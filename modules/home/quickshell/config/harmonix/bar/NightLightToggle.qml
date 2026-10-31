import QtQuick
import "../theme"
import "../components"
import "../services"

BarPill {
  id: root

  active: NightLight.active

  onClicked: NightLight.toggle()

  StyledText {
    text: Icons.nightLight
    color: NightLight.active ? Colors.accent : Colors.fgDim
    font.pixelSize: Theme.iconSize
  }
}
