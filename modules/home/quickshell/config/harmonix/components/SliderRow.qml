import QtQuick
import QtQuick.Layouts
import "../theme"

// A control, a slider and a readout: the row every popup that adjusts a level
// is built from. The leading item is a mute button where there is something
// to mute and a plain glyph where there isn't.
RowLayout {
  id: root

  property string icon: ""
  property real value: 0
  property string label: ""
  // Dims the fill and lights the button, for a muted channel.
  property bool muted: false
  property bool toggleable: false
  property real step: 0.05

  // One stop for the keyboard, not three: h and l move the level, Enter works
  // the button beside it. Both halves stay clickable -- this is only about
  // what KeyNav walks (components/KeyNav.qml).
  readonly property bool navigable: true
  property bool selected: false

  signal moved(real target)
  signal toggled

  function activate(): void {
    if (root.toggleable)
      root.toggled();
  }

  function adjust(direction: int): void {
    root.moved(Math.max(0, Math.min(1, root.value + direction * root.step)));
  }

  Layout.fillWidth: true
  spacing: Theme.popupGap

  IconButton {
    visible: root.toggleable
    selected: root.selected
    icon: root.icon
    active: root.muted
    accentColor: Colors.critical
    size: 30
    onClicked: root.toggled()
  }

  StyledText {
    visible: !root.toggleable
    text: root.icon
    color: root.selected ? Colors.accent : Colors.fgDim
    font.pixelSize: Theme.iconSize
  }

  ValueSlider {
    selected: root.selected
    value: root.value
    step: root.step
    fillColor: root.muted ? Colors.outline : Colors.accent
    onMoved: target => root.moved(target)
  }

  StyledText {
    Layout.minimumWidth: 38
    horizontalAlignment: Text.AlignRight
    text: root.label
    color: Colors.fgDim
  }
}
