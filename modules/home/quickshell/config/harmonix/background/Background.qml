import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../components"
import "../services"

// One instance per monitor (shell.qml), sitting right on top of hyprpaper's
// wallpaper -- the layer this repo disabled Hyprland's own splash text for
// (misc:disable_splash_rendering, hyprland/config/default/general.lua),
// because that one's quote list is compiled into the binary where this one
// is Quotes.qml.
//
// WlrLayer.Bottom rather than Background: hyprpaper is its own layer-shell
// client sitting at Background, and two surfaces sharing a layer stack in
// whatever order they happened to map in -- Bottom is the one layer
// guaranteed to draw above it without also sitting above normal windows.
PanelWindow {
  anchors {
    left: true
    right: true
    bottom: true
  }

  implicitHeight: label.implicitHeight + Theme.barMargin * 4
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Bottom
  exclusionMode: ExclusionMode.Ignore

  // Nothing in here takes input: an empty region, rather than leaving the
  // window to claim the whole strip, is what keeps a click meant for the
  // desktop underneath from landing on this instead.
  mask: Region {}

  Item {
    id: shadowSource

    anchors.centerIn: parent
    width: label.implicitWidth
    height: label.implicitHeight
    layer.enabled: true
    visible: false

    StyledText {
      id: label

      anchors.centerIn: parent
      text: `"${Quotes.current}"`
      color: Colors.fgDim
      font.pixelSize: Theme.fontSizeLarge
      font.italic: true
    }
  }

  MultiEffect {
    anchors.fill: shadowSource
    source: shadowSource
    shadowEnabled: true
    shadowColor: Colors.bg0
    shadowOpacity: 0.8
    shadowBlur: 0.6
  }
}
