import QtQuick
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  readonly property int percent: Math.round(Audio.volume * 100)
  readonly property int micPercent: Math.round(Audio.micVolume * 100)

  active: popup.visible
  fill: Audio.muted ? 0 : Audio.volume

  onClicked: popup.toggle()
  onRightClicked: Audio.toggleMute()
  onMiddleClicked: Audio.toggleMute()
  onScrolled: direction => Audio.adjustVolume(direction * 0.05)

  StyledText {
    text: Icons.volume(root.percent, Audio.muted)
    color: Audio.muted ? Colors.outline : Colors.fg
    font.pixelSize: Theme.iconSize
  }

  PercentLabel {
    value: root.percent
    color: Audio.muted ? Colors.outline : Colors.fg
  }

  BarPopup {
    id: popup

    anchorItem: root
    panelId: "volume"
    contentWidth: 360

    SectionLabel {
      text: "Output"
    }

    SliderRow {
      toggleable: true
      icon: Icons.volume(root.percent, Audio.muted)
      muted: Audio.muted
      value: Audio.volume
      label: `${root.percent}%`
      onToggled: Audio.toggleMute()
      onMoved: target => Audio.setVolume(target)
    }

    SectionLabel {
      visible: Audio.source !== null
      text: "Input"
    }

    SliderRow {
      visible: Audio.source !== null
      toggleable: true
      icon: Audio.micMuted ? Icons.micMuted : Icons.mic
      muted: Audio.micMuted
      value: Audio.micVolume
      label: `${root.micPercent}%`
      onToggled: Audio.toggleMicMute()
      onMoved: target => Audio.setMicVolume(target)
    }

    SectionLabel {
      visible: Audio.sinks.length > 1
      text: "Outputs"
    }

    Repeater {
      model: Audio.sinks.length > 1 ? Audio.sinks : []

      delegate: ListRow {
        required property var modelData

        active: modelData === Audio.sink
        icon: modelData === Audio.sink ? Icons.check : "󰓃"
        title: modelData.nickname || modelData.description || modelData.name
        onClicked: Audio.setSink(modelData)
      }
    }
  }
}
