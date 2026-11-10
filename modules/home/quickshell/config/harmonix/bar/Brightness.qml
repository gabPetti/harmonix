import QtQuick
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  visible: Backlight.available
  active: popup.visible
  fill: Backlight.percent / 100
  tooltipText: NightLight.active ? `${Backlight.percent}%  ·  night light on`
    : NightLight.scheduled ? `${Backlight.percent}%  ·  night light ${NightLight.windowLabel}`
    : `${Backlight.percent}%`

  onClicked: popup.toggle()
  onScrolled: direction => Backlight.adjust(direction * 5)

  // Night light moved into this popup, so the bar no longer carries a pill
  // that reports it. Warming the brightness glyph is what keeps the state
  // visible without spending width on a second icon -- and it is the same
  // cue as the screen itself, which has gone warm.
  StyledText {
    text: Icons.brightness(Backlight.percent)
    color: NightLight.active ? Colors.warning : Colors.fg
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

    SectionToggle {
      text: "Night light"
      checked: NightLight.active
      onToggled: NightLight.toggle()
    }

    // The schedule drives the switch above at the window's edges, which is
    // why it sits under it rather than in a panel of its own. Its own rows
    // only appear once it is on: two steppers reading 21:00 - 07:00 beside a
    // switch that is off say nothing about what the screen is doing.
    SectionToggle {
      text: "Schedule"
      checked: NightLight.scheduled
      onToggled: NightLight.setScheduled(!NightLight.scheduled)
    }

    StepperRow {
      visible: NightLight.scheduled
      icon: Icons.bedtimeSymbol
      symbol: true
      title: "On at"
      unit: ":00"
      value: NightLight.startHour
      maximum: 23
      onMoved: target => NightLight.setHour("start", target)
      onEditingFinished: popup.refocus()
    }

    StepperRow {
      visible: NightLight.scheduled
      icon: Icons.sunriseSymbol
      symbol: true
      title: "Off at"
      unit: ":00"
      value: NightLight.endHour
      maximum: 23
      onMoved: target => NightLight.setHour("end", target)
      onEditingFinished: popup.refocus()
    }
  }
}
