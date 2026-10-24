pragma Singleton
import QtQuick

// Tracks which bar popup is open. Keeping it here rather than in each widget
// means opening one popup closes any other, across every monitor.
QtObject {
  id: root

  property var owner: null

  function open(popup) {
    root.owner = popup;
  }

  function close() {
    root.owner = null;
  }

  function toggle(popup) {
    root.owner = root.owner === popup ? null : popup;
  }
}
