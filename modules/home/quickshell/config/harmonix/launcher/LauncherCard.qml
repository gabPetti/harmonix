import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../theme"
import "../components"
import "../services"

// The window and the chrome both pickers share: a dimmed backdrop, a card
// that rises from the bottom edge into the middle of the screen, a header
// strip ending in the mode chips, and a footer. What goes inside -- a search
// field and a list, or a grid driven by hjkl -- is the picker's own business,
// which is why keys are handled there rather than here.
PanelWindow {
  id: root

  // Which LauncherState mode this window answers to. Both pickers exist at
  // all times; only the one whose mode is current is mapped.
  property string mode: LauncherState.modeApps
  // Left-hand side of the header, before the mode chips.
  property alias headerContent: headerRow.data
  property string status: ""
  property string hint: ""

  default property alias content: body.data

  readonly property bool shown: LauncherState.opened && LauncherState.mode === root.mode

  visible: root.shown
  screen: Quickshell.screens.find(candidate => candidate.name === Hyprland.focusedMonitor?.name)
    ?? Quickshell.screens[0]
    ?? null

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"
  exclusionMode: ExclusionMode.Ignore

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "quickshell:launcher"
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  onVisibleChanged: card.reveal = root.visible ? 1 : 0

  Rectangle {
    anchors.fill: parent
    color: Qt.alpha(Colors.shadow, 0.5)
    opacity: card.reveal

    MouseArea {
      anchors.fill: parent
      onClicked: LauncherState.close()
    }
  }

  Rectangle {
    id: card

    // 0 is off the bottom edge, 1 is resting in the middle of the screen.
    // The position is a binding on this rather than something assigned on
    // open and close, so the card can't be left stranded if it is dismissed
    // mid-rise.
    property real reveal: 0

    readonly property int restY: Math.round((parent.height - height) / 2)

    anchors.horizontalCenter: parent.horizontalCenter
    y: Math.round(parent.height - (parent.height - card.restY) * card.reveal)
    width: Math.min(700, parent.width - 80)
    height: Math.min(540, Math.round(parent.height * 0.64))
    radius: 24
    color: Colors.bg0
    border.width: 1
    border.color: Colors.outlineSoft
    opacity: card.reveal

    // Arriving is given the longer, decelerating curve and leaving the
    // shorter one, the same split the bar's panels use.
    Behavior on reveal {
      NumberAnimation {
        duration: card.reveal > 0 ? Theme.animEnter : Theme.animExit
        easing.type: Easing.BezierSpline
        easing.bezierCurve: card.reveal > 0 ? Theme.easeEnter : Theme.easeExit
      }
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 10

      RowLayout {
        Layout.fillWidth: true
        spacing: 12

        RowLayout {
          id: headerRow

          Layout.fillWidth: true
          spacing: 12
        }

        ModeChip {
          label: "Apps"
          active: LauncherState.mode === LauncherState.modeApps
          onClicked: LauncherState.open(LauncherState.modeApps)
        }

        ModeChip {
          label: "Walls"
          active: LauncherState.mode === LauncherState.modeWallpapers
          onClicked: LauncherState.open(LauncherState.modeWallpapers)
        }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Colors.outlineSoft
      }

      Item {
        id: body

        Layout.fillWidth: true
        Layout.fillHeight: true
      }

      RowLayout {
        Layout.fillWidth: true

        StyledText {
          text: root.status
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
        }

        Item {
          Layout.fillWidth: true
        }

        StyledText {
          text: root.hint
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
        }
      }
    }
  }
}
