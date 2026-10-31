import QtQuick
import "../theme"

// Small on/off switch for popup headers (Wi-Fi, Bluetooth). It never flips
// itself: the owner reacts to `toggled` and feeds `checked` back from the real
// device state, so the switch can't drift out of sync with the system.
Rectangle {
  id: root

  property bool checked: false

  // See ListRow. A switch has no hover state to borrow, so the keyboard
  // cursor is a ring around it.
  readonly property bool navigable: true
  property bool selected: false

  signal toggled

  function activate(): void {
    root.toggled();
  }

  implicitWidth: 36
  implicitHeight: 20
  radius: height / 2
  color: root.checked ? Colors.accent : Colors.bg2

  Behavior on color {
    ColorAnimation { duration: Theme.animFast }
  }

  // Drawn around the switch rather than on it: the track is accent-filled
  // when the switch is on, so a border sitting in that fill would be the one
  // place the keyboard cursor couldn't be seen.
  Rectangle {
    anchors.centerIn: parent
    width: parent.width + 8
    height: parent.height + 8
    radius: height / 2
    visible: root.selected
    color: "transparent"
    border.width: 2
    border.color: Colors.accent
  }

  Rectangle {
    x: root.checked ? root.width - width - 3 : 3
    anchors.verticalCenter: parent.verticalCenter
    width: 14
    height: 14
    radius: 7
    color: root.checked ? Colors.accentFg : Colors.fg

    Behavior on x {
      NumberAnimation {
        duration: Theme.animNormal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.easeStandard
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled()
  }
}
