pragma Singleton
import QtQuick

// A random quote for the desktop background (background/Background.qml),
// standing in for Hyprland's own splash text -- disabled in
// hyprland/config/default/general.lua because its list is compiled in and
// can't be edited, where this one is just the array below.
QtObject {
  id: root

  readonly property var quotes: [
    "Do fast, fail fast, iterate fast.",
    "One step at a time",
  ]

  // Picked once per shell startup: the binding has nothing reactive in it,
  // so QML evaluates it exactly once and leaves it alone, which is what
  // keeps the quote stable for the whole session instead of reshuffling
  // every time something reads it.
  readonly property var current: root.quotes[Math.floor(Math.random() * root.quotes.length)]
}
