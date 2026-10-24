pragma Singleton
import QtQuick
import Quickshell.Io

// CPU and memory load, sampled once for every consumer. Reads /proc directly
// rather than shelling out, so the bar costs no process spawns at idle.
QtObject {
  id: root

  // Percentages, 0..100.
  property real cpu: 0
  property real memory: 0
  property real swap: 0

  property real memoryUsedGb: 0
  property real memoryTotalGb: 0

  property real disk: 0
  property real diskUsedGb: 0
  property real diskTotalGb: 0

  property real _prevIdle: 0
  property real _prevTotal: 0

  readonly property FileView statFile: FileView {
    path: "/proc/stat"
    onLoaded: root._updateCpu(text())
  }

  readonly property FileView memFile: FileView {
    path: "/proc/meminfo"
    onLoaded: root._updateMemory(text())
  }

  readonly property Timer sampler: Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.statFile.reload();
      root.memFile.reload();
    }
  }

  // Disk has no /proc equivalent, so this is the one reading that costs a
  // process -- but it only covers the root filesystem and barely moves, so it
  // samples far less often than CPU and memory do.
  readonly property Process diskQuery: Process {
    command: ["df", "-kP", "/"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root._updateDisk(text)
    }
  }

  readonly property Timer diskSampler: Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: root.diskQuery.running = true
  }

  function _updateCpu(content) {
    const fields = content.split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
    const idle = fields[3] + fields[4];
    const total = fields.reduce((a, b) => a + b, 0);

    const idleDelta = idle - root._prevIdle;
    const totalDelta = total - root._prevTotal;

    if (root._prevTotal > 0 && totalDelta > 0) {
      root.cpu = Math.max(0, Math.min(100, 100 * (1 - idleDelta / totalDelta)));
    }

    root._prevIdle = idle;
    root._prevTotal = total;
  }

  function _updateMemory(content) {
    const values = {};
    for (const line of content.split("\n")) {
      const match = line.match(/^(\w+):\s+(\d+)/);
      if (match) values[match[1]] = Number(match[2]);
    }

    const total = values.MemTotal ?? 0;
    const available = values.MemAvailable ?? 0;
    if (total > 0) {
      root.memory = 100 * (1 - available / total);
      root.memoryTotalGb = total / 1048576;
      root.memoryUsedGb = (total - available) / 1048576;
    }

    const swapTotal = values.SwapTotal ?? 0;
    const swapFree = values.SwapFree ?? 0;
    root.swap = swapTotal > 0 ? 100 * (1 - swapFree / swapTotal) : 0;
  }

  function _updateDisk(content) {
    // df -kP prints a header and exactly one line per filesystem, in 1 KiB
    // blocks: device, size, used, available, capacity, mountpoint.
    const line = content.trim().split("\n")[1];
    if (!line) return;

    const fields = line.trim().split(/\s+/);
    const used = Number(fields[2]);
    const available = Number(fields[3]);
    // Total from used + available rather than the size column, so the
    // percentage matches what df reports as Capacity -- the difference is
    // root-reserved blocks, which aren't usable space.
    const total = used + available;
    if (!(total > 0)) return;

    root.disk = 100 * used / total;
    root.diskUsedGb = used / 1048576;
    root.diskTotalGb = total / 1048576;
  }
}
