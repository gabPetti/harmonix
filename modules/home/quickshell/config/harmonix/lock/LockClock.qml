import QtQuick
import Quickshell
import "../theme"
import "../components"

// The time, a character at a time so a new minute rolls only the digits that
// changed, with the date under it.
//
// The two have their own stages of the entrance: the time is the first thing
// on the screen and the date follows it, which is the order they are read in.
Column {
  id: root

  // 0..1 each, from LockSurface.stage.
  property real timeStage: 1
  property real dateStage: 1

  spacing: 4

  // Fires on the minute boundary rather than once a second: nothing here
  // shows seconds, and a clock that woke the whole screen every second would
  // be the most expensive thing on a locked laptop.
  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Row {
    id: digits

    anchors.horizontalCenter: parent.horizontalCenter
    opacity: root.timeStage
    // A transform rather than a y: this is inside a Column, which owns the
    // y of everything in it. Every block of the entrance rises by the same
    // distance, so they all arrive travelling together.
    transform: Translate { y: Theme.lockRise * (1 - root.timeStage) }

    readonly property string time: Qt.formatDateTime(clock.date, "HH:mm")

    Repeater {
      model: digits.time.length

      FlipText {
        required property int index

        text: digits.time.charAt(index)
        pixelSize: Theme.lockClockSize
        weight: Font.DemiBold
        // The colon carries no information once the digits either side of it
        // are legible, so it is dropped back far enough to read as a
        // separator rather than as a third number.
        color: text === ":" ? Qt.alpha(Colors.fg, 0.35) : Colors.fg
      }
    }
  }

  StyledText {
    anchors.horizontalCenter: parent.horizontalCenter
    text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
    color: Colors.fgDim
    font.pixelSize: Theme.lockDateSize
    font.weight: Font.Medium
    opacity: root.dateStage
    transform: Translate { y: Theme.lockRise * (1 - root.dateStage) }
  }
}
