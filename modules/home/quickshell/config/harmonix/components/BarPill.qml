import QtQuick
import QtQuick.Layouts
import "../theme"

// The hoverable unit the bar is built from: a rounded, transparent-by-default
// container whose children are laid out in a row. Declared children land in
// the row, so a widget is usually just `BarPill { StyledText { ... } }`.
Rectangle {
  id: root

  default property alias content: row.data
  property string tooltipText: ""
  property bool active: false
  property bool interactive: true
  property int spacing: Theme.contentSpacing
  // 0..1 draws a progress fill behind the content; negative disables it.
  property real fill: -1

  readonly property bool hovered: hover.hovered

  signal clicked(var event)
  signal rightClicked(var event)
  signal middleClicked(var event)
  // +1 scrolling up/away, -1 scrolling down/toward.
  signal scrolled(int direction)

  Layout.alignment: Qt.AlignVCenter
  implicitWidth: row.implicitWidth + Theme.pillPadding * 2
  implicitHeight: Theme.pillHeight
  radius: height / 2
  clip: root.fill >= 0

  color: !root.interactive ? "transparent"
    : root.active ? Colors.accentSoft
    : root.hovered ? Colors.hoverSoft
    : "transparent"

  Behavior on color {
    ColorAnimation { duration: Theme.animFast }
  }

  Rectangle {
    visible: root.fill >= 0
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
    width: parent.width * Math.max(0, Math.min(1, root.fill))
    radius: parent.radius
    color: Colors.fillSoft

    Behavior on width {
      NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }
  }

  // A layout rather than a Row so pill contents are vertically centred and
  // hidden children collapse on their own.
  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: root.spacing
  }

  // Always tracking, even on non-interactive pills, so they can still carry a
  // tooltip; only the cursor and the highlight follow `interactive`.
  HoverHandler {
    id: hover
    cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.interactive
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    onClicked: event => {
      if (event.button === Qt.RightButton) root.rightClicked(event);
      else if (event.button === Qt.MiddleButton) root.middleClicked(event);
      else root.clicked(event);
    }
    onWheel: event => {
      if (event.angleDelta.y !== 0) root.scrolled(event.angleDelta.y > 0 ? 1 : -1);
    }
  }

  Tooltip {
    anchorItem: root
    text: root.tooltipText
    shown: root.hovered
  }
}
