import QtQuick
import "../theme"
import "../components"
import "../launcher"
import "../services"

// The pill the launcher hangs off. The panel lives here rather than in
// shell.qml so it drops from this pill on this monitor, the way every other
// bar panel is anchored to the widget that opens it.
BarPill {
  id: root

  active: LauncherState.opened
  tooltipText: "Applications  ·  right-click for wallpapers"

  onClicked: LauncherState.toggle(LauncherState.modeApps)
  onRightClicked: LauncherState.toggle(LauncherState.modeWallpapers)

  StyledText {
    text: Icons.distro
    color: root.active || root.hovered ? Colors.accent : Colors.fg
    font.pixelSize: Theme.iconSizeLarge
  }

  LauncherPanel {
    anchorItem: root
  }
}
