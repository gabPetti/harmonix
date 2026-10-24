import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  readonly property int percent: Math.round(Audio.volume * 100)
  readonly property int micPercent: Math.round(Audio.micVolume * 100)

  active: popup.visible
  fill: Audio.muted ? 0 : Audio.volume
  tooltipText: Audio.muted ? "Muted" : `${Audio.sinkName}  ·  ${root.percent}%`

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
    contentWidth: 300

    SectionLabel {
      text: "Output"
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      IconButton {
        icon: Icons.volume(root.percent, Audio.muted)
        active: Audio.muted
        accentColor: Colors.critical
        size: 30
        onClicked: Audio.toggleMute()
      }

      ValueSlider {
        value: Audio.volume
        fillColor: Audio.muted ? Colors.outline : Colors.accent
        onMoved: target => Audio.setVolume(target)
      }

      StyledText {
        Layout.minimumWidth: 38
        horizontalAlignment: Text.AlignRight
        text: `${root.percent}%`
        color: Colors.fgDim
      }
    }

    SectionLabel {
      visible: Audio.source !== null
      text: "Input"
    }

    RowLayout {
      Layout.fillWidth: true
      visible: Audio.source !== null
      spacing: 8

      IconButton {
        icon: Audio.micMuted ? "󰍭" : "󰍬"
        active: Audio.micMuted
        accentColor: Colors.critical
        size: 30
        onClicked: Audio.toggleMicMute()
      }

      ValueSlider {
        value: Audio.micVolume
        fillColor: Audio.micMuted ? Colors.outline : Colors.accent
        onMoved: target => Audio.setMicVolume(target)
      }

      StyledText {
        Layout.minimumWidth: 38
        horizontalAlignment: Text.AlignRight
        text: `${root.micPercent}%`
        color: Colors.fgDim
      }
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
