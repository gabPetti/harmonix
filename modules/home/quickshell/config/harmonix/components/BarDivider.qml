import QtQuick
import QtQuick.Layouts
import "../theme"

// Hairline between two sections of the flat bar. Deliberately shorter than
// the bar: a rule run edge to edge would read as cutting the bar in two
// rather than as grouping what sits either side of it.
//
// `before`/`after` are the sections it separates. A bar section can collapse
// on its own (an empty tray, no media player), and a divider left standing
// next to nothing is worse than no divider at all -- so it tracks them.
Rectangle {
  id: root

  property Item before: null
  property Item after: null

  Layout.alignment: Qt.AlignVCenter
  implicitWidth: 1
  implicitHeight: Theme.dividerHeight
  color: Colors.outlineSoft
  visible: (!root.before || root.before.visible) && (!root.after || root.after.visible)
}
