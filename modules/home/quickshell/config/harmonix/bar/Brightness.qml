import QtQuick
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  visible: Backlight.available
  active: popup.visible
  fill: Backlight.percent / 100

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
    panelId: "brightness"
    contentWidth: 312

    SectionLabel {
      text: "Brightness"
    }

    SliderRow {
      icon: Icons.brightness(Backlight.percent)
      value: Backlight.percent / 100
      label: `${Backlight.percent}%`
      onMoved: target => Backlight.set(target * 100)
    }
  }
}
