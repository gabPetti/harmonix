import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "../theme"
import "../components"

BarPill {
  id: root

  readonly property var toplevel: Hyprland.activeToplevel
  // appId comes straight off the wl_toplevel, which is populated before
  // Hyprland's IPC object is; fall back to the IPC class for anything odd.
  readonly property string appClass: root.toplevel?.wayland?.appId || root.toplevel?.lastIpcObject?.class || ""
  // heuristicLookup matches a window class against .desktop files, which is
  // what lets the bar show the app's real icon and name.
  readonly property var entry: root.appClass === "" ? null : DesktopEntries.heuristicLookup(root.appClass)
  readonly property string label: root.toplevel?.title || root.entry?.name || "Desktop"

  interactive: false
  tooltipText: root.label

  IconImage {
    visible: source !== ""
    source: root.entry ? Quickshell.iconPath(root.entry.icon, true) : ""
    implicitSize: Theme.iconSize + 3
    asynchronous: true
  }

  StyledText {
    Layout.maximumWidth: 240
    text: root.label
    color: root.toplevel ? Colors.fg : Colors.fgDim
    elide: Text.ElideRight
  }
}
