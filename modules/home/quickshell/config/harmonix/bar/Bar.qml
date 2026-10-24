import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../components"

// One instance per monitor. The bar floats with a margin on every side, and
// its contents are grouped into islands so the three regions read apart.
PanelWindow {
  id: bar

  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: Theme.barHeight + Theme.barMargin * 2
  color: "transparent"

  // Reserve only down to the bar's own bottom edge, not the full window.
  // Hyprland then adds its gaps_out below that, which -- since barMargin is
  // the same value -- leaves exactly as much room between the bar and the
  // windows as there is between the bar and the top of the screen.
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: Theme.barMargin + Theme.barHeight

  // Only the bar body takes input; clicks in the transparent margin around it
  // fall through to whatever is underneath.
  mask: Region {
    item: body
  }

  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "quickshell:bar"

  Rectangle {
    id: body

    anchors.fill: parent
    anchors.margins: Theme.barMargin
    radius: Theme.barRadius
    color: Qt.alpha(Colors.bg0, Theme.barOpacity)
    // border.width: 1
    // border.color: Colors.outlineSoft
  }

  RowLayout {
    anchors {
      left: parent.left
      leftMargin: Theme.barMargin + Theme.barEndPadding
      verticalCenter: parent.verticalCenter
    }
    spacing: Theme.groupSpacing

    BarGroup {
      LauncherButton {}

      Workspaces {
        screen: bar.screen
      }
    }

    BarGroup {
      ActiveWindow {}
    }
  }

  BarGroup {
    anchors.centerIn: parent

    Media {}

    Clock {}
  }

  RowLayout {
    anchors {
      right: parent.right
      rightMargin: Theme.barMargin + Theme.barEndPadding
      verticalCenter: parent.verticalCenter
    }
    spacing: Theme.groupSpacing

    BarGroup {
      Tray {}
    }

    BarGroup {
      Cpu {}
    }

    BarGroup {
      Ram {}
    }
    
    BarGroup {
      Disk {}
    }

    BarGroup {
      NightLightToggle {}
    }

    BarGroup {
      Brightness {}
    }

    BarGroup {
      Volume {}
    }

    BarGroup {
      Network {}

      Bluetooth {}

      Battery {}

      PowerButton {}
    }
  }
}
