import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

// One mode of the launcher dropdown, and the chrome the two modes have in
// common: a header strip ending in the mode chips, a hairline under it, a
// body, and a footer. What goes in the header and the body is the pane's own
// business -- which is why keys are handled there and not here.
//
// Both panes are built once and kept, visibility following the mode, so
// switching tabs doesn't re-read the desktop entries or the wallpaper
// directory. A hidden pane also gives up the keyboard: they are stacked on
// top of each other, and a FocusScope only passes the keys down while it has
// them itself.
FocusScope {
  id: root

  // Which LauncherState mode this pane answers to.
  property string mode: LauncherState.modeApps
  // Left-hand side of the header, before the mode chips.
  property alias headerContent: headerRow.data
  property string status: ""
  property string hint: ""

  default property alias content: body.data

  readonly property bool shown: LauncherState.opened && LauncherState.mode === root.mode

  visible: root.shown
  focus: root.shown

  ColumnLayout {
    anchors.fill: parent
    spacing: 10

    RowLayout {
      Layout.fillWidth: true
      spacing: 12

      RowLayout {
        id: headerRow

        Layout.fillWidth: true
        spacing: 12
      }

      ModeChip {
        label: "Apps"
        active: LauncherState.mode === LauncherState.modeApps
        onClicked: LauncherState.open(LauncherState.modeApps)
      }

      ModeChip {
        label: "Walls"
        active: LauncherState.mode === LauncherState.modeWallpapers
        onClicked: LauncherState.open(LauncherState.modeWallpapers)
      }
    }

    Rectangle {
      Layout.fillWidth: true
      implicitHeight: 1
      color: Colors.outlineSoft
    }

    Item {
      id: body

      Layout.fillWidth: true
      Layout.fillHeight: true
    }

    // The hint is the longest string in the shell, and a Layout item's
    // minimum width defaults to its implicit one: left unelidable it set the
    // column's minimum wider than the panel, and every fillWidth sibling --
    // the wallpaper grid among them -- was laid out at that width and spilled
    // out of the panel's left and right edges. Filling the remaining width
    // and eliding is what keeps the footer from driving the body's size.
    RowLayout {
      Layout.fillWidth: true
      spacing: 12

      StyledText {
        text: root.status
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
      }

      StyledText {
        Layout.fillWidth: true
        text: root.hint
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
      }
    }
  }
}
