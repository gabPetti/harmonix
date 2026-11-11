import QtQuick
import Quickshell.Networking as Net
import "../theme"
import "../components"
import "../services"

// The top-right corner: the three things worth knowing about a machine you
// have walked back up to, in the order you would ask them. Charge first,
// because it is the one that decides whether the laptop will still be awake
// later; then whether it is on the network, and whether its sound is muted.
//
// Read-only throughout. Volume and brightness are adjustable from the bar,
// and the lock screen is the one place in this shell where a control would be
// a control anyone walking past could use.
Row {
  id: root

  // 0..1, from LockSurface.stage.
  property real stage: 1

  readonly property var devices: Net.Networking.devices.values
  readonly property var wifiDevice: root.devices.find(device => device.type === Net.DeviceType.Wifi) ?? null
  readonly property var wiredDevice: root.devices.find(device => device.type === Net.DeviceType.Wired) ?? null
  readonly property var activeWifi: root.wifiDevice?.networks?.values?.find(network => network.connected) ?? null
  readonly property bool wiredUp: root.wiredDevice?.connected ?? false

  spacing: Theme.pillSpacing
  opacity: root.stage
  transform: Translate { y: -Theme.lockRise * (1 - root.stage) }

  LockChip {
    visible: Power.hasBattery
    icon: Icons.battery(Power.percent, Power.charging)
    label: Power.secondsRemaining > 0
      ? `${Power.percent}%  ·  ${Power.formatDuration(Power.secondsRemaining)}`
      : `${Power.percent}%`
    tone: Power.critical ? Colors.critical
      : Power.low ? Colors.warning
      : Power.charging ? Colors.accent
      : Colors.fg
  }

  LockChip {
    icon: root.wiredUp ? Icons.wired
      : !Net.Networking.wifiEnabled ? Icons.wifiOff
      : root.activeWifi ? Icons.wifi(Math.round(root.activeWifi.signalStrength * 100))
      : Icons.wifiOff
    label: root.wiredUp ? "Wired"
      : root.activeWifi?.name ?? "Offline"
  }

  // Only when there is something unusual to report: a muted machine is worth
  // saying, a machine at its usual volume is not.
  LockChip {
    visible: Audio.muted
    icon: Icons.volume(Audio.volume * 100, Audio.muted)
    label: "Muted"
    tone: Colors.warning
  }
}
