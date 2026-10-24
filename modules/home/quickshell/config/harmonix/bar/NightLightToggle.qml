import QtQuick
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  active: NightLight.active
  tooltipText: NightLight.active ? "Night light on" : "Night light off"

  onClicked: NightLight.toggle()

  StyledText {
    text: Icons.nightLight
    color: NightLight.active ? Colors.accent : Colors.fgDim
    font.pixelSize: Theme.iconSize
  }
}
