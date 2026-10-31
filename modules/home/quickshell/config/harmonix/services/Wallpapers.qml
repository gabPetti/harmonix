pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wallpaper list and "apply" action, backed by scripts/wallpaper. The script
// owns the symlink + hyprpaper + matugen sequence; this just drives it and
// caches what is on disk.
QtObject {
  id: root

  // HARMONIX_WALLPAPERS comes from the systemd unit, so the directory follows
  // vars.repoPath instead of being hardcoded here.
  readonly property string directory: Quickshell.env("HARMONIX_WALLPAPERS")
    || `${Quickshell.env("HOME")}/harmonix/wallpapers`
  readonly property string script: Quickshell.shellPath("scripts/wallpaper")

  property var files: []
  property string current: ""
  property bool applying: false
  property bool fetching: false

  readonly property Process lister: Process {
    command: [root.script, "list"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.files = text.split("\n").filter(line => line !== "")
    }
  }

  readonly property Process currentQuery: Process {
    command: [root.script, "current"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.current = text.trim()
    }
  }

  readonly property Process applier: Process {
    // Surface failures: a silent non-zero exit here is exactly what makes a
    // broken apply look like "the picker did nothing".
    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim() !== "") console.warn("wallpaper:", text.trim());
      }
    }

    onExited: exitCode => {
      root.applying = false;
      if (exitCode !== 0) console.warn("wallpaper: apply failed with exit code", exitCode);
      root.currentQuery.running = true;
    }
  }

  // Downloads a wallpaper from Wallhaven and applies it. The script owns the
  // search and the download; this only reports that one is in flight, so the
  // launcher can show the button spinning.
  readonly property Process fetcher: Process {
    command: [root.script, "fetch"]

    stdout: StdioCollector {
      onStreamFinished: {
        if (text.trim() !== "") root.current = text.trim();
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim() !== "") console.warn("wallpaper fetch:", text.trim());
      }
    }

    onExited: exitCode => {
      root.fetching = false;
      if (exitCode !== 0) console.warn("wallpaper: fetch failed with exit code", exitCode);
      root.refresh();
    }
  }

  function fetch() {
    if (root.fetching) return;
    root.fetching = true;
    root.fetcher.running = true;
  }

  function refresh() {
    root.lister.running = true;
    root.currentQuery.running = true;
  }

  function apply(path) {
    if (root.applying) return;
    root.applying = true;
    root.applier.command = [root.script, "set", path];
    root.applier.running = true;
  }

  function name(path) {
    return path.split("/").pop().replace(/\.[^.]+$/, "").replace(/[-_]/g, " ");
  }
}
