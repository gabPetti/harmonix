import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Shapes
import Quickshell.Hyprland
import Quickshell.Wayland
import "../theme"
import "../services"

// A panel that extends out of the bar. Children are placed in a fixed-width
// ColumnLayout, so content should use `Layout.fillWidth` rather than
// anchoring to the popup: the panel's extended height is derived from the
// column, and anchoring back to it would be a binding loop.
//
// Visibility lives in the Panels singleton, which is what makes opening one
// panel close whichever one was already open.
//
// A layer surface of its own, in the bar's namespace, rather than an xdg
// popup anchored to the bar -- which is what it used to be. Hyprland applies
// a layer rule to the layer surface itself; blur_popups carries only the blur
// onto its popups, not xray. So as a popup the panel blurred whatever window
// it hung across while the bar blurred the wallpaper, and the identical fill
// came out visibly darker. As its own surface it matches the bar rule for
// rule, so the two are the same material again.
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
  //
  // Recomputed rather than bound: mapToItem walks the parent chain and
  // creates a dependency on none of it, so as a binding this read whatever
  // the pill's position happened to be when the panel was built -- before
  // the bar had laid out, which left every panel pinned at a clamp limit.
  // Naming the pill's own geometry in the binding isn't enough either: the
  // pill holds still inside its group while the group moves under it.
  property point anchorPoint: Qt.point(0, 0)

  function updateAnchor(): void {
    if (root.anchorItem)
      root.anchorPoint = root.anchorItem.mapToItem(null, root.anchorItem.width / 2, root.anchorItem.height);
  }

  // The bar relays out while a panel is open -- media collapses, the clock
  // ticks a digit wider -- and no signal reports that a descendant moved in
  // the scene, so an open panel re-reads its anchor on a slow tick. One
  // mapToItem ten times a second, and only while something is open.
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
  // Taken only while a panel is actually open, so the window underneath keeps
  // the keyboard the rest of the time. Exclusive rather than on-demand: the
  // panel is a menu, and hjkl has to reach it without a click first.
  WlrLayershell.keyboardFocus: root.shouldShow ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  // Ignore every exclusive zone rather than merely reserving none of its own:
  // the bar reserves barMargin + barHeight, and a panel that respects that
  // would have its top margin measured from the bottom of the reservation --
  // landing a bar's height below the bar it is supposed to hang off.
  exclusionMode: ExclusionMode.Ignore

  anchors {
    top: true
    left: true
  }

  // Centred under the pill that opened it, so a panel reads as belonging to
  // its button: the clock's calendar comes down in the middle of the bar, a
  // tray panel over its own icon. Pulled back when the pill sits too close to
  // an end for the panel to fit, the limits being where the bar body's
  // underside stops being straight -- a fillet needs bar directly above it,
  // so the whole window has to clear the bar's rounded ends.
  margins {
    left: Math.round(Math.max(Theme.barMargin + Theme.barRadius, Math.min(root.anchorPoint.x - root.implicitWidth / 2, (root.anchorWindow ? root.anchorWindow.width : 0) - Theme.barMargin - Theme.barRadius - root.implicitWidth)))
    top: Math.round(root.anchorPoint.y) + Theme.popupAttach
  }

  implicitWidth: root.contentWidth + root.padding * 2 + Theme.popupFillet * 2
  // Held at full height for as long as it's open, rather than resized frame
  // by frame: animating a window's height means a fresh buffer and a surface
  // commit every tick, which is what made the extend stutter. The drawer
  // inside does all the moving, and the compositor only sees one resize.
  implicitHeight: Math.max(1, root.extendedHeight)
  color: "transparent"
  visible: root.shouldShow || root.extension > 0

  // Which is why the window needs a mask: it is full height from the first
  // frame, and without this the part the drawer hasn't reached yet would
  // still swallow clicks meant for the window underneath.
  mask: Region {
    item: drawer
  }

  onShouldShowChanged: {
    if (root.shouldShow) {
      root.updateAnchor();
      // Deferred: on a panel's first open its content hasn't been laid out
      // yet, and the walk orders items by where they sit.
      Qt.callLater(root.navFirst);
    } else {
      root.navSelect(null);
    }
    root.extension = root.shouldShow ? 1 : 0;
  }

  // --- keyboard ----------------------------------------------------------
  //
  // j and k walk the panel's interactive pieces in reading order, h and l
  // drive whatever the selection can adjust -- a volume or brightness slider
  // -- Enter acts on it, and q or Escape closes. A piece joins the walk by
  // declaring `navigable` and a `selected` flag; see components/ListRow.qml.
  property Item navItem: null

  // Rebuilt on every keypress rather than cached: these panels list networks,
  // devices and sinks that appear and disappear underneath the selection.
  function navItems(): var {
    const found = [];
    const walk = item => {
      for (const child of item.children) {
        if (!child.visible)
          continue;
        if (child.navigable === true)
          found.push(child);
        walk(child);
      }
    };
    walk(column);
    found.sort((a, b) => {
      const pa = a.mapToItem(column, 0, 0);
      const pb = b.mapToItem(column, 0, 0);
      // Down the panel first, then across -- but only count a difference in
      // y as a different row, or two things side by side in one row would
      // sort by a pixel of mismatched baseline.
      return Math.abs(pa.y - pb.y) > 2 ? pa.y - pb.y : pa.x - pb.x;
    });
    return found;
  }

  // Opening a panel puts the cursor on its first item, so j/k and Enter have
  // somewhere to start without a keypress to get there.
  function navFirst(): void {
    const items = root.navItems();
    root.navSelect(items.length > 0 ? items[0] : null);
  }

  function navSelect(item: Item): void {
    root.navItem = item;
    for (const candidate of root.navItems())
      candidate.selected = candidate === item;
  }

  function navMove(delta: int): void {
    const items = root.navItems();
    if (items.length === 0)
      return;
    const at = items.indexOf(root.navItem);
    // Nothing selected yet: j starts at the top of the panel, k at the end.
    root.navSelect(at === -1 ? items[delta > 0 ? 0 : items.length - 1] : items[Math.max(0, Math.min(items.length - 1, at + delta))]);
  }

  function navAdjust(direction: int): void {
    if (root.navItem && root.navItem.adjust)
      root.navItem.adjust(direction);
  }

  function navActivate(): void {
    if (root.navItem && root.navItem.activate)
      root.navItem.activate();
  }

  Item {
    anchors.fill: parent
    focus: true

    Keys.onPressed: event => {
      switch (event.key) {
      case Qt.Key_Escape:
      case Qt.Key_Q:
        root.close();
        break;
      case Qt.Key_J:
      case Qt.Key_Down:
        root.navMove(1);
        break;
      case Qt.Key_K:
      case Qt.Key_Up:
        root.navMove(-1);
        break;
      case Qt.Key_L:
      case Qt.Key_Right:
        root.navAdjust(1);
        break;
      case Qt.Key_H:
      case Qt.Key_Left:
        root.navAdjust(-1);
        break;
      case Qt.Key_Return:
      case Qt.Key_Enter:
      case Qt.Key_Space:
        root.navActivate();
        break;
      default:
        // Anything the panel has no use for stays unaccepted.
        return;
      }
      event.accepted = true;
    }
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

  // One closed outline rather than a rounded rectangle: the two top corners
  // are concave, curving outward into the bar's underside so the panel grows
  // out of the bar instead of being butted against it, and the far end keeps
  // the ordinary convex radius. Drawn as a single path so the fill is laid
  // down once -- two overlapping shapes at this alpha would seam.
  //
  // Exactly the bar's fill, down to the alpha: matching only the colour would
  // still read as a different material, because the bar's apparent tone comes
  // from the wallpaper blurred behind it rather than from bg0.
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
