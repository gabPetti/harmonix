import QtQuick
import QtQuick.Layouts
import "../theme"

// Horizontal 0..1 slider. It never writes `value` itself: the owner reacts to
// `moved` and feeds the new value back, so the displayed position always
// reflects the real system state rather than the drag.
Item {
  id: root

  property real value: 0
  property color fillColor: Colors.accent
  property real step: 0.05

  signal moved(real target)

  Layout.fillWidth: true
  implicitHeight: 18

  Rectangle {
    id: track
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width
    height: 6
    radius: 3
    color: Colors.bg2

    Rectangle {
      width: track.width * Math.max(0, Math.min(1, root.value))
      height: parent.height
      radius: parent.radius
      color: root.fillColor

      Behavior on width {
        enabled: !area.pressed
        NumberAnimation { duration: Theme.animFast }
      }
    }
  }

  Rectangle {
    x: Math.max(0, Math.min(root.width - width, track.width * root.value - width / 2))
    anchors.verticalCenter: parent.verticalCenter
    width: 12
    height: 12
    radius: 6
    color: root.fillColor
    scale: area.containsMouse || area.pressed ? 1.3 : 1

    Behavior on scale {
      NumberAnimation { duration: Theme.animFast }
    }
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onPressed: event => root._seek(event.x)
    onPositionChanged: event => {
      if (area.pressed) root._seek(event.x);
    }
    onWheel: event => {
      if (event.angleDelta.y === 0) return;
      const delta = event.angleDelta.y > 0 ? root.step : -root.step;
      root.moved(Math.max(0, Math.min(1, root.value + delta)));
    }
  }

  function _seek(x) {
    root.moved(Math.max(0, Math.min(1, x / root.width)));
  }
}
