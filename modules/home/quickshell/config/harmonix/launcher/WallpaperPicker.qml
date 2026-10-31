import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

// The wallpaper half of the launcher. Unlike the app list there is nothing to
// type here, so the grid holds the keyboard and hjkl moves through it the way
// it moves through a bar panel: h/l by one, j/k by a row. Search is still
// there, behind `/`, and gives the keys back on Enter or Escape.
LauncherCard {
  id: root

  readonly property int columns: 3

  readonly property var results: {
    const query = search.text.trim();
    return query === "" ? Wallpapers.files
      : Fuzzy.rank(Wallpapers.files, path => [Wallpapers.name(path)], query);
  }

  property int selection: 0
  // While true the search field has the keyboard and hjkl are just letters.
  property bool searching: false

  mode: LauncherState.modeWallpapers
  status: Wallpapers.fetching ? "Fetching wallpaper…"
    : Wallpapers.applying ? "Applying wallpaper…"
    : `${root.results.length} wallpaper${root.results.length === 1 ? "" : "s"}`
  hint: root.searching ? "enter done  ·  esc back to grid"
    : "hjkl move  ·  enter apply  ·  / search  ·  f fetch  ·  esc close"

  onResultsChanged: root.selection = 0

  onShownChanged: {
    if (root.shown) {
      search.text = "";
      root.selection = 0;
      root.searching = false;
      Wallpapers.refresh();
      grid.forceActiveFocus();
    }
  }

  function move(delta) {
    const count = root.results.length;
    if (count === 0)
      return;
    root.selection = Math.max(0, Math.min(count - 1, root.selection + delta));
  }

  function activate() {
    const chosen = root.results[root.selection];
    if (!chosen)
      return;
    Wallpapers.apply(chosen);
    LauncherState.close();
  }

  function startSearch() {
    root.searching = true;
    search.forceActiveFocus();
  }

  function endSearch() {
    root.searching = false;
    grid.forceActiveFocus();
  }

  headerContent: RowLayout {
    Layout.fillWidth: true
    spacing: 12

    StyledText {
      text: Icons.wallpaper
      color: Colors.accent
      font.pixelSize: 20
    }

    TextInput {
      id: search

      Layout.fillWidth: true
      color: Colors.fg
      font.family: Theme.font
      font.pixelSize: 18
      selectByMouse: true
      selectionColor: Colors.accent
      selectedTextColor: Colors.accentFg

      // Both ways out of the field hand the keyboard back to the grid; the
      // filter itself stays, so Escape here is "stop typing", not "undo".
      Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Escape:
        case Qt.Key_Return:
        case Qt.Key_Enter:
          root.endSearch();
          break;
        case Qt.Key_Down:
          root.endSearch();
          break;
        default:
          return;
        }
        event.accepted = true;
      }

      StyledText {
        anchors.verticalCenter: parent.verticalCenter
        visible: search.text === "" && !root.searching
        text: "Press / to search…"
        color: Colors.fgDim
        font.pixelSize: 18
      }
    }

    // Pulls a fresh wallpaper off Wallhaven and applies it, so the grid isn't
    // limited to what's already on disk. Also on `f`.
    IconButton {
      icon: Wallpapers.fetching ? Icons.spinner : Icons.download
      active: Wallpapers.fetching
      tooltipText: Wallpapers.fetching ? "Fetching…" : "Fetch a wallpaper from Wallhaven"
      onClicked: Wallpapers.fetch()

      // from: 0 means each spell of fetching starts upright again, so the
      // icon doesn't need resetting when the animation stops.
      RotationAnimation on rotation {
        running: Wallpapers.fetching
        from: 0
        to: 360
        duration: 1200
        loops: Animation.Infinite
      }
    }
  }

  // The grid itself can't hold focus (it is inside the card's content item,
  // and a view steals arrow keys for its own scrolling), so the keys live on
  // a focus scope wrapped around it.
  FocusScope {
    id: grid

    anchors.fill: parent
    focus: !root.searching

    Keys.onPressed: event => {
      switch (event.key) {
      case Qt.Key_H:
      case Qt.Key_Left:
        root.move(-1);
        break;
      case Qt.Key_L:
      case Qt.Key_Right:
        root.move(1);
        break;
      case Qt.Key_J:
      case Qt.Key_Down:
        root.move(root.columns);
        break;
      case Qt.Key_K:
      case Qt.Key_Up:
        root.move(-root.columns);
        break;
      case Qt.Key_G:
        root.selection = event.modifiers & Qt.ShiftModifier ? root.results.length - 1 : 0;
        break;
      case Qt.Key_Return:
      case Qt.Key_Enter:
      case Qt.Key_Space:
        root.activate();
        break;
      case Qt.Key_Slash:
        root.startSearch();
        break;
      case Qt.Key_F:
        Wallpapers.fetch();
        break;
      case Qt.Key_Tab:
        LauncherState.open(LauncherState.modeApps);
        break;
      case Qt.Key_Q:
      case Qt.Key_Escape:
        LauncherState.close();
        break;
      default:
        return;
      }
      event.accepted = true;
    }

    WallpaperResults {
      anchors.fill: parent
      results: root.results
      selection: root.selection
      columns: root.columns
      onPicked: index => {
        root.selection = index;
        root.activate();
      }
    }
  }

  StyledText {
    anchors.centerIn: parent
    width: parent.width
    visible: root.results.length === 0
    text: Wallpapers.files.length === 0 ? `No wallpapers in ${Wallpapers.directory}` : "No matches"
    color: Colors.fgDim
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
  }
}
