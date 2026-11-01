import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

// The spectrum Cava reads, drawn as a row of capsules growing from a common
// baseline. Sized from Theme alone, so it occupies the same width whether
// anything is playing or not -- the bar must not reflow on every pause.
Item {
  id: root

  property color color: Colors.accent

  // Levels are already smoothed by cava, so the bars follow them frame for
  // frame; a Behavior on top of that would only add lag at 60fps.
  readonly property var levels: Cava.levels

  Layout.alignment: Qt.AlignVCenter
  implicitWidth: Theme.visualizerBars * Theme.visualizerBarWidth
    + (Theme.visualizerBars - 1) * Theme.visualizerBarSpacing
  implicitHeight: Theme.visualizerHeight

  Row {
    anchors.fill: parent
    spacing: Theme.visualizerBarSpacing

    Repeater {
      model: Theme.visualizerBars

      delegate: Rectangle {
        required property int index

        // Never zero: silence reads as an even row of dots sitting on the
        // baseline, which is a resting visualizer rather than a gap in the
        // pill where one used to be.
        readonly property real level: root.levels[index] ?? 0

        anchors.bottom: parent.bottom
        width: Theme.visualizerBarWidth
        height: Theme.visualizerBarMin
          + (Theme.visualizerHeight - Theme.visualizerBarMin) * level
        radius: width / 2
        color: root.color
      }
    }
  }
}
