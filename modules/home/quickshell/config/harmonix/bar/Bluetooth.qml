import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth as Bluez
import "../theme"
import "../components"

// Adapter toggle plus a connect menu over BlueZ, which covers what
// blueman-manager was being opened for.
BarPill {
  id: root

  readonly property var adapter: Bluez.Bluetooth.defaultAdapter
  readonly property bool enabled: root.adapter?.enabled ?? false
  readonly property var connected: Bluez.Bluetooth.devices.values.filter(device => device.connected)

  // Paired devices first, then whatever the scan turned up.
  readonly property var devices: Bluez.Bluetooth.devices.values.slice()
    .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired)
      || (a.name ?? "").localeCompare(b.name ?? ""))
    .slice(0, 8)

  active: popup.visible
  tooltipText: !root.enabled ? "Bluetooth off"
    : root.connected.length > 0 ? root.connected.map(device => device.name).join(", ")
    : "Bluetooth on, nothing connected"

  onClicked: popup.toggle()
  onRightClicked: {
    if (root.adapter) root.adapter.enabled = !root.enabled;
  }

  // Discovery is only useful while the menu is open.
  Binding {
    target: root.adapter
    property: "discovering"
    value: popup.visible && root.enabled
    when: root.adapter !== null
    restoreMode: Binding.RestoreNone
  }

  StyledText {
    text: !root.enabled ? Icons.bluetoothOff
      : root.connected.length > 0 ? Icons.bluetoothConnected
      : Icons.bluetoothOn
    color: !root.enabled ? Colors.outline
      : root.connected.length > 0 ? Colors.accent
      : Colors.fg
    font.pixelSize: Theme.iconSize
  }

  BarPopup {
    id: popup

    anchorItem: root
    contentWidth: 320

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      SectionLabel {
        text: root.adapter?.discovering ? "Bluetooth  ·  scanning" : "Bluetooth"
      }

      ToggleSwitch {
        checked: root.enabled
        onToggled: {
          if (root.adapter) root.adapter.enabled = !root.enabled;
        }
      }
    }

    StyledText {
      Layout.fillWidth: true
      visible: root.enabled && root.devices.length === 0
      text: "No devices found yet…"
      color: Colors.fgDim
      font.pixelSize: Theme.fontSizeSmall
    }

    Repeater {
      model: root.enabled ? root.devices : []

      delegate: ListRow {
        required property var modelData

        active: modelData.connected
        busy: modelData.state === Bluez.BluetoothDeviceState.Connecting
          || modelData.state === Bluez.BluetoothDeviceState.Disconnecting
          || modelData.pairing
        icon: modelData.connected ? Icons.bluetoothConnected : Icons.bluetoothOn
        title: modelData.name || modelData.deviceName || modelData.address
        subtitle: modelData.connected ? "Connected" : modelData.paired ? "Paired" : "Available"
        trailing: modelData.batteryAvailable ? `${Math.round(modelData.battery * 100)}%` : ""
        onClicked: {
          if (modelData.connected) modelData.disconnect();
          else if (modelData.paired) modelData.connect();
          else modelData.pair();
        }
        // Right click forgets a device, the one thing the popup can't infer.
        onRightClicked: {
          if (modelData.paired) modelData.forget();
        }
      }
    }
  }
}
