import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../theme"
import "../services"

// Dropdown anchored under a bar pill. Children are placed in a fixed-width
// ColumnLayout, so content should use `Layout.fillWidth` rather than anchoring
// to the popup: the popup's height is derived from the column, and anchoring
// back to it would be a binding loop.
//
// Visibility lives in the Panels singleton, which is what makes opening one
// popup close whichever one was already open.
PopupWindow {
  id: root

  property Item anchorItem: null
  property int contentWidth: Theme.popupWidth
  property int padding: Theme.popupPadding

  default property alias content: column.data

  anchor {
    item: root.anchorItem
    rect.y: root.anchorItem ? root.anchorItem.height + Theme.popupGap : 0
    edges: Edges.Bottom
    gravity: Edges.Bottom
    adjustment: PopupAdjustment.SlideX
  }

  implicitWidth: root.contentWidth + root.padding * 2
  implicitHeight: column.implicitHeight + root.padding * 2
  color: "transparent"
  visible: Panels.owner === root

  function open() {
    Panels.open(root);
  }

  function close() {
    Panels.close();
  }

  function toggle() {
    Panels.toggle(root);
  }

  HyprlandFocusGrab {
    active: root.visible
    windows: [root]
    // Another pill may already have taken ownership by the time the grab on
    // this one clears; don't close the popup that replaced us.
    onCleared: {
      if (Panels.owner === root) root.close();
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.popupRadius
    color: Colors.bg0
    border.width: 1
    border.color: Colors.outlineSoft
  }

  ColumnLayout {
    id: column
    x: root.padding
    y: root.padding
    width: root.contentWidth
    spacing: 8
  }
}
