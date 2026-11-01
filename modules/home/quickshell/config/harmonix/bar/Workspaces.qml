import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import "../theme"
import "../components"

// Dots for the workspaces on this monitor: the focused one stretches into a
// bar, occupied ones stay solid, empty ones fade back. Theme.workspaceCount
// of them are always drawn, whether or not Hyprland has created them yet, so
// the group keeps one width instead of growing a dot at a time.
//
// A special workspace is not part of that row -- Hyprland layers it over
// whichever workspace stays active underneath -- so showing one blurs the
// dots back and names it over the top, the way end-4's bar does.
Item {
  id: root

  property var screen: null

  readonly property var monitor: root.screen ? Hyprland.monitorFor(root.screen) : null

  // Every real workspace on this monitor, special ones excluded: those carry
  // a negative id and are handled by the overlay below, not by a dot.
  readonly property var monitorWorkspaces: Hyprland.workspaces.values
    .filter(workspace => workspace.id > 0 && (!root.monitor || workspace.monitor === root.monitor))

  // The ids to draw: the first Theme.workspaceCount unconditionally, plus any
  // the user has actually reached beyond them. Sorted and de-duplicated, so
  // an existing workspace inside the default range doesn't get a second dot.
  readonly property var workspaceIds: {
    const ids = root.monitorWorkspaces.map(workspace => workspace.id);
    for (let id = 1; id <= Theme.workspaceCount; id++) ids.push(id);
    return [...new Set(ids)].sort((a, b) => a - b);
  }

  // Hyprland reports a monitor's special workspace only inside the monitor's
  // IPC object, which Quickshell does not keep current (lastIpcObject is only
  // refreshed on demand). So the live value comes from the activespecialv2
  // event, and the stale object just seeds it at startup -- the binding below
  // is replaced by the first assignment the handler makes.
  property string specialWorkspace: root.monitor?.lastIpcObject?.specialWorkspace?.name ?? ""

  // "special:magic" is how Hyprland names them; the prefix is noise here.
  readonly property string specialLabel: root.specialWorkspace.replace(/^special:/, "")

  // Drives the blur, the label's fade and its scale together, so the dots
  // receding and the name arriving are one movement rather than two.
  property real specialProgress: root.specialWorkspace !== "" ? 1 : 0

  Layout.alignment: Qt.AlignVCenter
  // Padded like a pill so the dots sit at the same inset as neighbouring
  // pill contents rather than hard against them. The padding doubles as the
  // margin the blur spreads into -- a layer is clipped to its item's bounds,
  // so without it the blurred dots would be cut off square at the edges.
  implicitWidth: row.implicitWidth + Theme.pillPadding * 2
  implicitHeight: Theme.pillHeight

  Behavior on specialProgress {
    NumberAnimation {
      duration: Theme.animNormal
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.easeStandard
    }
  }

  // The seeded value above is only as fresh as the last monitor fetch, which
  // on a hot reload is whatever it was when the shell first started. Asking
  // for one now is what makes the chip correct if the shell is reloaded with
  // a special workspace already open.
  Component.onCompleted: Hyprland.refreshMonitors()

  Connections {
    target: Hyprland

    // activespecialv2 carries "<id>,<name>,<monitor>", and all three are
    // empty when the special workspace is being closed rather than opened.
    function onRawEvent(event): void {
      if (event.name !== "activespecialv2") return;

      const parts = event.data.split(",");
      if (root.monitor && parts[2] !== root.monitor.name) return;

      root.specialWorkspace = parts[1] ?? "";
    }
  }

  Item {
    id: dots

    anchors.fill: parent
    opacity: 1 - Theme.workspaceSpecialDim * root.specialProgress
    // Rendered through the blur rather than beside it, which keeps the dots
    // visible to the mouse: an item hidden to feed an effect takes no input.
    // Off at rest so the bar isn't paying for a texture it never blurs.
    layer.enabled: root.specialProgress > 0
    layer.smooth: true
    layer.effect: MultiEffect {
      blurEnabled: true
      blur: root.specialProgress
      blurMax: Theme.workspaceBlur
    }

    Row {
      id: row

      anchors.centerIn: parent
      spacing: Theme.workspaceDotSpacing

      Repeater {
        model: ScriptModel {
          values: root.workspaceIds
        }

        delegate: Rectangle {
          id: dot

          required property var modelData

          // Null until Hyprland creates it -- a dot inside the default range
          // that has never been visited has no workspace behind it.
          readonly property var workspace: root.monitorWorkspaces
            .find(candidate => candidate.id === dot.modelData) ?? null

          readonly property bool focused: dot.workspace?.active ?? false
          readonly property bool occupied: (dot.workspace?.toplevels?.values?.length ?? 0) > 0

          anchors.verticalCenter: parent.verticalCenter
          width: dot.focused ? Theme.workspaceDotActive : dot.occupied ? Theme.workspaceDot : Theme.workspaceDotEmpty
          height: dot.focused ? Theme.workspaceDot : dot.occupied ? Theme.workspaceDot : Theme.workspaceDotEmpty
          radius: height / 2
          color: dot.workspace?.urgent ? Colors.critical
            : dot.focused ? Colors.accent
            : dot.occupied ? Colors.fgDim
            : Colors.outlineSoft

          Behavior on width {
            NumberAnimation {
              duration: Theme.animNormal
              easing.type: Easing.BezierSpline
              easing.bezierCurve: Theme.easeStandard
            }
          }

          Behavior on height {
            NumberAnimation {
              duration: Theme.animNormal
              easing.type: Easing.BezierSpline
              easing.bezierCurve: Theme.easeStandard
            }
          }

          Behavior on color {
            ColorAnimation { duration: Theme.animNormal }
          }

          MouseArea {
            // Grown past the dot so small targets are still easy to hit.
            anchors.fill: parent
            anchors.margins: -5
            cursorShape: Qt.PointingHandCursor
            // A dot with no workspace behind it still switches: the
            // dispatcher creates the workspace on arrival.
            onClicked: dot.workspace
              ? dot.workspace.activate()
              : Hyprland.dispatch(root.focusWorkspace(dot.modelData))
          }
        }
      }
    }
  }

  // Outside `dots`, so the blur it fades in over doesn't also soften it.
  Rectangle {
    id: specialChip

    anchors.centerIn: parent
    // Never wider than the dots it covers: a long special workspace name
    // would otherwise reach past the group and over the divider beside it.
    width: Math.min(specialName.implicitWidth + Theme.contentSpacing * 2, root.width)
    height: Theme.specialChipHeight
    radius: height / 2
    color: Colors.accent
    opacity: root.specialProgress
    // Settles into place rather than appearing at full size, which reads as
    // the name rising out of the dots instead of being stamped over them.
    scale: 0.85 + 0.15 * root.specialProgress
    visible: root.specialProgress > 0

    StyledText {
      id: specialName

      anchors.centerIn: parent
      width: Math.min(implicitWidth, specialChip.width - Theme.contentSpacing * 2)
      text: root.specialLabel
      font.pixelSize: Theme.fontSizeSmall
      font.bold: true
      // The chip is painted in the accent, so its text takes the colour the
      // palette pairs with that rather than the shell's usual foreground.
      color: Colors.accentFg
      elide: Text.ElideRight
      horizontalAlignment: Text.AlignHCenter
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    onWheel: event => {
      if (event.angleDelta.y === 0) return;
      Hyprland.dispatch(root.focusWorkspace(event.angleDelta.y > 0 ? "e+1" : "e-1"));
    }
  }

  // Hyprland's Lua config mode parses a dispatch as a Lua expression, so the
  // plain "workspace 3" form is a syntax error there and vice versa.
  function focusWorkspace(target): string {
    return Hyprland.usingLua
      ? `hl.dsp.focus({ workspace = "${target}" })`
      : `workspace ${target}`;
  }
}
