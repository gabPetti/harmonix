import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

// The VPN pill: which tunnel is up, and a menu of the saved profiles to
// bring one up or take it down. Sits beside the network pill because a VPN
// rides on top of the link rather than standing in for it -- keeping the two
// separate is what lets the Wi-Fi glyph go on reporting the Wi-Fi.
BarPill {
  id: root

  readonly property var connections: Vpn.connections
  readonly property bool connected: Vpn.connected
  // Right click is the shortcut for the common case: one profile, toggled
  // without opening anything. With several saved it would be a guess, so it
  // only ever takes down what is already up.
  readonly property var quickTarget: root.connected ? Vpn.active[0]
    : root.connections.length === 1 ? root.connections[0]
    : null

  active: popup.visible
  tooltipText: root.connections.length === 0 ? "No VPN profiles"
    : root.connected ? `VPN  ·  ${Vpn.active.map(connection => connection.name).join(", ")}`
    : "VPN off"

  // nmcli monitor only narrates connections changing *state*, so a profile
  // that was merely added -- by a rebuild writing one into
  // /etc/NetworkManager -- never announces itself, and the list stays as it
  // was when the shell started. Opening the menu is the moment the answer
  // has to be current.
  onActiveChanged: if (root.active) Vpn.refresh()

  onClicked: popup.toggle()
  onRightClicked: {
    if (root.quickTarget) Vpn.toggle(root.quickTarget);
  }

  StyledText {
    text: Icons.vpn
    color: root.connected ? Colors.accent : Colors.outline
    font.pixelSize: Theme.iconSize
  }

  BarPopup {
    id: popup

    anchorItem: root
    panelId: "vpn"
    contentWidth: 384

    SectionLabel {
      text: "VPN"
    }

    StyledText {
      Layout.fillWidth: true
      visible: root.connections.length === 0
      text: "No VPN profiles in NetworkManager."
      color: Colors.fgDim
      font.pixelSize: Theme.fontSizeSmall
      wrapMode: Text.WordWrap
    }

    Repeater {
      model: root.connections

      delegate: ListRow {
        required property var modelData

        active: modelData.active
        busy: Vpn.busyUuid === modelData.uuid
        icon: Icons.vpn
        title: modelData.name
        subtitle: modelData.active ? "Connected"
          : modelData.type === "wireguard" ? "WireGuard" : "OpenVPN"
        onClicked: Vpn.toggle(modelData)
      }
    }

    // nmcli's own words. A tunnel fails for reasons the bar can't paraphrase
    // -- a wrong password, an unreachable gateway, a missing plugin -- and
    // guessing between them is worse than quoting it.
    StyledText {
      Layout.fillWidth: true
      visible: Vpn.error !== ""
      text: Vpn.error
      color: Colors.critical
      font.pixelSize: Theme.fontSizeSmall
      wrapMode: Text.WordWrap
    }
  }
}
