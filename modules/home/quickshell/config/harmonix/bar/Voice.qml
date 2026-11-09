import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

// Talk to Claude: the pill opens a panel with the two controls a spoken
// conversation needs -- record a turn, and mute the microphone outright --
// and shows what was heard and what came back.
//
// The pill is the only part always visible. Everything underneath it is
// ClaudeVoice; this file is just the handle and the readout.
BarPill {
  id: root

  active: popup.visible || ClaudeVoice.active

  tooltipText: ClaudeVoice.recording
    ? `Listening · ${ClaudeVoice.elapsed}s\nClick to stop and send`
    : ClaudeVoice.busy ? ClaudeVoice.stageLabel
    : "Talk to Claude"

  onClicked: popup.toggle()
  // The one thing worth a shortcut on the pill itself: the panel exists to
  // be opened once, and after that recording a turn is the whole interaction.
  onMiddleClicked: ClaudeVoice.toggle()

  // Recording is the state you must not lose track of -- the microphone is
  // open -- so it gets the one warm colour, the way the pomodoro's break
  // phase does. Working is the accent, idle is dim.
  readonly property color stateColor: ClaudeVoice.recording ? Colors.critical
    : ClaudeVoice.busy ? Colors.accent
    : Colors.fgDim

  StyledText {
    text: Icons.voiceSymbol
    color: root.stateColor
    font.family: Theme.symbolFont
    font.pixelSize: Theme.iconSize
    font.variableAxes: ({ "FILL": ClaudeVoice.active ? 1 : 0, "opsz": Theme.iconSize })

    Behavior on color {
      ColorAnimation { duration: Theme.animNormal }
    }
  }

  // Only while something is happening: a word in the bar at rest would make
  // this the widest pill in the group for no reading.
  StyledText {
    visible: ClaudeVoice.active
    text: ClaudeVoice.recording ? ClaudeVoice.label : ClaudeVoice.stageLabel
    color: root.stateColor
  }

  BarPopup {
    id: popup

    anchorItem: root
    panelId: "voice"
    contentWidth: 340

    SectionLabel {
      text: "Claude voice"
    }

    ListRow {
      icon: ClaudeVoice.recording ? Icons.stop : Icons.record
      iconColor: ClaudeVoice.recording ? Colors.critical : Colors.fgDim
      title: ClaudeVoice.recording ? "Stop and send" : "Record a question"
      // Carries the whole round trip, so the row you clicked is also the row
      // that tells you how far along it is.
      subtitle: ClaudeVoice.recording ? `Listening · ${ClaudeVoice.label}`
        : ClaudeVoice.busy ? ClaudeVoice.stageLabel
        : Audio.micMuted ? "Microphone is muted"
        : ClaudeVoice.speechMuted ? "Claude answers in the panel only"
        : "Claude answers out loud"
      active: ClaudeVoice.recording
      busy: ClaudeVoice.busy
      // A second turn on top of one still being answered would talk over the
      // reply it is still speaking.
      enabled: !ClaudeVoice.busy
      opacity: enabled ? 1 : 0.6
      onClicked: ClaudeVoice.toggle()
    }

    ListRow {
      icon: Audio.micMuted ? Icons.micMuted : Icons.mic
      title: Audio.micMuted ? "Unmute microphone" : "Mute microphone"
      subtitle: Audio.micMuted ? "Nothing is being picked up" : `Input at ${Math.round(Audio.micVolume * 100)}%`
      active: Audio.micMuted
      enabled: Audio.source !== null
      opacity: enabled ? 1 : 0.6
      onClicked: Audio.toggleMicMute()
    }

    SectionLabel {
      text: "Claude's voice"
    }

    SliderRow {
      toggleable: true
      icon: Icons.volume(Math.round(ClaudeVoice.volume * 100), ClaudeVoice.speechMuted)
      muted: ClaudeVoice.speechMuted
      value: ClaudeVoice.volume
      label: ClaudeVoice.speechMuted ? "off" : `${Math.round(ClaudeVoice.volume * 100)}%`
      onToggled: ClaudeVoice.toggleSpeech()
      onMoved: target => ClaudeVoice.setVolume(target)
    }

    SectionLabel {
      visible: ClaudeVoice.transcript !== ""
      text: "You said"
    }

    StyledText {
      Layout.fillWidth: true
      visible: ClaudeVoice.transcript !== ""
      text: ClaudeVoice.transcript
      color: Colors.fgDim
      wrapMode: Text.WordWrap
    }

    SectionLabel {
      visible: ClaudeVoice.reply !== ""
      text: "Claude"
    }

    StyledText {
      Layout.fillWidth: true
      visible: ClaudeVoice.reply !== ""
      text: ClaudeVoice.reply
      wrapMode: Text.WordWrap
    }

    StyledText {
      Layout.fillWidth: true
      visible: ClaudeVoice.error !== ""
      text: ClaudeVoice.error
      color: Colors.critical
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeSmall
    }
  }
}
