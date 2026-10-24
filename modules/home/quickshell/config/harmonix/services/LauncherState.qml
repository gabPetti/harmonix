pragma Singleton
import QtQuick

// Shared launcher state, so the bar button, a keybind over IPC, and the
// launcher window itself all drive the same thing.
QtObject {
  id: root

  readonly property string modeApps: "apps"
  readonly property string modeWallpapers: "wallpapers"

  property bool opened: false
  property string mode: root.modeApps

  function open(mode) {
    root.mode = mode || root.modeApps;
    root.opened = true;
  }

  function close() {
    root.opened = false;
  }

  function toggle(mode) {
    const next = mode || root.modeApps;
    if (root.opened && root.mode === next) root.close();
    else root.open(next);
  }
}
