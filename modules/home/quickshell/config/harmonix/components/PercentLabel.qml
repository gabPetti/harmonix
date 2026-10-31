import QtQuick
import QtQuick.Layouts
import "../theme"

// Percentage readout pinned to the width of the widest value it can show, so
// a pill doesn't resize as the number crosses 9 -> 10 -> 100 and its glyph
// stays a fixed distance from the number.
StyledText {
  id: root

  property int value: 0
  // Droppable, because a reading that already sits inside a dial doesn't need
  // a unit spelled out next to it.
  property string suffix: "%"

  Layout.preferredWidth: metrics.width
  text: `${root.value}${root.suffix}`

  TextMetrics {
    id: metrics
    font: root.font
    text: `100${root.suffix}`
  }
}
