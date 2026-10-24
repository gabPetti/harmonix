import QtQuick
import QtQuick.Layouts
import "../theme"

// Small uppercase heading that separates groups inside a popup.
Text {
  Layout.fillWidth: true
  color: Colors.fgDim
  font.family: Theme.font
  font.pixelSize: Theme.fontSizeSmall
  font.capitalization: Font.AllUppercase
  font.letterSpacing: 0.8
  elide: Text.ElideRight
}
