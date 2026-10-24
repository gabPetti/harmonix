import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  readonly property int percent: Math.round(Power.percent)
  readonly property string remaining: Power.formatDuration(Power.secondsRemaining)

  visible: Power.hasBattery
  active: popup.visible
  fill: Power.percent / 100
  tooltipText: root.remaining === "" ? `Battery ${root.percent}%`
    : Power.charging ? `${root.percent}%  ·  ${root.remaining} until full`
    : `${root.percent}%  ·  ${root.remaining} left`

  onClicked: popup.toggle()
  onRightClicked: Power.cycleProfile()

  StyledText {
    text: Icons.battery(Power.percent, Power.charging)
    color: Power.critical ? Colors.critical : Power.low ? Colors.warning : Colors.fg
    font.pixelSize: Theme.iconSize

    SequentialAnimation on opacity {
      running: Power.critical
      loops: Animation.Infinite
      alwaysRunToEnd: true

      NumberAnimation { to: 0.35; duration: 700; easing.type: Easing.InOutQuad }
      NumberAnimation { to: 1; duration: 700; easing.type: Easing.InOutQuad }
    }
  }

  PercentLabel {
    value: root.percent
    color: Power.critical ? Colors.critical : Power.low ? Colors.warning : Colors.fg
  }

  BarPopup {
    id: popup

    anchorItem: root
    contentWidth: 270

    SectionLabel {
      text: "Battery"
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 10

      StyledText {
        text: Icons.battery(Power.percent, Power.charging)
        color: Power.critical ? Colors.critical : Power.low ? Colors.warning : Colors.accent
        font.pixelSize: 26
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        StyledText {
          text: `${root.percent}%`
          font.pixelSize: Theme.fontSizeLarge
          font.weight: Font.DemiBold
        }

        StyledText {
          text: Power.charging ? (root.remaining === "" ? "Charging" : `${root.remaining} until full`)
            : (root.remaining === "" ? "On battery" : `${root.remaining} remaining`)
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
        }
      }
    }

    StyledText {
      Layout.fillWidth: true
      visible: Power.battery?.healthSupported ?? false
      text: `Health ${Math.round(Power.battery?.healthPercentage ?? 0)}%`
      color: Colors.fgDim
      font.pixelSize: Theme.fontSizeSmall
    }

    SectionLabel {
      text: "Power profile"
    }

    Repeater {
      model: PowerProfiles.hasPerformanceProfile
        ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
        : [PowerProfile.PowerSaver, PowerProfile.Balanced]

      delegate: ListRow {
        required property var modelData

        active: PowerProfiles.profile === modelData
        icon: Icons.powerProfile(modelData)
        title: Power.profileName(modelData)
        onClicked: Power.setProfile(modelData)
      }
    }
  }
}
