import QtQuick
import Quickshell
import "../theme"
import "../components"

BarPill {
  id: root

  active: popup.visible
  // Wider than the default so the time and date read as two values, not one.
  spacing: Theme.pillPadding
  tooltipText: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")

  onClicked: popup.toggle()

  // SystemClock fires on the minute boundary instead of once a second.
  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  StyledText {
    text: Qt.formatDateTime(clock.date, "HH:mm")
    font.weight: Font.DemiBold
  }

  StyledText {
    text: `${Icons.calendar} ${Qt.formatDateTime(clock.date, "dd-MM")}`
    color: Colors.fgDim
  }

  BarPopup {
    id: popup

    anchorItem: root
    contentWidth: 276

    onVisibleChanged: {
      if (popup.visible) month.reset();
    }

    MonthView {
      id: month
      date: clock.date
    }
  }
}
