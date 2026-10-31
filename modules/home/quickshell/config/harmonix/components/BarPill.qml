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
  // Overridable because a pill whose content is a shape rather than text
  // carries its own optical margin and needs less.
  property int padding: Theme.pillPadding
  // 0..1 draws a level rule under the content; negative disables it.
  property real fill: -1

  readonly property bool hovered: hover.hovered

  signal clicked(var event)
  signal rightClicked(var event)
  signal middleClicked(var event)
  // +1 scrolling up/away, -1 scrolling down/toward.
  signal scrolled(int direction)

  Layout.alignment: Qt.AlignVCenter
  implicitWidth: row.implicitWidth + root.padding * 2
  implicitHeight: Theme.pillHeight
  radius: height / 2

  color: !root.interactive ? "transparent"
    : root.active ? Colors.accentSoft
    : root.hovered ? Colors.hoverSoft
    : "transparent"

  Behavior on color {
    ColorAnimation { duration: Theme.animFast }
  }

  // Level readout -- volume, brightness, charge. A rule under the content
  // rather than a filled capsule behind it: with the group backgrounds gone
  // a full-height fill was the only solid blob left in the bar, and it read
  // as one. Inset to the content's own width so it tracks the text instead
  // of the pill's hover area.
  Rectangle {
    visible: root.fill >= 0
    anchors {
      left: parent.left
      leftMargin: root.padding
      bottom: parent.bottom
      // Below the pill rather than inside it. At the current icon size a
      // glyph's descender reaches the pill's bottom edge, so a rule drawn
      // inside would run into it; the gutter the pill is already inset by
      // (pillInset) is free space, and sitting there reads as an indicator
      // under the pill instead of an underline through the icon.
      bottomMargin: -(Theme.levelGap + Theme.levelHeight)
    }
    width: (parent.width - root.padding * 2) * Math.max(0, Math.min(1, root.fill))
    height: Theme.levelHeight
    radius: height / 2
    color: Colors.accent
    opacity: 0.7

    Behavior on width {
      NumberAnimation {
        duration: Theme.animNormal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.easeStandard
      }
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
