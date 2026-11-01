import QtQuick

// hjkl over whatever interactive pieces a container holds: j and k walk them
// in reading order, h and l drive whatever the selection can adjust (a volume
// or brightness slider), Enter acts on it, q and Escape leave.
//
// A panel whose h and l mean something on their own -- the media panel, where
// they step tracks -- sets `fallbackAdjust`, which takes the keypress
// whenever the selected item has nothing of its own to vary.
//
// A piece joins the walk by declaring `navigable` and a `selected` flag, and
// answering `activate()` or `adjust(direction)` -- see components/ListRow.qml.
// Nothing here knows what any of them are.
Item {
  id: root

  property Item container: null
  property Item current: null
  // function(direction) run when h or l lands on an item that doesn't
  // implement adjust(). Null leaves those keys inert, as before.
  property var fallbackAdjust: null

  signal dismissed

  anchors.fill: parent
  focus: true

  // Rebuilt on every keypress rather than cached: these panels list networks,
  // devices and sinks that appear and disappear underneath the selection.
  function items(): var {
    const found = [];

    const walk = item => {
      for (const child of item.children) {
        if (!child.visible)
          continue;
        // A navigable item is a leaf: a slider row owns its own button and
        // slider, and stopping on each of them separately would make h and l
        // mean one thing on the row and another one item later.
        if (child.navigable === true)
          found.push(child);
        else
          walk(child);
      }
    };

    if (root.container)
      walk(root.container);

    found.sort((a, b) => {
      const pa = a.mapToItem(root.container, 0, 0);
      const pb = b.mapToItem(root.container, 0, 0);
      // Down first, then across -- but only a real difference in y counts as
      // a new row, or two things side by side would sort by a pixel of
      // mismatched baseline.
      return Math.abs(pa.y - pb.y) > 2 ? pa.y - pb.y : pa.x - pb.x;
    });

    return found;
  }

  function select(item: Item): void {
    root.current = item;
    for (const candidate of root.items())
      candidate.selected = candidate === item;
  }

  // Opening a panel puts the cursor on its first item, so j/k and Enter have
  // somewhere to start without a keypress to get there.
  function first(): void {
    const found = root.items();
    root.select(found.length > 0 ? found[0] : null);
  }

  // h and l: the selected item first -- a slider must keep them -- then the
  // panel's own meaning for them.
  function adjust(direction: int): void {
    if (root.current?.adjust)
      root.current.adjust(direction);
    else if (root.fallbackAdjust)
      root.fallbackAdjust(direction);
  }

  function move(delta: int): void {
    const found = root.items();
    if (found.length === 0)
      return;

    const at = found.indexOf(root.current);
    // Nothing selected yet: j starts at the top, k at the end.
    root.select(at === -1 ? found[delta > 0 ? 0 : found.length - 1]
      : found[Math.max(0, Math.min(found.length - 1, at + delta))]);
  }

  Keys.onPressed: event => {
    switch (event.key) {
    case Qt.Key_Escape:
    case Qt.Key_Q:
      root.dismissed();
      break;
    case Qt.Key_J:
    case Qt.Key_Down:
      root.move(1);
      break;
    case Qt.Key_K:
    case Qt.Key_Up:
      root.move(-1);
      break;
    case Qt.Key_L:
    case Qt.Key_Right:
      root.adjust(1);
      break;
    case Qt.Key_H:
    case Qt.Key_Left:
      root.adjust(-1);
      break;
    case Qt.Key_Return:
    case Qt.Key_Enter:
    case Qt.Key_Space:
      root.current?.activate?.();
      break;
    default:
      // Anything the panel has no use for stays unaccepted.
      return;
    }
    event.accepted = true;
  }
}
