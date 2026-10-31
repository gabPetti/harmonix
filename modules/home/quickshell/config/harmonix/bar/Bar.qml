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

  // How much width the centre section actually has. The sides are anchored to
  // the bar's edges and the centre to its middle, so the layout itself does
  // nothing to stop the three meeting -- the centre gets twice the distance
  // to whichever side is nearer, and anything expendable in it yields once
  // that runs out.
  readonly property real centerRoom: 2 * Math.max(0, Math.min(
    bar.width / 2 - (leftRow.x + leftRow.width),
    rightRow.x - bar.width / 2) - Theme.groupSpacing)

  RowLayout {
    id: leftRow

    anchors {
      left: parent.left
      leftMargin: Theme.barMargin + Theme.barEndPadding
      verticalCenter: parent.verticalCenter
    }
    spacing: Theme.groupSpacing

    BarGroup {
      id: launchGroup

      LauncherButton {}

      Workspaces {
        screen: bar.screen
      }
    }

    BarDivider {
      before: launchGroup
      after: windowGroup
    }

    BarGroup {
      id: windowGroup

      ActiveWindow {}
    }
  }

  // Media collapses when nothing is playing, so the clock drifts back to dead
  // centre on its own -- which is why the divider has to track it.
  RowLayout {
    anchors.centerIn: parent
    spacing: Theme.groupSpacing

    BarGroup {
      id: mediaGroup

      // The clock is the one thing in the bar that has to stay put, so when
      // the centre runs out of room the now-playing readout is what gives.
      // Measured against implicitWidth rather than width so hiding the group
      // can't feed back into the test that hid it.
      shown: mediaGroup.implicitWidth + clockGroup.implicitWidth
        + Theme.groupSpacing * 2 + 1 <= bar.centerRoom

      Media {}
    }

    BarDivider {
      before: mediaGroup
      after: clockGroup
    }

    BarGroup {
      id: clockGroup

      Clock {}
    }
  }

  RowLayout {
    id: rightRow

    anchors {
      right: parent.right
      rightMargin: Theme.barMargin + Theme.barEndPadding
      verticalCenter: parent.verticalCenter
    }
    spacing: Theme.groupSpacing

    BarGroup {
      id: trayGroup

      Tray {}
    }

    BarDivider {
      before: trayGroup
      after: resourceGroup
    }

    BarGroup {
      id: resourceGroup

      Cpu {}

      Ram {}

      Disk {}
    }

    BarDivider {
      before: resourceGroup
      after: toggleGroup
    }

    BarGroup {
      id: toggleGroup

      NightLightToggle {}

      Brightness {}

      Volume {}
    }

    BarDivider {
      before: toggleGroup
      after: systemGroup
    }

    BarGroup {
      id: systemGroup

      Network {}

      Bluetooth {}

      Battery {}

      PowerButton {}
    }
  }
}
