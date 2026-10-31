pragma Singleton
import QtQuick
import Quickshell.Hyprland

// Tracks which bar popup is open. Keeping it here rather than in each widget
// means opening one popup closes any other, across every monitor.
QtObject {
  id: root

  property var owner: null

  // Every panel that gave itself an id, so a keybind can ask for one by name
  // (shell.qml exposes this over IPC). The bar is instantiated once per
  // monitor, so each id appears as many times as there are screens -- which
  // is why the lookup asks Hyprland which one has focus rather than taking
  // the first match.
  property var registry: []

  function register(popup) {
    root.registry.push(popup);
  }

  function unregister(popup) {
    const at = root.registry.indexOf(popup);
    if (at !== -1)
      root.registry.splice(at, 1);
  }

  function find(id) {
    const matches = root.registry.filter(popup => popup.panelId === id);
    const focused = Hyprland.focusedMonitor?.name ?? "";
    return matches.find(popup => popup.screen?.name === focused) ?? matches[0] ?? null;
  }

  function open(popup) {
    root.owner = popup;
  }

  function close() {
    root.owner = null;
  }

  function toggle(popup) {
    root.owner = root.owner === popup ? null : popup;
  }

  function toggleNamed(id) {
    const popup = root.find(id);
    if (popup)
      root.toggle(popup);
  }
}
