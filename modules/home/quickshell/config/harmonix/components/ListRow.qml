import QtQuick
import QtQuick.Layouts
import "../theme"

// One selectable entry in a popup list: glyph, title, optional second line,
// and an optional trailing label.
Rectangle {
  id: root

  property string icon: ""
  // Set when `icon` is a Material Symbols ligature rather than a Nerd Font
  // codepoint -- see UsageRing.symbol.
  property bool symbol: false
  property string title: ""
  property string subtitle: ""
  property string trailing: ""
  property bool active: false
  property bool busy: false
  property color iconColor: root.active ? Colors.accent : Colors.fgDim

  readonly property bool hovered: area.containsMouse

  // Reachable by the popup's hjkl navigation (components/BarPopup.qml), and
  // `selected` is where that navigation currently is -- drawn like a hover so
  // the keyboard cursor and the pointer read the same.
  readonly property bool navigable: true
  property bool selected: false

  // A RotationAnimation stops wherever it happens to be, which left the
  // glyph of a row that had been busy sitting at an angle.
  onBusyChanged: if (!root.busy) glyph.rotation = 0

  signal clicked
  signal rightClicked

  function activate(): void {
    root.clicked();
  }

  Layout.fillWidth: true
  implicitHeight: root.subtitle === "" ? 34 : 44
  radius: 10
  color: root.hovered || root.selected ? Colors.hoverSoft : root.active ? Colors.accentSoft : "transparent"
  border.width: root.selected ? 1 : 0
  border.color: Colors.accent

  Behavior on color {
    ColorAnimation { duration: Theme.animFast }
  }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    spacing: 10

    StyledText {
      id: glyph

      visible: root.icon !== ""
      text: root.busy ? Icons.spinner : root.icon
      color: root.iconColor
      // The spinner is a Nerd Font glyph whatever the row's own icon is.
      font.family: root.symbol && !root.busy ? Theme.symbolFont : Theme.font
      font.pixelSize: Theme.iconSize
      font.variableAxes: root.symbol && !root.busy ? ({ "FILL": 1, "opsz": Theme.iconSize }) : ({})

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
