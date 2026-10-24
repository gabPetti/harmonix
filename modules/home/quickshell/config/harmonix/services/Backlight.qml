pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Display backlight. The current level is read straight out of sysfs so the
// bar doesn't fork a process just to redraw; only writes go through
// brightnessctl, which owns the permission handling.
QtObject {
  id: root

  property int percent: 0
  property string device: ""
  property int maxValue: 0

  readonly property bool available: root.device !== "" && root.maxValue > 0

  readonly property Process detect: Process {
    running: true
    command: ["sh", "-c", "ls -1 /sys/class/backlight 2>/dev/null | head -n1"]
    stdout: StdioCollector {
      onStreamFinished: root.device = text.trim()
    }
  }

  readonly property FileView maxFile: FileView {
    path: root.device === "" ? "" : `/sys/class/backlight/${root.device}/max_brightness`
    onLoaded: root.maxValue = parseInt(text().trim(), 10) || 0
  }

  readonly property FileView currentFile: FileView {
    path: root.device === "" ? "" : `/sys/class/backlight/${root.device}/brightness`
    onLoaded: {
      if (root.maxValue > 0) {
        root.percent = Math.round((parseInt(text().trim(), 10) || 0) / root.maxValue * 100);
      }
    }
  }

  readonly property Timer sampler: Timer {
    interval: 1000
    running: root.available
    repeat: true
    onTriggered: root.currentFile.reload()
  }

  readonly property Process writer: Process {
    onExited: root.currentFile.reload()
  }

  function set(value) {
    root._run(`${Math.max(1, Math.min(100, Math.round(value)))}%`);
  }

  function adjust(delta) {
    root.set(root.percent + delta);
  }

  function _run(argument) {
    root.writer.running = false;
    root.writer.command = ["brightnessctl", "--machine-readable", "set", argument];
    root.writer.running = true;
  }
}
