import QtQuick
import QtQuick.Layouts
import "../theme"

// A run of pills that belongs together. Purely a grouping device: the bar is
// one flat surface, so a section reads by the air around it and the hairline
// beside it rather than by a filled container of its own. The only fill left
// anywhere in the bar is a pill's hover and active highlight.
//
// Collapses to nothing when it has no visible children, which is what lets
// the dividers next to it (BarDivider) know to disappear too.
Item {
  id: root

  default property alias content: row.data
  property int spacing: Theme.pillSpacing
  // Lets the bar retire a section that no longer fits, on top of the
  // automatic collapse below. Expendable sections yield; the rest don't.
  property bool shown: true

  Layout.alignment: Qt.AlignVCenter
  implicitWidth: row.implicitWidth
  implicitHeight: Theme.groupHeight
  visible: root.shown && row.implicitWidth > 0

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: root.spacing
  }
}
