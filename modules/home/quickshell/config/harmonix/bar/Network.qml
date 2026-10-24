import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking as Net
import "../theme"
import "../components"

// Wi-Fi/wired state and a connect menu, straight off NetworkManager through
// Quickshell's Networking service -- no nmcli polling, and no terminal popup
// for picking a network.
BarPill {
  id: root

  readonly property var devices: Net.Networking.devices.values
  readonly property var wifiDevice: root.devices.find(device => device.type === Net.DeviceType.Wifi) ?? null
  readonly property var wiredDevice: root.devices.find(device => device.type === Net.DeviceType.Wired) ?? null
  readonly property var activeWifi: root.wifiDevice?.networks?.values?.find(network => network.connected) ?? null
  readonly property bool wiredUp: root.wiredDevice?.connected ?? false
  readonly property bool wifiOn: Net.Networking.wifiEnabled

  // Connected first, then strongest.
  readonly property var networks: (root.wifiDevice?.networks?.values ?? []).slice()
    .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
    .slice(0, 8)

  // The network waiting on a password, if any.
  property var pskTarget: null

  active: popup.visible
  tooltipText: root.wiredUp ? `Wired  ·  ${root.wiredDevice.address}`
    : !root.wifiOn ? "Wi-Fi off"
    : root.activeWifi ? `${root.activeWifi.name}  ·  ${Math.round(root.activeWifi.signalStrength)}%`
    : "Not connected"

  onClicked: popup.toggle()
  onRightClicked: Net.Networking.wifiEnabled = !Net.Networking.wifiEnabled

  function activate(network) {
    if (network.connected) {
      network.disconnect();
      return;
    }
    if (network.known || network.security === Net.WifiSecurityType.Open) {
      network.connect();
      return;
    }
    root.pskTarget = network;
  }

  function submitPsk() {
    if (!root.pskTarget) return;
    root.pskTarget.connectWithPsk(pskField.text);
    root.pskTarget = null;
    pskField.text = "";
  }

  // Only scan while the menu is open; a background scan costs battery and
  // interrupts the active connection on some cards.
  Binding {
    target: root.wifiDevice
    property: "scannerEnabled"
    value: popup.visible && root.wifiOn
    when: root.wifiDevice !== null
    restoreMode: Binding.RestoreNone
  }

  StyledText {
    text: root.wiredUp ? Icons.wired
      : !root.wifiOn ? Icons.wifiOff
      : root.activeWifi ? Icons.wifi(root.activeWifi.signalStrength)
      : Icons.wifi(0)
    color: root.wiredUp || root.activeWifi ? Colors.fg : Colors.outline
    font.pixelSize: Theme.iconSize
  }

  BarPopup {
    id: popup

    anchorItem: root
    contentWidth: 320

    onVisibleChanged: {
      if (!popup.visible) {
        root.pskTarget = null;
        pskField.text = "";
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      SectionLabel {
        text: "Wi-Fi"
      }

      ToggleSwitch {
        checked: root.wifiOn
        onToggled: Net.Networking.wifiEnabled = !root.wifiOn
      }
    }

    ListRow {
      visible: root.wiredDevice !== null
      icon: Icons.wired
      iconColor: root.wiredUp ? Colors.accent : Colors.fgDim
      active: root.wiredUp
      title: "Wired"
      subtitle: root.wiredUp ? root.wiredDevice.address : "Unplugged"
      onClicked: {
        if (root.wiredUp) root.wiredDevice.disconnect();
      }
    }

    StyledText {
      Layout.fillWidth: true
      visible: root.wifiOn && root.networks.length === 0
      text: "Scanning…"
      color: Colors.fgDim
      font.pixelSize: Theme.fontSizeSmall
    }

    Repeater {
      model: root.wifiOn ? root.networks : []

      delegate: ListRow {
        required property var modelData

        active: modelData.connected
        busy: modelData.stateChanging
        icon: Icons.wifi(modelData.signalStrength)
        title: modelData.name || "(hidden)"
        subtitle: modelData.connected ? "Connected"
          : modelData.known ? "Saved"
          : modelData.security === Net.WifiSecurityType.Open ? "Open" : ""
        trailing: modelData.security === Net.WifiSecurityType.Open
          ? `${Math.round(modelData.signalStrength)}%`
          : `${Icons.lock} ${Math.round(modelData.signalStrength)}%`
        onClicked: root.activate(modelData)
        onRightClicked: {
          if (modelData.known) modelData.forget();
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      visible: root.pskTarget !== null
      implicitHeight: 36
      radius: 10
      color: Colors.bg1

      onVisibleChanged: {
        if (visible) pskField.forceActiveFocus();
      }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 6
        spacing: 8

        StyledText {
          text: Icons.lock
          color: Colors.fgDim
        }

        TextInput {
          id: pskField

          Layout.fillWidth: true
          color: Colors.fg
          font.family: Theme.font
          font.pixelSize: Theme.fontSize
          echoMode: TextInput.Password
          selectByMouse: true
          selectionColor: Colors.accent
          selectedTextColor: Colors.accentFg
          verticalAlignment: TextInput.AlignVCenter

          Keys.onReturnPressed: root.submitPsk()
          Keys.onEnterPressed: root.submitPsk()
          Keys.onEscapePressed: root.pskTarget = null

          StyledText {
            anchors.verticalCenter: parent.verticalCenter
            visible: pskField.text === ""
            text: root.pskTarget ? `Password for ${root.pskTarget.name}` : ""
            color: Colors.fgDim
            font.pixelSize: Theme.fontSizeSmall
          }
        }

        IconButton {
          icon: Icons.check
          size: 26
          iconSize: Theme.fontSizeSmall
          onClicked: root.submitPsk()
        }
      }
    }
  }
}
