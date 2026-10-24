import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../theme"

// Dots for the workspaces that exist on this monitor: the focused one stretches
// into a bar, occupied ones stay solid, empty ones fade back.
Item {
  id: root

  property var screen: null

  readonly property var monitor: root.screen ? Hyprland.monitorFor(root.screen) : null

  Layout.alignment: Qt.AlignVCenter
  // Padded like a pill so the dots sit at the same inset as neighbouring
  // pill contents rather than hard against them.
  implicitWidth: row.implicitWidth + Theme.pillPadding * 2
  implicitHeight: Theme.pillHeight

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 5

    Repeater {
      model: ScriptModel {
        values: Hyprland.workspaces.values
          .filter(workspace => workspace.id > 0 && (!root.monitor || workspace.monitor === root.monitor))
          .sort((a, b) => a.id - b.id)
      }

      delegate: Rectangle {
        id: dot

        required property var modelData

        readonly property bool focused: dot.modelData.active
        readonly property bool occupied: (dot.modelData.toplevels?.values?.length ?? 0) > 0

        anchors.verticalCenter: parent.verticalCenter
        width: dot.focused ? 24 : dot.occupied ? 10 : 8
        height: dot.focused ? 10 : dot.occupied ? 10 : 8
        radius: height / 2
        color: dot.modelData.urgent ? Colors.critical
          : dot.focused ? Colors.accent
          : dot.occupied ? Colors.fgDim
          : Colors.outlineSoft

        Behavior on width {
          NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        Behavior on height {
          NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        Behavior on color {
          ColorAnimation { duration: Theme.animNormal }
        }

        MouseArea {
          // Grown past the dot so small targets are still easy to hit.
          anchors.fill: parent
          anchors.margins: -5
          cursorShape: Qt.PointingHandCursor
          onClicked: dot.modelData.activate()
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    onWheel: event => {
      if (event.angleDelta.y === 0) return;
      Hyprland.dispatch(event.angleDelta.y > 0 ? "workspace e+1" : "workspace e-1");
    }
  }
}
