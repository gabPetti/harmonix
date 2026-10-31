import QtQuick
import QtQuick.Layouts
import "../theme"

// A section heading with a switch on the right: how every popup that owns a
// radio (Wi-Fi, Bluetooth) introduces its list.
RowLayout {
  id: root

  property alias text: label.text
  property bool checked: false

  signal toggled

  Layout.fillWidth: true
  spacing: Theme.popupGap

  SectionLabel {
    id: label

    Layout.fillWidth: true
  }

  ToggleSwitch {
    checked: root.checked
    onToggled: root.toggled()
  }
}
