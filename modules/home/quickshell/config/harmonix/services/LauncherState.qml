pragma Singleton
import QtQuick

// Which half of the launcher is showing, and the one place that opens and
// closes it. The launcher is an ordinary bar panel (launcher/LauncherPanel.qml
// hanging off bar/LauncherButton.qml), so the open state itself lives in
// Panels like every other panel's -- this only chooses the mode and finds the
// panel on the focused monitor, so the bar button, a keybind over IPC and the
// mode chips all drive the same thing.
QtObject {
  id: root

  readonly property string modeApps: "apps"
  readonly property string modeWallpapers: "wallpapers"

  // What the panel registers itself under, so `panels toggle launcher` and
  // the launcher's own IPC reach the same window.
  readonly property string panelId: "launcher"

  readonly property bool opened: Panels.owner?.panelId === root.panelId

  property string mode: root.modeApps

  function open(mode) {
    root.mode = mode || root.modeApps;
    const panel = Panels.find(root.panelId);
    if (panel)
      Panels.open(panel);
  }

  function close() {
    if (root.opened)
      Panels.close();
  }

  function toggle(mode) {
    const next = mode || root.modeApps;
    // Already open on the other mode: switch to it rather than closing, so
    // the two keybinds behave like tabs once the panel is down.
    if (root.opened && root.mode === next) root.close();
    else root.open(next);
  }
}
