"""Argos Translate, kept warm.

Loading the models costs about six seconds; translating a sentence with them
already loaded costs about a third of one. So this is a daemon rather than a
command: the bar starts it once (services/Translator.qml) and then writes one
request per line for as long as the shell is running.

Protocol, one JSON object per line each way:

    in   {"id": 1, "lang": "en", "text": "bom dia"}
    out  {"id": 1, "text": "good morning"}
         {"id": 1, "error": "why it stopped"}

and one line at startup saying whether the language packages are there:

         {"ready": true}
         {"ready": false, "error": "..."}

Run as `translate.py fetch` it installs those packages instead -- some 290MB
of weights, which is why they are downloaded on request rather than pinned
into the system closure.
"""

import json
import sys

# Portuguese in, English, German or Spanish out. English and Spanish have
# direct packages; German does not, so it goes through English --
# argostranslate chains the two on its own, which is why en->de is in the
# packages to install even though nothing here ever asks for English in.
SOURCE = "pt"
TARGETS = ("en", "de", "es")
REQUIRED = (("pt", "en"), ("en", "de"), ("pt", "es"))

# Everything the libraries print on their own -- stanza's warnings, the
# HuggingFace notice -- would otherwise land in the middle of a response.
# Responses go to the real stdout; anything else is pushed to stderr, which
# the bar logs rather than parses.
out = sys.stdout
sys.stdout = sys.stderr

import argostranslate.package  # noqa: E402
import argostranslate.translate  # noqa: E402


def reply(payload):
    json.dump(payload, out)
    out.write("\n")
    out.flush()


def installed():
    return {
        (p.from_code, p.to_code)
        for p in argostranslate.package.get_installed_packages()
    }


def missing():
    return [pair for pair in REQUIRED if pair not in installed()]


def fetch():
    argostranslate.package.update_package_index()
    available = argostranslate.package.get_available_packages()

    for from_code, to_code in missing():
        match = next(
            (p for p in available if p.from_code == from_code and p.to_code == to_code),
            None,
        )
        if match is None:
            reply({"error": f"no {from_code}->{to_code} package in the Argos index"})
            return 1
        argostranslate.package.install_from_path(match.download())

    reply({"ready": True})
    return 0


def serve():
    absent = missing()
    if absent:
        names = ", ".join(f"{a}->{b}" for a, b in absent)
        reply({"ready": False, "error": f"missing language packages: {names}"})
    else:
        reply({"ready": True})

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            request = json.loads(line)
        except json.JSONDecodeError as error:
            reply({"error": f"unreadable request: {error}"})
            continue

        identifier = request.get("id")
        lang = request.get("lang")
        text = (request.get("text") or "").strip()

        if lang not in TARGETS:
            reply({"id": identifier, "error": f"cannot translate into {lang}"})
            continue
        if not text:
            reply({"id": identifier, "error": "nothing to translate"})
            continue

        try:
            reply(
                {
                    "id": identifier,
                    "text": argostranslate.translate.translate(text, SOURCE, lang),
                }
            )
        except Exception as error:  # the models raise their own exception types
            reply({"id": identifier, "error": str(error)})

    return 0


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "serve"
    sys.exit(fetch() if mode == "fetch" else serve())
