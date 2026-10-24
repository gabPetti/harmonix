import QtQuick
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  active: popup.visible
  tooltipText: "Session"

  onClicked: popup.toggle()

  StyledText {
    text: Icons.power
    color: root.active || root.hovered ? Colors.critical : Colors.fgDim
    font.pixelSize: Theme.iconSize
  }

  BarPopup {
    id: popup

    anchorItem: root
    contentWidth: 190

    ListRow {
      icon: Icons.lockScreen
      title: "Lock"
      onClicked: {
        popup.close();
        Power.lock();
      }
    }

    ListRow {
      icon: Icons.suspend
      title: "Suspend"
      onClicked: {
        popup.close();
        Power.suspend();
      }
    }

    ListRow {
      icon: Icons.logout
      title: "Log out"
      onClicked: {
        popup.close();
        Power.logout();
      }
    }

    ListRow {
      icon: Icons.reboot
      title: "Reboot"
      iconColor: Colors.warning
      onClicked: {
        popup.close();
        Power.reboot();
      }
    }

    ListRow {
      icon: Icons.power
      title: "Shut down"
      iconColor: Colors.critical
      onClicked: {
        popup.close();
        Power.shutdown();
      }
    }
  }
}
