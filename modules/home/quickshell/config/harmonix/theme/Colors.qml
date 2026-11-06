pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  // Catppuccin-ish fallback palette, used until matugen has run once and
  // written ~/.config/quickshell/harmonix/matugen-colors.json (see
  // modules/home/matugen/config/templates/quickshell-colors.json).
  property string accent: "#89b4fa"
  property string accentFg: "#1e1e2e"
  property string fg: "#cdd6f4"
  property string fgDim: "#a6adc8"
  property string bg0: "#1e1e2e"
  property string bg1: "#302d41"
  property string bg2: "#575268"
  property string outline: "#6c7086"
  property string shadow: "#11111b"
  property string warning: "#f9e2af"
  property string critical: "#f38ba8"
  property string hoverBg: "#313244"

  // Which half of the matugen palette the values above came from. Written by
  // the same template, so widgets that need more than a colour to read right
  // in both modes (an opacity, a border) can ask instead of guessing from the
  // background's luminance. Switched with `M` in the launcher's wallpaper
  // picker; see scripts/wallpaper.
  property string mode: "dark"
  readonly property bool light: root.mode === "light"

  // Translucent derivations, so widgets don't each invent their own alpha.
  readonly property color accentSoft: Qt.alpha(accent, 0.18)
  readonly property color hoverSoft: Qt.alpha(hoverBg, 0.55)
  readonly property color outlineSoft: Qt.alpha(outline, 0.35)

  property FileView _file: FileView {
    path: Quickshell.env("HOME") + "/.config/quickshell/harmonix/matugen-colors.json"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
      try {
        const data = JSON.parse(text())
        for (const key in data) {
          if (key in root) root[key] = data[key]
        }
      } catch (e) {
        console.warn("Colors: failed to parse matugen-colors.json:", e)
      }
    }
  }
}
