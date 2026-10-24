import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  visible: Backlight.available
  active: popup.visible
  fill: Backlight.percent / 100
  tooltipText: `Brightness ${Backlight.percent}%`

  onClicked: popup.toggle()
  onScrolled: direction => Backlight.adjust(direction * 5)

  StyledText {
    text: Icons.brightness(Backlight.percent)
    font.pixelSize: Theme.iconSize
  }

  PercentLabel {
    value: Backlight.percent
  }

  BarPopup {
    id: popup

    anchorItem: root
    contentWidth: 260

    SectionLabel {
      text: "Brightness"
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      StyledText {
        text: Icons.brightness(Backlight.percent)
        font.pixelSize: Theme.iconSize
        color: Colors.fgDim
      }

      ValueSlider {
        value: Backlight.percent / 100
        onMoved: target => Backlight.set(target * 100)
      }

      StyledText {
        Layout.minimumWidth: 38
        horizontalAlignment: Text.AlignRight
        text: `${Backlight.percent}%`
        color: Colors.fgDim
      }
    }
  }
}
