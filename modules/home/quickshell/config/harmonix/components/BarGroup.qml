import QtQuick
import QtQuick.Layouts
import "../theme"

// A rounded container holding a run of pills. The bar has three of them
// (left/center/right) so the sections read as distinct islands.
Rectangle {
  id: root

  default property alias content: row.data
  property int spacing: Theme.pillSpacing

  implicitWidth: row.implicitWidth + Theme.groupPadding * 2
  implicitHeight: Theme.groupHeight
  radius: height / 2
  color: Qt.alpha(Colors.bg1, 0.45)
  visible: row.implicitWidth > 0

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: root.spacing
  }
}
