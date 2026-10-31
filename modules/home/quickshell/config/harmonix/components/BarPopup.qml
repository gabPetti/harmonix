import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Shapes
import Quickshell.Hyprland
import Quickshell.Wayland
import "../theme"
import "../services"

// A panel that extends out of the bar. Content goes in a fixed-width
// ColumnLayout and should use `Layout.fillWidth`: the panel's height is
// derived from the column, so anchoring back to the panel is a binding loop.
//
// Visibility lives in the Panels singleton, which is what makes opening one
// panel close whichever was already open.
//
// A layer surface in the bar's namespace rather than an xdg popup of it:
// Hyprland's layer rules reach a surface but not its popups, so only this way
// do the two blur the same wallpaper and read as the same material.
PanelWindow {
  id: root

  property Item anchorItem: null
  property int contentWidth: Theme.popupWidth
  property int padding: Theme.popupPadding
  // Name a panel answers to over IPC, so a Hyprland keybind can open it
  // (services/Panels.qml, shell.qml). Panels without one are mouse-only.
  property string panelId: ""

  default property alias content: column.data

  // What Panels wants. The window outlives it by the length of the collapse,
  // which is the whole reason the two are separate: a panel that vanished
  // the instant it was dismissed would never animate shut.
  readonly property bool shouldShow: Panels.owner === root
  // 0 is folded into the bar, 1 fully extended. Assigned rather than bound so
  // that `visible` can depend on it without forming a loop.
  property real extension: 0

  readonly property int extendedHeight: column.implicitHeight + root.padding * 2

  // The bar window the anchor pill lives in: the panel belongs on that same
  // monitor, and its width is what the panel has to stay inside of.
  readonly property var anchorWindow: root.anchorItem ? root.anchorItem.QsWindow.window : null

  // Middle of the pill's bottom edge, in the bar window's coordinates --
  // which are the screen's, the bar being anchored to three edges at the top.
  // Recomputed, not bound: mapToItem depends on nothing, so as a binding it
  // froze at whatever the layout was when the panel was built.
  property point anchorPoint: Qt.point(0, 0)

  function updateAnchor(): void {
    if (root.anchorItem)
      root.anchorPoint = root.anchorItem.mapToItem(null, root.anchorItem.width / 2, root.anchorItem.height);
  }

  // Nothing signals that a descendant moved in the scene, and the bar does
  // relay out under an open panel (media collapses, the clock widens), so the
  // anchor is re-read on a slow tick -- only while a panel is open.
  onAnchorItemChanged: root.updateAnchor()

  Component.onCompleted: {
    root.updateAnchor();
    if (root.panelId !== "")
      Panels.register(root);
  }

  Component.onDestruction: Panels.unregister(root)

  Timer {
    running: root.visible
    interval: 100
    repeat: true
    triggeredOnStart: true
    onTriggered: root.updateAnchor()
  }

  screen: root.anchorWindow ? root.anchorWindow.screen : null

  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "quickshell:bar"
  // Only while open, so the window underneath keeps the keyboard otherwise.
  // Exclusive, not on-demand: hjkl has to reach a panel without a click.
  WlrLayershell.keyboardFocus: root.shouldShow ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  // Ignore every exclusive zone, not merely reserve none: respecting the
  // bar's own zone would measure this panel's top margin from the bottom of
  // it, landing the panel a bar's height below the bar it hangs off.
  exclusionMode: ExclusionMode.Ignore

  anchors {
    top: true
    left: true
  }

  // Centred under the pill that opened it, pulled back when the pill sits too
  // close to an end to fit. The limits are where the bar's underside stops
  // being straight: a fillet needs bar directly above it.
  margins {
    left: Math.round(Math.max(Theme.barMargin + Theme.barRadius, Math.min(root.anchorPoint.x - root.implicitWidth / 2, (root.anchorWindow ? root.anchorWindow.width : 0) - Theme.barMargin - Theme.barRadius - root.implicitWidth)))
    top: Math.round(root.anchorPoint.y) + Theme.popupAttach
  }

  implicitWidth: root.contentWidth + root.padding * 2 + Theme.popupFillet * 2
  // Full height for as long as it's open rather than resized frame by frame:
  // animating a window's height is a new buffer and a surface commit every
  // tick. The drawer does the moving, the compositor sees one resize.
  implicitHeight: Math.max(1, root.extendedHeight)
  color: "transparent"
  visible: root.shouldShow || root.extension > 0

  // Which is why it needs a mask: without one, the height the drawer hasn't
  // reached yet would still swallow clicks meant for the window under it.
  mask: Region {
    item: drawer
  }

  onShouldShowChanged: {
    if (root.shouldShow) {
      root.updateAnchor();
      // Deferred: on a panel's first open its content hasn't been laid out
      // yet, and the walk orders items by where they sit.
      Qt.callLater(nav.first);
    } else {
      nav.select(null);
    }
    root.extension = root.shouldShow ? 1 : 0;
  }

  // hjkl, Enter and q, over whatever the panel holds.
  KeyNav {
    id: nav

    container: column
    onDismissed: root.close()
  }

  Behavior on extension {
    NumberAnimation {
      duration: root.shouldShow ? Theme.animEnter : Theme.animExit
      easing.type: Easing.BezierSpline
      easing.bezierCurve: root.shouldShow ? Theme.easeEnter : Theme.easeExit
    }
  }

  function open() {
    Panels.open(root);
  }

  function close() {
    Panels.close();
  }

  function toggle() {
    Panels.toggle(root);
  }

  HyprlandFocusGrab {
    active: root.visible
    windows: [root]
    // Another pill may already have taken ownership by the time the grab on
    // this one clears; don't close the panel that replaced us.
    onCleared: {
      if (Panels.owner === root) root.close();
    }
  }

  // One closed outline, not a rounded rectangle: the top corners are concave,
  // curving out into the bar's underside so the panel grows from the bar
  // rather than butting against it. A single path, because two overlapping
  // shapes at this alpha would seam where their fills meet.
  //
  // Exactly the bar's fill, alpha included -- matching only the colour reads
  // as a different material, the tone coming from the blur behind it.
  Item {
    id: drawer

    width: parent.width
    height: Math.round(root.extendedHeight * root.extension)

    Shape {
      id: shape

      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer

      // Both radii collapse while the drawer is only a few pixels tall, so
      // the outline stays a simple closed curve all through the opening.
      readonly property real fillet: Math.min(Theme.popupFillet, drawer.height)
      readonly property real radius: Math.min(Theme.popupRadius, Math.max(0, drawer.height - shape.fillet))

      ShapePath {
        fillColor: Qt.alpha(Colors.bg0, Theme.barOpacity)
        // Negative, not zero: a ShapePath strokes in white by default, and
        // only a negative width turns stroking off outright.
        strokeWidth: -1

        startX: 0
        startY: 0

        // Across the top, flush with the bar.
        PathLine {
          x: shape.width
          y: 0
        }

        // Down and in: the right-hand fillet.
        PathArc {
          x: shape.width - shape.fillet
          y: shape.fillet
          radiusX: shape.fillet
          radiusY: shape.fillet
          direction: PathArc.Counterclockwise
        }

        PathLine {
          x: shape.width - shape.fillet
          y: drawer.height - shape.radius
        }

        PathArc {
          x: shape.width - shape.fillet - shape.radius
          y: drawer.height
          radiusX: shape.radius
          radiusY: shape.radius
          direction: PathArc.Clockwise
        }

        PathLine {
          x: shape.fillet + shape.radius
          y: drawer.height
        }

        PathArc {
          x: shape.fillet
          y: drawer.height - shape.radius
          radiusX: shape.radius
          radiusY: shape.radius
          direction: PathArc.Clockwise
        }

        PathLine {
          x: shape.fillet
          y: shape.fillet
        }

        // Back out to the bar: the left-hand fillet.
        PathArc {
          x: 0
          y: 0
          radiusX: shape.fillet
          radiusY: shape.fillet
          direction: PathArc.Counterclockwise
        }
      }
    }

    // The fillets widen the window past the panel proper, so content is
    // clipped to the body between them rather than to the whole drawer.
    Item {
      x: Theme.popupFillet
      width: root.contentWidth + root.padding * 2
      height: parent.height
      clip: true

      // Pinned to the top rather than filling the drawer: the content holds
      // still at its final position and the drawer's edge travels past it, so
      // the contents are uncovered rather than stretched into place.
      ColumnLayout {
        id: column

        x: root.padding
        y: root.padding
        width: root.contentWidth
        spacing: Theme.popupGap
      }
    }
  }
}
