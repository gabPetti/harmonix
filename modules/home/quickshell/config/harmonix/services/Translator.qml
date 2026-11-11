pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The bar's translator: Portuguese in, English, German or Spanish out,
// through Argos Translate running locally -- no network, no API, nothing
// billed.
//
// Argos spends about six seconds loading its models and a third of a second
// using them, so scripts/translate is held open as a daemon for the life of
// the shell rather than run per translation (see scripts/translate.py for the
// line protocol). It is the same reason the VPN service keeps `nmcli monitor`
// open instead of polling.
//
// The text being translated lives here rather than in the panel so that it
// survives the panel closing -- a translation you went to copy into another
// window is still there when you come back -- and so switching language
// re-runs the same text without retyping it.
QtObject {
  id: root

  readonly property string script: Quickshell.shellPath("scripts/translate")

  // Portuguese is always the source: this exists to read what is in front of
  // you, not to compose in another language. `code` is what the daemon takes,
  // `title` what the panel's chips say, `label` the two letters the pill has
  // room for.
  readonly property var languages: [
    { code: "en", title: "English", label: "EN" },
    { code: "de", title: "German", label: "DE" },
    { code: "es", title: "Spanish", label: "ES" }
  ]

  property string target: "en"

  readonly property var language: root.languages.find(entry => entry.code === root.target) ?? root.languages[0]

  // False until the daemon has answered for itself, which it does once at
  // startup -- either that the models are there, or that they still have to
  // be downloaded.
  property bool ready: false
  property bool fetching: false

  property string input: ""
  property string output: ""
  property string error: ""

  // The request the daemon is still working on, so a reply that arrives after
  // the language changed can be dropped rather than shown. 0 is none.
  property int pending: 0
  property int lastId: 0

  readonly property bool busy: root.pending !== 0

  // The text the output belongs to, so a stale translation can be dimmed the
  // moment the input moves away from it instead of sitting there looking
  // current.
  property string translated: ""

  readonly property bool stale: root.output !== "" && root.input.trim() !== root.translated

  function setTarget(code: string): void {
    if (code === root.target)
      return;

    root.target = code;
    root.save();
    // The language is only ever changed with an intent behind it: if there is
    // text in the panel, that intent is to see it in the language just picked.
    if (root.input.trim() !== "")
      root.translate(root.input);
  }

  // What Tab does in the open panel, and what scrolling the pill does. Step
  // is signed so that going back is one Backtab rather than two Tabs -- with
  // three languages the shorter way round is worth having.
  function cycle(step: int): void {
    const count = root.languages.length;
    const at = root.languages.findIndex(entry => entry.code === root.target);
    root.setTarget(root.languages[(at + (step || 1) + count) % count].code);
  }

  function translate(text: string): void {
    const trimmed = text.trim();

    root.input = text;
    root.error = "";

    if (trimmed === "") {
      root.output = "";
      root.translated = "";
      return;
    }

    if (!root.ready) {
      root.error = root.fetching ? "still downloading the language models"
        : "the language models aren't installed yet";
      return;
    }

    root.lastId++;
    root.pending = root.lastId;
    root.daemon.write(JSON.stringify({ id: root.lastId, lang: root.target, text: trimmed }) + "\n");
  }

  // Translate what is on the clipboard, which is how most of this gets used:
  // the text being translated was selected somewhere else.
  function translateClipboard(): void {
    if (root.busy)
      return;

    root.error = "";
    root.pasting.running = true;
  }

  function copy(): void {
    if (root.output === "")
      return;

    root.copier.command = ["wl-copy", "--", root.output];
    root.copier.running = true;
  }

  function clear(): void {
    root.input = "";
    root.output = "";
    root.translated = "";
    root.error = "";
  }

  // Some 290MB of models, which is why they are fetched on request rather
  // than pinned into every system generation.
  function fetch(): void {
    if (root.fetching)
      return;

    root.error = "";
    root.fetching = true;
    root.fetcher.running = true;
  }

  // A singleton builds its object-typed properties on first access, and
  // nothing reads these until they are needed -- without this the daemon
  // would not exist to be started. Same trap as ClaudeVoice's recorder.
  Component.onCompleted: {
    root.daemon;
    root.fetcher;
    root.pasting;
    root.copier;
    root.store;
  }

  readonly property Process daemon: Process {
    id: daemon

    command: [root.script, "serve"]
    running: true
    stdinEnabled: true

    stdout: SplitParser {
      onRead: line => root._handle(line)
    }

    stderr: SplitParser {
      // Argos narrates its model loading; none of it is the bar's business
      // unless something actually failed, and the failure comes back on
      // stdout as an error reply.
      onRead: line => console.log("Translator:", line)
    }

    onExited: (code, status) => {
      root.ready = false;
      root.pending = 0;
      // Nothing restarts it from here: the daemon only exits if it crashed or
      // its stdin closed, and a crash loop would be worse than one dead pill.
      // The panel's download row restarts it once the models are in.
      if (code !== 0 && root.error === "")
        root.error = "the translator stopped (exit " + code + ")";
    }
  }

  function _handle(line: string): void {
    let reply;
    try {
      reply = JSON.parse(line);
    } catch (error) {
      console.warn("Translator: unreadable reply:", line);
      return;
    }

    // The startup line, which has no id.
    if (reply.ready !== undefined) {
      root.ready = reply.ready;
      if (!reply.ready && reply.error)
        root.error = reply.error;
      return;
    }

    // A reply to a request that has since been superseded -- the language
    // changed, or the text did -- is no longer the answer to anything.
    if (reply.id !== root.pending)
      return;

    root.pending = 0;

    if (reply.error) {
      root.error = reply.error;
      return;
    }

    root.output = reply.text;
    root.translated = root.input.trim();
  }

  readonly property Process fetcher: Process {
    id: fetcher

    command: [root.script, "fetch"]

    stdout: SplitParser {
      onRead: line => {
        try {
          const reply = JSON.parse(line);
          if (reply.error)
            root.error = reply.error;
        } catch (error) {
          console.warn("Translator: unreadable fetch reply:", line);
        }
      }
    }

    stderr: SplitParser {
      onRead: line => console.log("Translator fetch:", line)
    }

    onExited: (code, status) => {
      root.fetching = false;
      if (code !== 0 && root.error === "")
        root.error = "downloading the models failed (exit " + code + ")";
      // Either way the daemon has to be asked again: it only looks for the
      // models when it starts.
      root.daemon.running = false;
      root.daemon.running = true;
    }
  }

  readonly property Process pasting: Process {
    id: pasting

    // --no-newline so the trailing newline wl-paste adds doesn't count as
    // part of the selection; -t text/plain so a copy out of a browser comes
    // in as its text rather than as the HTML behind it.
    command: ["wl-paste", "--no-newline", "--type", "text/plain"]

    stdout: StdioCollector {
      onStreamFinished: {
        const clipboard = text.trim();
        if (clipboard === "")
          root.error = "the clipboard has no text in it";
        else
          root.translate(clipboard);
      }
    }
  }

  readonly property Process copier: Process {
    id: copier
  }

  // The chosen language outlives the session; the text deliberately doesn't.
  readonly property FileView store: FileView {
    id: store

    path: Quickshell.statePath("translate.json")
    preload: true
    // Silent on a missing file: there is none until the language is first
    // changed, and a first run shouldn't log an error for that.
    printErrors: false

    onLoaded: {
      try {
        const saved = JSON.parse(store.text());
        if (root.languages.some(entry => entry.code === saved.target))
          root.target = saved.target;
      } catch (error) {
        console.warn("Translator: ignoring unreadable translate.json:", error);
      }
    }
  }

  function save(): void {
    root.store.setText(JSON.stringify({ target: root.target }));
  }
}
