import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../components"
import "../services"

// The application half of the launcher, replacing `rofi -show drun`. Typing
// is the point here, so the search field keeps the focus and navigation is on
// the arrow keys (or Ctrl+J/K) -- the wallpaper picker, where there is
// nothing to type, is the one that gets plain hjkl.
LauncherPane {
  id: root

  readonly property string terminal: "kitty"

  readonly property var entries: DesktopEntries.applications.values.filter(entry => !entry.noDisplay)

  readonly property var results: {
    const query = search.text.trim();
    const alphabetical = root.entries.slice().sort((a, b) => a.name.localeCompare(b.name));

    return query === "" ? alphabetical
      : Fuzzy.rank(alphabetical, entry => root.fields(entry), query).slice(0, 60);
  }

  property int selection: 0

  mode: LauncherState.modeApps
  status: `${root.results.length} result${root.results.length === 1 ? "" : "s"}`
  hint: "enter open  ·  tab switch mode  ·  esc close"

  onResultsChanged: root.selection = 0

  onShownChanged: {
    if (root.shown) {
      search.text = "";
      root.selection = 0;
      search.forceActiveFocus();
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
    root.launch(chosen);
    LauncherState.close();
  }

  // DesktopEntry.execute() runs the command as-is, which means anything
  // declaring Terminal=true (btop, nvim, yazi, vim) starts with no terminal
  // attached and dies immediately. Those get one.
  function launch(entry) {
    if (entry.runInTerminal)
      Quickshell.execDetached([root.terminal, "-e"].concat(entry.command));
    else
      entry.execute();
  }

  function fields(entry) {
    return [entry.name, entry.genericName, entry.id].concat(entry.keywords ?? []);
  }

  headerContent: RowLayout {
    Layout.fillWidth: true
    spacing: 12

    StyledText {
      text: Icons.search
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
      focus: true

      Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Escape:
          LauncherState.close();
          break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
          root.activate();
          break;
        case Qt.Key_Up:
          root.move(-1);
          break;
        case Qt.Key_Down:
          root.move(1);
          break;
        case Qt.Key_Tab:
          LauncherState.open(LauncherState.modeWallpapers);
          break;
        // j and k are letters in a field you are typing into, so they only
        // navigate with Ctrl held.
        case Qt.Key_J:
          if (!(event.modifiers & Qt.ControlModifier))
            return;
          root.move(1);
          break;
        case Qt.Key_K:
          if (!(event.modifiers & Qt.ControlModifier))
            return;
          root.move(-1);
          break;
        default:
          return;
        }
        event.accepted = true;
      }

      StyledText {
        anchors.verticalCenter: parent.verticalCenter
        visible: search.text === ""
        text: "Search applications…"
        color: Colors.fgDim
        font.pixelSize: 18
      }
    }
  }

  AppResults {
    anchors.fill: parent
    results: root.results
    selection: root.selection
    onPicked: index => {
      root.selection = index;
      root.activate();
    }
  }

  StyledText {
    anchors.centerIn: parent
    width: parent.width
    visible: root.results.length === 0
    text: "No matches"
    color: Colors.fgDim
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
  }
}
