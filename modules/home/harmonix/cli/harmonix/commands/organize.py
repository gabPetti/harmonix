"""harmonix organize: move loose files and git repos to where they belong.

Where things go is ~/.config/harmonix/organize.toml. Nothing is overwritten
(a clash gets a -1, -2, ... suffix), and every run is logged so `--undo` can
put the last one back.
"""

import fnmatch
import json
import os
import re
import shutil
import subprocess
import sys
import time
import tomllib
from datetime import datetime
from pathlib import Path

HOME = Path.home()
CONFIG = (
    Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config"))
    / "harmonix"
    / "organize.toml"
)
LOGS = (
    Path(os.environ.get("XDG_STATE_HOME", HOME / ".local" / "state"))
    / "harmonix"
    / "organize"
)
# Browsers write these while a download is still in flight.
PARTIAL_SUFFIXES = {".part", ".crdownload", ".download", ".tmp"}


def register(subparsers):
    parser = subparsers.add_parser(
        "organize", help="move files and git repos to where they belong"
    )
    parser.add_argument(
        "-n", "--dry-run", action="store_true", help="show the moves, make none"
    )
    parser.add_argument(
        "--undo", action="store_true", help="put the last run's moves back"
    )
    parser.add_argument(
        "paths",
        nargs="*",
        type=Path,
        help="files, repos or folders to sort instead of the configured sources",
    )
    parser.set_defaults(run=run)


def run(args):
    if args.undo:
        return undo(args.dry_run)

    try:
        config = Config(tomllib.loads(CONFIG.read_text()))
    except FileNotFoundError:
        print(f"harmonix organize: no config at {CONFIG}", file=sys.stderr)
        return 1

    moves = plan(candidates(args.paths, config), config)
    if not moves:
        print("Nothing to organize.")
        return 0

    for src, dst in moves:
        print(f"{pretty(src)}  →  {pretty(dst)}")
    if args.dry_run:
        print(f"\n{len(moves)} would move (dry run).")
        return 0

    LOGS.mkdir(parents=True, exist_ok=True)
    log = LOGS / f"{datetime.now():%Y-%m-%dT%H-%M-%S}.jsonl"
    with log.open("w") as out:
        for src, dst in moves:
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(src, dst)
            # Written per move, so a run that dies halfway is still undoable.
            out.write(json.dumps({"from": str(src), "to": str(dst)}) + "\n")
            out.flush()
    print(f"\n{len(moves)} moved. Undo with: harmonix organize --undo")
    return 0


class Config:
    def __init__(self, raw):
        self.sources = [expand(s) for s in raw.get("sources", [])]
        self.min_age = raw.get("min_age_minutes", 2) * 60
        self.rules = [
            ([g.lower() for g in rule["match"]], expand(rule["to"]))
            for rule in raw.get("rule", [])
        ]
        self.types = {
            ext.lower(): expand(dest)
            for dest, exts in raw.get("types", {}).items()
            for ext in exts
        }

        code = dict(raw.get("code", {}))
        self.code_root = expand(code.pop("root", "~/Code"))
        self.code_groups = {
            group: [re.compile(p, re.IGNORECASE) for p in patterns]
            for group, patterns in code.items()
        }
        user = os.environ.get("HARMONIX_GITHUB_USER")
        self.own_remote = (
            re.compile(rf"github\.com[:/]{re.escape(user)}/", re.IGNORECASE)
            if user
            else None
        )
        repo = os.environ.get("HARMONIX_REPO")
        self.pinned = {Path(repo).resolve()} if repo else set()


def candidates(paths, config):
    """Everything that might move: loose files and repos in the sources."""
    if paths:
        for path in map(Path.absolute, paths):
            if path.is_dir() and not is_repo(path):
                yield from children(path, config)
            elif path.exists():
                yield path
    else:
        for source in config.sources:
            if source.is_dir():
                yield from children(source, config)


def children(folder, config):
    now = time.time()
    for child in sorted(folder.iterdir()):
        if child.name.startswith(".") or child.is_symlink():
            continue
        if child.is_dir():
            if is_repo(child):
                yield child
        elif child.suffix.lower() not in PARTIAL_SUFFIXES:
            if now - child.stat().st_mtime >= config.min_age:
                yield child


def plan(items, config):
    moves, claimed = [], set()
    for item in items:
        folder = destination(item, config)
        if folder is None or folder == item.parent:
            continue
        target = free(folder / item.name, item.is_dir(), claimed)
        claimed.add(target)
        moves.append((item, target))
    return moves


def destination(path, config):
    if path.is_dir():
        return repo_destination(path, config)

    name = path.name.lower()
    for globs, folder in config.rules:
        if any(fnmatch.fnmatch(name, g) for g in globs):
            return folder
    return config.types.get(path.suffix.lower().lstrip("."))


def repo_destination(repo, config):
    if repo.resolve() in config.pinned or config.code_root in repo.parents:
        return None

    remote = remote_url(repo)
    if remote is None:
        return config.code_root / "personal"
    if config.own_remote and config.own_remote.search(remote):
        return config.code_root / "personal"
    for group, patterns in config.code_groups.items():
        if any(p.search(remote) for p in patterns):
            return config.code_root / group
    return config.code_root / "forks"


def remote_url(repo):
    def git(*args):
        result = subprocess.run(
            ["git", "-C", str(repo), *args], capture_output=True, text=True
        )
        return result.stdout.strip() if result.returncode == 0 else ""

    remotes = git("remote").split()
    if not remotes:
        return None
    # origin if there is one, otherwise whichever remote is listed first.
    name = "origin" if "origin" in remotes else remotes[0]
    return git("remote", "get-url", name) or None


def is_repo(path):
    return (path / ".git").exists()


def free(target, is_dir, claimed):
    """target, or target-1, target-2, ... if that name is already taken."""
    # A folder's name is all stem: "grpc-java.v2" is not a .v2 file.
    stem, suffix = (target.name, "") if is_dir else (target.stem, target.suffix)
    candidate, n = target, 0
    while candidate.exists() or candidate.is_symlink() or candidate in claimed:
        n += 1
        candidate = target.with_name(f"{stem}-{n}{suffix}")
    return candidate


def undo(dry_run):
    logs = sorted(LOGS.glob("*.jsonl")) if LOGS.is_dir() else []
    if not logs:
        print("Nothing to undo.")
        return 0

    log = logs[-1]
    moves = [json.loads(line) for line in log.read_text().splitlines() if line]
    failed = 0
    for move in reversed(moves):
        src, dst = Path(move["from"]), Path(move["to"])
        if not dst.exists() or src.exists():
            print(f"skipped {pretty(dst)}: moved or replaced since", file=sys.stderr)
            failed += 1
            continue
        print(f"{pretty(dst)}  →  {pretty(src)}")
        if not dry_run:
            src.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(dst, src)

    if not dry_run:
        log.rename(log.with_suffix(".undone"))
    return 1 if failed else 0


def expand(path):
    return Path(path).expanduser()


def pretty(path):
    try:
        return "~/" + str(path.relative_to(HOME))
    except ValueError:
        return str(path)
