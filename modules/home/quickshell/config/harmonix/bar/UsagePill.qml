import QtQuick
import "../theme"
import "../components"

// Shared shape for the CPU/RAM readouts: glyph, percentage, and a fill behind
// the pill tracking the load.
BarPill {
  id: root

  property string icon: ""
  property real value: 0

  readonly property color valueColor: root.value >= 90 ? Colors.critical
    : root.value >= 75 ? Colors.warning
    : Colors.fg

  fill: root.value / 100

  StyledText {
    text: root.icon
    color: root.valueColor
    font.pixelSize: Theme.iconSize
  }

  PercentLabel {
    value: Math.round(root.value)
    color: root.valueColor
  }
}
