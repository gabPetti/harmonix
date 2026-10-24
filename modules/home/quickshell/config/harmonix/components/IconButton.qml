import QtQuick
import QtQuick.Layouts
import "../theme"

// Round glyph button used inside popups (media transport, power actions).
Rectangle {
  id: root

  property string icon: ""
  property int size: 34
  property int iconSize: Theme.iconSize
  property bool active: false
  property color accentColor: Colors.accent
  property string tooltipText: ""

  readonly property bool hovered: hover.hovered

  signal clicked

  implicitWidth: root.size
  implicitHeight: root.size
  radius: width / 2
  color: root.hovered ? Colors.hoverSoft : root.active ? Colors.accentSoft : Qt.alpha(Colors.bg1, 0.5)

  Behavior on color {
    ColorAnimation { duration: Theme.animFast }
  }

  StyledText {
    anchors.centerIn: parent
    text: root.icon
    color: root.active || root.hovered ? root.accentColor : Colors.fg
    font.pixelSize: root.iconSize
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.clicked()
  }

  Tooltip {
    anchorItem: root
    text: root.tooltipText
    shown: root.hovered
  }
}
