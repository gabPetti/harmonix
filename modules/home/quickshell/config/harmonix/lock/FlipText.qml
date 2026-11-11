import QtQuick
import "../theme"

// One character that rolls over when it changes: the outgoing glyph rises out
// of the top while the incoming one comes up from the bottom, both inside a
// clip the height of a line.
//
// Used a character at a time by LockClock, so a new minute only moves the
// digits that actually changed -- rolling "09:59" to "10:00" as one block
// would animate the colon and every digit that stayed put.
Item {
  id: root

  property string text: ""
  property int pixelSize: Theme.fontSize
  property int weight: Font.Normal
  property color color: Colors.fg

  // What is actually drawn, which lags `text` by the length of one roll:
  // the handler below moves the old glyph aside before letting the new one
  // through, and the two Texts read from here and from `previous`.
  property string shown: ""

  implicitWidth: metrics.advanceWidth
  // The line box rather than the glyph's own height, so a row of these sits
  // on one baseline whatever characters are in them.
  implicitHeight: metrics.height
  clip: true

  // The first assignment comes through this handler too, with nothing to roll
  // out -- which is how a digit arrives from below on the way in rather than
  // being there from the start.
  onTextChanged: {
    if (root.text === root.shown) return;

    previous.text = root.shown;
    root.shown = root.text;
    roll.restart();
  }

  TextMetrics {
    id: metrics

    font.family: Theme.font
    font.pixelSize: root.pixelSize
    font.weight: root.weight
    // Measured against a digit, not against the character being shown: the
    // font is not monospaced on every weight, and a width that tracked the
    // glyph would shuffle the whole clock along on every minute.
    text: root.text === ":" ? ":" : "0"
  }

  Text {
    id: current

    width: parent.width
    text: root.shown
    color: root.color
    font.family: Theme.font
    font.pixelSize: root.pixelSize
    font.weight: root.weight
    horizontalAlignment: Text.AlignHCenter
  }

  Text {
    id: previous

    width: parent.width
    color: root.color
    font.family: Theme.font
    font.pixelSize: root.pixelSize
    font.weight: root.weight
    horizontalAlignment: Text.AlignHCenter
    opacity: 0
  }

  ParallelAnimation {
    id: roll

    NumberAnimation {
      target: previous
      property: "y"
      from: 0
      to: -root.height
      duration: Theme.animEnter
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.easeEnter
    }

    NumberAnimation {
      target: previous
      property: "opacity"
      from: 1
      to: 0
      duration: Theme.animEnter
    }

    NumberAnimation {
      target: current
      property: "y"
      from: root.height
      to: 0
      duration: Theme.animEnter
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.easeEnter
    }

    NumberAnimation {
      target: current
      property: "opacity"
      from: 0
      to: 1
      duration: Theme.animEnter
    }
  }
}
