import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

// The launcher, as a panel dropped from the bar's distro pill: app search and
// the wallpaper grid, one pane each, switched by the chips in their header.
//
// An ordinary BarPopup, so it comes out of the bar in the same material as
// every other panel and opening it closes whichever was already open. Two
// things set it apart from the rest: it drops from the middle of the bar
// rather than from its pill, being far too wide to read as hanging off one;
// and its own hjkl walk is off, the panes wanting the keys raw -- one has a
// field to type into, the other its own meaning for h and l.
BarPopup {
  id: root

  panelId: LauncherState.panelId
  contentWidth: Theme.launcherWidth
  centered: true
  keyNav: false

  // One slot both panes fill, at a fixed height: a dropdown that resized
  // itself between a list and a grid would re-run the open animation's
  // distance on every tab switch.
  Item {
    Layout.fillWidth: true
    implicitHeight: Theme.launcherHeight

    AppLauncher {
      anchors.fill: parent
    }

    WallpaperPicker {
      anchors.fill: parent
    }
  }
}
