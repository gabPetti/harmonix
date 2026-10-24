import QtQuick
import "../theme"

// Text with the shell's font defaults already applied.
Text {
  color: Colors.fg
  font.family: Theme.font
  font.pixelSize: Theme.fontSize
  verticalAlignment: Text.AlignVCenter
  textFormat: Text.PlainText
}
