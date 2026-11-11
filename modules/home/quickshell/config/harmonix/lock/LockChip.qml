import QtQuick
import "../theme"
import "../components"

// A glyph and a label in a glass pill: the readouts in the lock screen's
// corners and the warnings under its field are all one of these.
//
// Not components/Chip, which is a tab -- it is sized for a bar panel, has no
// glyph, and carries an on/off state this has no use for. The two look alike
// because they are the same shape at different scales, not because one could
// stand in for the other.
Rectangle {
  id: root

  property string icon: ""
  // Whether `icon` is a Material Symbols ligature rather than a Nerd Font
  // codepoint -- the symbol font renders the name itself.
  property bool symbol: false
  property string label: ""
  // What the glyph is drawn in, which is also what the label follows at a
  // lower weight: a chip that has something to warn about colours as a whole
  // rather than lighting up only its icon.
  property color tone: Colors.fg

  implicitWidth: row.implicitWidth + Theme.pillPadding * 2
  implicitHeight: Theme.pillHeight
  radius: height / 2
  // The same fill and alpha as the bar and its panels, so the corners read as
  // the shell's own material with the wallpaper's tone coming through from
  // the blur behind them.
  color: Qt.alpha(Colors.bg0, Theme.barOpacity)

  Row {
    id: row

    anchors.centerIn: parent
    spacing: Theme.contentSpacing

    StyledText {
      anchors.verticalCenter: parent.verticalCenter
      text: root.icon
      color: root.tone
      font.family: root.symbol ? Theme.symbolFont : Theme.font
      font.pixelSize: Theme.iconSize
      font.variableAxes: root.symbol ? ({ "FILL": 1, "opsz": Theme.iconSize }) : ({})
    }

    StyledText {
      anchors.verticalCenter: parent.verticalCenter
      visible: root.label !== ""
      text: root.label
      color: root.tone === Colors.fg ? Colors.fgDim : root.tone
      font.pixelSize: Theme.fontSizeSmall
    }
  }
}
