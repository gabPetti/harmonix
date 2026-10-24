import QtQuick
import QtQuick.Layouts
import "../theme"

// One selectable entry in a popup list: glyph, title, optional second line,
// and an optional trailing label.
Rectangle {
  id: root

  property string icon: ""
  property string title: ""
  property string subtitle: ""
  property string trailing: ""
  property bool active: false
  property bool busy: false
  property color iconColor: root.active ? Colors.accent : Colors.fgDim

  readonly property bool hovered: area.containsMouse

  signal clicked
  signal rightClicked

  Layout.fillWidth: true
  implicitHeight: root.subtitle === "" ? 34 : 44
  radius: 10
  color: root.hovered ? Colors.hoverSoft : root.active ? Colors.accentSoft : "transparent"

  Behavior on color {
    ColorAnimation { duration: Theme.animFast }
  }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    spacing: 10

    StyledText {
      visible: root.icon !== ""
      text: root.busy ? Icons.spinner : root.icon
      color: root.iconColor
      font.pixelSize: Theme.iconSize

      RotationAnimation on rotation {
        running: root.busy
        from: 0
        to: 360
        duration: 1200
        loops: Animation.Infinite
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      StyledText {
        Layout.fillWidth: true
        text: root.title
        color: root.active ? Colors.accent : Colors.fg
        elide: Text.ElideRight
      }

      StyledText {
        Layout.fillWidth: true
        visible: root.subtitle !== ""
        text: root.subtitle
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
        elide: Text.ElideRight
      }
    }

    StyledText {
      visible: root.trailing !== ""
      text: root.trailing
      color: Colors.fgDim
      font.pixelSize: Theme.fontSizeSmall
    }
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: event => {
      if (event.button === Qt.RightButton) root.rightClicked();
      else root.clicked();
    }
  }
}
