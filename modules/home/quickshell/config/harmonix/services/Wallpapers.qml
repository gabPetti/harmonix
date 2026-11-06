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
  // "light" or "dark": which half of the matugen palette every template is
  // rendered from. The script owns the stored value; this mirrors it.
  property string mode: "dark"
  readonly property bool light: root.mode === "light"
  property bool applying: false
  property bool fetching: false
  property bool switchingMode: false

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

  readonly property Process modeQuery: Process {
    command: [root.script, "mode"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        if (text.trim() !== "") root.mode = text.trim();
      }
    }
  }

  // Re-themes the session from the wallpaper that is already up, so this is
  // the same work as an apply -- every template re-rendered, every post_hook
  // fired -- with only the light/dark half of the palette changed.
  readonly property Process modeSetter: Process {
    stdout: StdioCollector {
      onStreamFinished: {
        if (text.trim() !== "") root.mode = text.trim();
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim() !== "") console.warn("wallpaper mode:", text.trim());
      }
    }

    onExited: exitCode => {
      root.switchingMode = false;
      if (exitCode !== 0) {
        console.warn("wallpaper: mode switch failed with exit code", exitCode);
        // The stored mode is what the script decided, not what was asked
        // for: on a failure, read it back rather than keeping the guess.
        root.modeQuery.running = true;
      }
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
    root.modeQuery.running = true;
  }

  // `which` is "light", "dark" or "toggle".
  function setMode(which) {
    if (root.switchingMode) return;
    root.switchingMode = true;
    root.modeSetter.command = [root.script, "mode", which];
    root.modeSetter.running = true;
  }

  function toggleMode() {
    root.setMode("toggle");
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
