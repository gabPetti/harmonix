import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  readonly property string remaining: Power.formatDuration(Power.secondsRemaining)
  // Warning and critical colouring, which the icon and the readout share.
  readonly property color tone: Power.critical ? Colors.critical : Power.low ? Colors.warning : Colors.fg

  visible: Power.hasBattery
  active: popup.visible
  fill: Power.percent / 100

  onClicked: popup.toggle()
  onRightClicked: Power.cycleProfile()

  StyledText {
    text: Icons.battery(Power.percent, Power.charging)
    color: root.tone
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
    value: Power.percent
    color: root.tone
  }

  BarPopup {
    id: popup

    anchorItem: root
    panelId: "battery"
    contentWidth: 324

    SectionLabel {
      text: "Battery"
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 10

      StyledText {
        text: Icons.battery(Power.percent, Power.charging)
        color: Power.low ? root.tone : Colors.accent
        font.pixelSize: 26
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        StyledText {
          text: `${Power.percent}%`
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
