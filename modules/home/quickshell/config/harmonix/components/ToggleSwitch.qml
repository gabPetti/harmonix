import QtQuick
import "../theme"

// Small on/off switch for popup headers (Wi-Fi, Bluetooth). It never flips
// itself: the owner reacts to `toggled` and feeds `checked` back from the real
// device state, so the switch can't drift out of sync with the system.
Rectangle {
  id: root

  property bool checked: false

  signal toggled

  implicitWidth: 36
  implicitHeight: 20
  radius: height / 2
  color: root.checked ? Colors.accent : Colors.bg2

  Behavior on color {
    ColorAnimation { duration: Theme.animFast }
  }

  Rectangle {
    x: root.checked ? root.width - width - 3 : 3
    anchors.verticalCenter: parent.verticalCenter
    width: 14
    height: 14
    radius: 7
    color: root.checked ? Colors.accentFg : Colors.fg

    Behavior on x {
      NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled()
  }
}
