import QtQuick
import "../theme"
import "../components"

// Shared shape for the CPU/RAM/disk readouts: a dial with the glyph knocked
// out of it, and the percentage beside it. The load lives in the dial, so
// unlike the other pills this one draws no background fill and no unit -- the
// three of them sit side by side and should read as one instrument cluster
// rather than three labelled rows.
BarPill {
  id: root

  property string icon: ""
  // Set when `icon` is a Material Symbols ligature -- see UsageRing.symbol.
  property bool symbol: false
  // A percentage, 0..100, matching what SystemUsage reports.
  property real value: 0

  // The dial is a solid area, not a glyph, so it carries far more weight than
  // the icons around it -- the accent keeps it from shouting the way full
  // foreground would, and leaves the warning tones somewhere to escalate to.
  readonly property color valueColor: root.value >= 90 ? Colors.critical
    : root.value >= 75 ? Colors.warning
    : Colors.accent

  // The dial is already inset by its own rim, so the text padding the other
  // pills use would leave these looking adrift in their group.
  padding: 6
  spacing: 4

  UsageRing {
    value: root.value / 100
    icon: root.icon
    symbol: root.symbol
    color: root.valueColor
  }

  PercentLabel {
    value: Math.round(root.value)
    suffix: ""
    font.pixelSize: Theme.fontSizeSmall
  }
}
