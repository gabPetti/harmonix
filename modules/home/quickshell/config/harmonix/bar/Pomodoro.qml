import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

// The focus timer in the bar: the clock itself, and a panel holding the
// transport and the two phase lengths.
//
// The pill is always there, running or not. It is the handle the panel hangs
// off (SUPER+ALT+H opens it by panelId), and a timer that only appears once
// it is already counting is one you can't start without hunting for it.
BarPill {
  id: root

  active: popup.visible
  // The elapsed rule under the pill, same indicator the volume and battery
  // pills use. Hidden on an untouched phase: a rule pinned at zero reads as
  // a flat battery rather than as a timer waiting to be started.
  fill: Pomodoro.running || Pomodoro.remaining < Pomodoro.phaseSeconds ? Pomodoro.progress : -1

  tooltipText: `${Pomodoro.phaseName} · ${Pomodoro.running ? "running" : "paused"}\n${Pomodoro.label} of ${Pomodoro.minutesFor(Pomodoro.phase)}m`

  onClicked: popup.toggle()
  onMiddleClicked: Pomodoro.toggle()
  onScrolled: direction => Pomodoro.setMinutes(Pomodoro.phase, Pomodoro.minutesFor(Pomodoro.phase) + direction)

  // Which phase this is, as a colour rather than a second glyph: the two are
  // never on at once, and the bar has no room for a word. The pill drops to
  // fgDim while the clock is stopped; the panel keeps the phase colour,
  // having room to say what it is.
  readonly property color phaseAccent: Pomodoro.phase === Pomodoro.phaseWork ? Colors.accent : Colors.warning
  readonly property color phaseColor: Pomodoro.running ? root.phaseAccent : Colors.fgDim

  StyledText {
    text: Icons.timerSymbol
    color: root.phaseColor
    font.family: Theme.symbolFont
    font.pixelSize: Theme.iconSize
    font.variableAxes: ({ "FILL": Pomodoro.running ? 1 : 0, "opsz": Theme.iconSize })

    Behavior on color {
      ColorAnimation { duration: Theme.animNormal }
    }
  }

  StyledText {
    text: Pomodoro.label
    color: Pomodoro.running ? Colors.fg : Colors.fgDim
  }

  BarPopup {
    id: popup

    anchorItem: root
    panelId: "pomodoro"
    contentWidth: 320
    // h and l belong to the phase lengths while the walk is on one; with the
    // selection on a transport button they step the current phase instead.
    fallbackAdjust: direction => Pomodoro.setMinutes(Pomodoro.phase, Pomodoro.minutesFor(Pomodoro.phase) + direction)

    SectionLabel {
      text: Pomodoro.phaseName
    }

    // The readout, big enough to be the thing you see when the panel opens.
    StyledText {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      text: Pomodoro.label
      color: root.phaseAccent
      font.pixelSize: Theme.pomodoroReadout
    }

    // Elapsed, as a plain track: nothing here is draggable, because seeking
    // a pomodoro is just setting a different length.
    Rectangle {
      Layout.fillWidth: true
      implicitHeight: Theme.pomodoroTrack
      radius: height / 2
      color: Colors.outlineSoft

      Rectangle {
        width: Math.round(parent.width * Math.max(0, Math.min(1, Pomodoro.progress)))
        height: parent.height
        radius: height / 2
        color: root.phaseAccent

        Behavior on width {
          NumberAnimation { duration: Theme.animFast }
        }
      }
    }

    RowLayout {
      Layout.fillWidth: true
      Layout.topMargin: 2
      spacing: Theme.popupGap

      Item {
        Layout.fillWidth: true
      }

      IconButton {
        icon: Icons.restartSymbol
        symbol: true
        tooltipText: "Reset phase"
        onClicked: Pomodoro.reset()
      }

      IconButton {
        icon: Pomodoro.running ? Icons.pauseSymbol : Icons.playSymbol
        symbol: true
        size: 42
        iconSize: Theme.iconSizeLarge
        active: Pomodoro.running
        tooltipText: Pomodoro.running ? "Pause" : "Start"
        onClicked: Pomodoro.toggle()
      }

      IconButton {
        icon: Icons.skipSymbol
        symbol: true
        tooltipText: Pomodoro.phase === Pomodoro.phaseWork ? "Skip to break" : "Skip to focus"
        onClicked: Pomodoro.skip()
      }

      Item {
        Layout.fillWidth: true
      }
    }

    SectionLabel {
      text: "Lengths"
    }

    StepperRow {
      icon: Icons.focusSymbol
      symbol: true
      title: "Focus"
      unit: "min"
      value: Pomodoro.workMinutes
      minimum: Pomodoro.minMinutes
      maximum: Pomodoro.maxMinutes
      onMoved: target => Pomodoro.setMinutes(Pomodoro.phaseWork, target)
      onEditingFinished: popup.refocus()
    }

    StepperRow {
      icon: Icons.breakSymbol
      symbol: true
      title: "Break"
      unit: "min"
      value: Pomodoro.breakMinutes
      minimum: Pomodoro.minMinutes
      maximum: Pomodoro.maxMinutes
      onMoved: target => Pomodoro.setMinutes(Pomodoro.phaseBreak, target)
      onEditingFinished: popup.refocus()
    }
  }
}
