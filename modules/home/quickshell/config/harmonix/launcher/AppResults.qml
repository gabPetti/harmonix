import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../theme"
import "../components"

ListView {
  id: root

  property var results: []
  property int selection: 0

  signal picked(int index)

  model: root.results
  currentIndex: root.selection
  clip: true
  spacing: 2
  boundsBehavior: Flickable.StopAtBounds
  cacheBuffer: 400

  onCurrentIndexChanged: root.positionViewAtIndex(root.currentIndex, ListView.Contain)

  delegate: Rectangle {
    id: entry

    required property var modelData
    required property int index

    width: root.width
    height: 52
    radius: 12
    color: entry.index === root.selection ? Colors.accentSoft
      : area.containsMouse ? Colors.hoverSoft
      : "transparent"

    Behavior on color {
      ColorAnimation { duration: Theme.animFast }
    }

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.rightMargin: 12
      spacing: 12

      // Checked lookup returns "" instead of warning for entries whose icon
      // isn't in the theme; those fall back to a glyph.
      Item {
        implicitWidth: 32
        implicitHeight: 32

        StyledText {
          anchors.centerIn: parent
          visible: appIcon.status !== Image.Ready
          text: Icons.apps
          color: Colors.fgDim
          font.pixelSize: 22
        }

        IconImage {
          id: appIcon
          anchors.fill: parent
          source: entry.modelData ? Quickshell.iconPath(entry.modelData.icon, true) : ""
          asynchronous: true
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        StyledText {
          Layout.fillWidth: true
          text: entry.modelData?.name ?? ""
          color: entry.index === root.selection ? Colors.accent : Colors.fg
          font.pixelSize: Theme.fontSize + 1
          elide: Text.ElideRight
        }

        StyledText {
          Layout.fillWidth: true
          visible: text !== ""
          text: entry.modelData?.genericName || entry.modelData?.comment || ""
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
          elide: Text.ElideRight
        }
      }
    }

    MouseArea {
      id: area
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.picked(entry.index)
    }
  }
}
