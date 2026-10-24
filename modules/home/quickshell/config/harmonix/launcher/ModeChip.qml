import QtQuick
import "../theme"
import "../components"

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
