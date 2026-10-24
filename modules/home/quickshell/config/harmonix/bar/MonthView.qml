import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"

// Monday-first month grid with today highlighted. `reset()` jumps back to the
// month containing `date`; the popup calls it on every open so navigating away
// doesn't stick.
ColumnLayout {
  id: root

  property date date: new Date()

  property int shownYear: 0
  property int shownMonth: 0

  readonly property bool onCurrentMonth: root.shownYear === root.date.getFullYear()
    && root.shownMonth === root.date.getMonth()
  readonly property int leadingBlanks: (new Date(root.shownYear, root.shownMonth, 1).getDay() + 6) % 7
  readonly property int dayCount: new Date(root.shownYear, root.shownMonth + 1, 0).getDate()

  Layout.fillWidth: true
  spacing: 6

  Component.onCompleted: root.reset()

  function reset() {
    root.shownYear = root.date.getFullYear();
    root.shownMonth = root.date.getMonth();
  }

  function shift(months) {
    const target = new Date(root.shownYear, root.shownMonth + months, 1);
    root.shownYear = target.getFullYear();
    root.shownMonth = target.getMonth();
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: 4

    IconButton {
      icon: Icons.chevronLeft
      size: 26
      onClicked: root.shift(-1)
    }

    StyledText {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      text: Qt.formatDate(new Date(root.shownYear, root.shownMonth, 1), "MMMM yyyy")
      font.weight: Font.DemiBold
    }

    IconButton {
      icon: Icons.chevronRight
      size: 26
      onClicked: root.shift(1)
    }
  }

  GridLayout {
    Layout.fillWidth: true
    columns: 7
    rowSpacing: 1
    columnSpacing: 1

    Repeater {
      model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

      delegate: StyledText {
        required property string modelData

        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: modelData
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
      }
    }

    Repeater {
      model: root.leadingBlanks + root.dayCount

      delegate: Item {
        id: cell

        required property int index

        readonly property int day: cell.index - root.leadingBlanks + 1
        readonly property bool today: root.onCurrentMonth && cell.day === root.date.getDate()

        Layout.fillWidth: true
        implicitHeight: 28

        Rectangle {
          anchors.centerIn: parent
          visible: cell.today
          width: 26
          height: 26
          radius: 13
          color: Colors.accent
        }

        StyledText {
          anchors.centerIn: parent
          visible: cell.day > 0
          text: cell.day
          color: cell.today ? Colors.accentFg : Colors.fg
          font.pixelSize: Theme.fontSizeSmall
        }
      }
    }
  }
}
