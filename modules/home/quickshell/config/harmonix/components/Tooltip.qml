import QtQuick
import Quickshell
import "../theme"

// Hover label for bar pills. Shown after a short delay so that sweeping the
// cursor across the bar doesn't flash a tooltip for every pill on the way.
PopupWindow {
  id: root

  property Item anchorItem: null
  property string text: ""
  property bool shown: false

  anchor {
    item: root.anchorItem
    rect.y: root.anchorItem ? root.anchorItem.height + Theme.popupGap : 0
    edges: Edges.Bottom
    gravity: Edges.Bottom
    adjustment: PopupAdjustment.SlideX
  }

  implicitWidth: label.implicitWidth + 20
  implicitHeight: label.implicitHeight + 12
  color: "transparent"
  visible: false

  onShownChanged: {
    if (root.shown) delay.restart();
    else {
      delay.stop();
      root.visible = false;
    }
  }

  Timer {
    id: delay
    interval: 420
    onTriggered: root.visible = root.shown && root.text !== ""
  }

  Rectangle {
    anchors.fill: parent
    radius: 10
    color: Colors.bg0
    border.width: 1
    border.color: Colors.outlineSoft

    StyledText {
      id: label
      anchors.centerIn: parent
      text: root.text
      font.pixelSize: Theme.fontSizeSmall
    }
  }
}
