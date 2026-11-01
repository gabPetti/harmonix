import QtQuick
import "../theme"

// Round glyph button used inside popups (media transport, power actions).
Rectangle {
  id: root

  property string icon: ""
  // Whether `icon` is a Material Symbols ligature rather than a Nerd Font
  // codepoint -- the symbol font renders the name itself.
  property bool symbol: false
  property int size: 34
  property int iconSize: Theme.iconSize
  property bool active: false
  property color accentColor: Colors.accent
  property string tooltipText: ""

  readonly property bool hovered: hover.hovered

  // See ListRow: the same two properties are what the popup's hjkl
  // navigation looks for.
  readonly property bool navigable: true
  property bool selected: false

  signal clicked

  function activate(): void {
    root.clicked();
  }

  implicitWidth: root.size
  implicitHeight: root.size
  radius: width / 2
  color: root.hovered || root.selected ? Colors.hoverSoft : root.active ? Colors.accentSoft : Qt.alpha(Colors.bg1, 0.5)
  border.width: root.selected ? 1 : 0
  border.color: Colors.accent

  Behavior on color {
    ColorAnimation { duration: Theme.animFast }
  }

  StyledText {
    anchors.centerIn: parent
    text: root.icon
    color: root.active || root.hovered ? root.accentColor : Colors.fg
    font.family: root.symbol ? Theme.symbolFont : Theme.font
    font.pixelSize: root.iconSize
    font.variableAxes: root.symbol ? ({ "FILL": 1, "opsz": root.iconSize }) : ({})
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
