import QtQuick
import "../theme"

// A small pill-shaped label that is either on or off: the launcher's two
// mode tabs, the translation panel's target languages. Narrow enough that a
// row of them reads as one control rather than as a list.
Rectangle {
  id: root

  property string label: ""
  property bool active: false

  signal clicked

  implicitWidth: text.implicitWidth + 18
  implicitHeight: 24
  radius: height / 2
  color: root.active ? Colors.accent : area.containsMouse ? Colors.hoverSoft : Qt.alpha(Colors.bg1, 0.6)

  Behavior on color {
    ColorAnimation { duration: Theme.animFast }
  }

  StyledText {
    id: text
    anchors.centerIn: parent
    text: root.label
    color: root.active ? Colors.accentFg : Colors.fgDim
    font.pixelSize: Theme.fontSizeSmall
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
