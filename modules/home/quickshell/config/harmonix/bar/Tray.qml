import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../theme"
import "../components"

// StatusNotifierItem host. Left click activates, right click opens the app's
// own menu, middle click is its secondary action.
Item {
  id: root

  Layout.alignment: Qt.AlignVCenter
  implicitWidth: row.implicitWidth
  implicitHeight: Theme.pillHeight
  visible: row.implicitWidth > 0

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: Theme.pillSpacing

    Repeater {
      model: SystemTray.items

      delegate: BarPill {
        id: pill

        required property SystemTrayItem modelData

        tooltipText: pill.modelData.tooltipTitle || pill.modelData.title || pill.modelData.id
        spacing: 0

        onClicked: {
          if (pill.modelData.onlyMenu) pill.showMenu();
          else pill.modelData.activate();
        }
        onRightClicked: pill.showMenu()
        onMiddleClicked: pill.modelData.secondaryActivate()
        onScrolled: direction => pill.modelData.scroll(direction * 120, false)

        function showMenu() {
          if (pill.modelData.hasMenu) {
            pill.modelData.display(pill.QsWindow.window, pill.width / 2, pill.height);
          }
        }

        IconImage {
          source: pill.modelData.icon
          implicitSize: Theme.iconSize + 2
          asynchronous: true
        }
      }
    }
  }
}
