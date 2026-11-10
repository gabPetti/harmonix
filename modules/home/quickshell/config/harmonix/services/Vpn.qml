pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The VPN profiles NetworkManager knows about, and which of them is up.
//
// Everything else in the bar reads NetworkManager through Quickshell's
// Networking service, but that one models *devices* -- a VPN connection has
// none until it is already up, so its profiles are invisible there. nmcli is
// the only way to see them, hence the one CLI left in the network pill.
//
// Rather than poll, `nmcli monitor` is held open: it prints a line whenever
// any connection changes state, which is the cue to re-read the list.
QtObject {
  id: root

  // { name, uuid, type, active } per saved VPN profile, actives first.
  property var connections: []

  // The uuid of a profile whose up/down is still in flight, so the list can
  // spin that row instead of looking like the click did nothing.
  property string busyUuid: ""

  property string error: ""

  readonly property var active: root.connections.filter(connection => connection.active)
  readonly property bool connected: root.active.length > 0

  function refresh(): void {
    root.lister.running = true;
  }

  function up(uuid: string): void {
    root.run(["nmcli", "connection", "up", "uuid", uuid], uuid);
  }

  function down(uuid: string): void {
    root.run(["nmcli", "connection", "down", "uuid", uuid], uuid);
  }

  function toggle(connection: var): void {
    if (connection.active) root.down(connection.uuid);
    else root.up(connection.uuid);
  }

  function run(command: var, uuid: string): void {
    if (root.busyUuid !== "") return;
    root.error = "";
    root.busyUuid = uuid;
    root.switcher.command = command;
    root.switcher.running = true;
  }

  // Terse output is colon-separated with any literal colon in a field
  // backslash-escaped, so fields are split on unescaped colons only.
  //
  // Scanned a character at a time rather than split on a lookbehind: QML's
  // engine takes `/(?<!\\):/` without complaint and then never matches it,
  // which hands back the whole line as one field and quietly empties the
  // list -- a VPN profile that is right there in nmcli simply never appears.
  function fields(line: string): var {
    const parts = [];
    let current = "";

    for (let at = 0; at < line.length; at++) {
      if (line[at] === "\\" && at + 1 < line.length)
        current += line[++at];
      else if (line[at] === ":") {
        parts.push(current);
        current = "";
      } else
        current += line[at];
    }
    parts.push(current);

    return parts;
  }

  readonly property Process lister: Process {
    command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,STATE", "connection", "show"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        root.connections = text.trim().split("\n")
          .filter(line => line !== "")
          .map(line => root.fields(line))
          .filter(parts => parts[2] === "vpn" || parts[2] === "wireguard")
          .map(parts => ({
            name: parts[0],
            uuid: parts[1],
            type: parts[2],
            active: parts[3] === "activated"
          }))
          .sort((a, b) => (b.active - a.active) || a.name.localeCompare(b.name));
      }
    }
  }

  readonly property Process switcher: Process {
    stderr: StdioCollector {
      onStreamFinished: root.error = text.trim()
    }
    onExited: {
      root.busyUuid = "";
      root.refresh();
    }
  }

  // A singleton builds its object properties on first access, and nothing
  // reads the monitor -- without this the list would only ever be as fresh
  // as the last click.
  Component.onCompleted: root.monitor

  readonly property Process monitor: Process {
    command: ["nmcli", "monitor"]
    running: true
    stdout: SplitParser {
      onRead: debounce.restart()
    }
  }

  // nmcli monitor narrates a single connect as a burst of lines; one re-read
  // once it settles is enough.
  readonly property Timer debounce: Timer {
    interval: 300
    onTriggered: root.refresh()
  }
}
