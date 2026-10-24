import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../theme"
import "../components"
import "../services"

// Thumbnail grid for picking a wallpaper. Replaces piping `find` into
// `rofi -dmenu`, which could only ever show filenames.
GridView {
  id: root

  property var results: []
  property int selection: 0
  property int columns: 3

  signal picked(int index)

  model: root.results
  currentIndex: root.selection
  cellWidth: Math.floor(root.width / root.columns)
  cellHeight: Math.round(root.cellWidth * 0.6) + 22
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  cacheBuffer: 600

  onCurrentIndexChanged: root.positionViewAtIndex(root.currentIndex, GridView.Contain)

  delegate: Item {
    id: cell

    required property var modelData
    required property int index

    readonly property bool selected: cell.index === root.selection
    readonly property bool isCurrent: cell.modelData === Wallpapers.current

    width: root.cellWidth
    height: root.cellHeight

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 5
      spacing: 3

      // A plain Rectangle clips to its bounding box, so the thumbnail's square
      // corners sit outside the rounded frame. ClippingRectangle clips to the
      // rounded border instead, and insets content by the border width itself.
      ClippingRectangle {
        id: frame

        // border is a value type and can't take a Behavior directly, so the
        // animation lives on a plain property that feeds it.
        property color edge: cell.selected ? Colors.accent
          : area.containsMouse ? Colors.outline
          : "transparent"

        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 12
        color: Colors.bg1
        border.width: 2
        border.color: frame.edge

        Behavior on edge {
          ColorAnimation { duration: Theme.animFast }
        }

        Image {
          anchors.fill: parent
          source: cell.modelData ? `file://${cell.modelData}` : ""
          fillMode: Image.PreserveAspectCrop
          sourceSize.width: 320
          asynchronous: true
          cache: true
        }

        Rectangle {
          anchors.top: parent.top
          anchors.right: parent.right
          anchors.margins: 6
          visible: cell.isCurrent
          width: 22
          height: 22
          radius: 11
          color: Colors.accent

          StyledText {
            anchors.centerIn: parent
            text: Icons.check
            color: Colors.accentFg
            font.pixelSize: Theme.fontSizeSmall
          }
        }
      }

      StyledText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: cell.modelData ? Wallpapers.name(cell.modelData) : ""
        color: cell.selected ? Colors.accent : Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
        elide: Text.ElideRight
      }
    }

    MouseArea {
      id: area
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.picked(cell.index)
    }
  }
}
