import QtQuick
import "../theme"
import "../components"
import "../services"

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
}
