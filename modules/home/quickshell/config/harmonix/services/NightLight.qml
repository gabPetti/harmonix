pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Warm-screen toggle, backed by scripts/nightlight (which owns the hyprsunset
// process and its state file).
QtObject {
  id: root

  readonly property string script: Quickshell.shellPath("scripts/nightlight")

  property bool active: false

  readonly property Process query: Process {
    command: [root.script, "status"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.active = text.trim() === "state=on"
    }
  }

  readonly property Process toggler: Process {
    command: [root.script, "toggle"]
    stdout: StdioCollector {
      onStreamFinished: root.active = text.trim() === "state=on"
    }
  }

  function toggle() {
    root.toggler.running = true;
  }
}
