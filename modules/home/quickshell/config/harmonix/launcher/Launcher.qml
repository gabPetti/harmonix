import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../theme"
import "../components"
import "../services"

// Fullscreen overlay replacing `rofi -show drun` and the rofi wallpaper menu.
// Mapped only while open, and takes exclusive keyboard focus so typing lands
// here rather than in the window underneath.
PanelWindow {
  id: root

  readonly property string terminal: "kitty"

  readonly property bool wallpaperMode: LauncherState.mode === LauncherState.modeWallpapers
  readonly property int columns: 3
  // How far one Up/Down press moves: a whole row in the wallpaper grid.
  readonly property int rowStep: root.wallpaperMode ? root.columns : 1

  readonly property var appEntries: DesktopEntries.applications.values.filter(entry => !entry.noDisplay)

  readonly property var results: {
    const query = search.text.trim();

    if (root.wallpaperMode) {
      return query === "" ? Wallpapers.files
        : root.rank(Wallpapers.files, path => [Wallpapers.name(path)], query);
    }

    const alphabetical = root.appEntries.slice().sort((a, b) => a.name.localeCompare(b.name));
    return query === "" ? alphabetical
      : root.rank(alphabetical, entry => root.appFields(entry), query).slice(0, 60);
  }

  property int selection: 0

  visible: LauncherState.opened
  screen: Quickshell.screens.find(candidate => candidate.name === Hyprland.focusedMonitor?.name)
    ?? Quickshell.screens[0]
    ?? null

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"
  exclusionMode: ExclusionMode.Ignore

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "quickshell:launcher"
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  onResultsChanged: root.selection = 0

  onVisibleChanged: {
    if (root.visible) {
      root.reset();
      card.opacity = 1;
      card.scale = 1;
    } else {
      card.opacity = 0;
      card.scale = 0.97;
    }
  }

  function reset() {
    search.text = "";
    root.selection = 0;
    search.forceActiveFocus();
    if (root.wallpaperMode) Wallpapers.refresh();
  }

  function move(delta) {
    const count = root.results.length;
    if (count === 0) return;
    root.selection = Math.max(0, Math.min(count - 1, root.selection + delta));
  }

  function activate() {
    const chosen = root.results[root.selection];
    if (!chosen) return;

    if (root.wallpaperMode) Wallpapers.apply(chosen);
    else root.launch(chosen);

    LauncherState.close();
  }

  // DesktopEntry.execute() runs the command as-is, which means anything
  // declaring Terminal=true (btop, nvim, yazi, vim) starts with no terminal
  // attached and dies immediately. Those get one.
  function launch(entry) {
    if (entry.runInTerminal) {
      Quickshell.execDetached([root.terminal, "-e"].concat(entry.command));
    } else {
      entry.execute();
    }
  }

  function appFields(entry) {
    return [entry.name, entry.genericName, entry.id].concat(entry.keywords ?? []);
  }

  function rank(items, fields, query) {
    const scored = [];
    for (const item of items) {
      const score = Fuzzy.scoreAny(fields(item), query);
      if (score > 0) scored.push({ item, score });
    }
    scored.sort((a, b) => b.score - a.score);
    return scored.map(entry => entry.item);
  }

  Connections {
    target: LauncherState

    // Switching mode with the launcher already open starts a fresh query.
    function onModeChanged() {
      if (root.visible) root.reset();
    }
  }

  Rectangle {
    anchors.fill: parent
    color: Qt.alpha(Colors.shadow, 0.5)
    opacity: card.opacity

    MouseArea {
      anchors.fill: parent
      onClicked: LauncherState.close()
    }
  }

  Rectangle {
    id: card

    anchors.horizontalCenter: parent.horizontalCenter
    y: Math.round(parent.height * 0.13)
    width: Math.min(700, parent.width - 80)
    height: Math.min(540, Math.round(parent.height * 0.64))
    radius: 24
    color: Colors.bg0
    border.width: 1
    border.color: Colors.outlineSoft
    opacity: 0
    scale: 0.97

    Behavior on opacity {
      NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }

    Behavior on scale {
      NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 10

      RowLayout {
        Layout.fillWidth: true
        spacing: 12

        StyledText {
          text: root.wallpaperMode ? Icons.wallpaper : Icons.search
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
              event.accepted = true;
              break;
            case Qt.Key_Return:
            case Qt.Key_Enter:
              root.activate();
              event.accepted = true;
              break;
            case Qt.Key_Up:
              root.move(-root.rowStep);
              event.accepted = true;
              break;
            case Qt.Key_Down:
              root.move(root.rowStep);
              event.accepted = true;
              break;
            case Qt.Key_Tab:
              LauncherState.open(root.wallpaperMode ? LauncherState.modeApps : LauncherState.modeWallpapers);
              event.accepted = true;
              break;
            case Qt.Key_Left:
              if (root.wallpaperMode) {
                root.move(-1);
                event.accepted = true;
              }
              break;
            case Qt.Key_Right:
              if (root.wallpaperMode) {
                root.move(1);
                event.accepted = true;
              }
              break;
            case Qt.Key_J:
              if (event.modifiers & Qt.ControlModifier) {
                root.move(root.rowStep);
                event.accepted = true;
              }
              break;
            case Qt.Key_K:
              if (event.modifiers & Qt.ControlModifier) {
                root.move(-root.rowStep);
                event.accepted = true;
              }
              break;
            }
          }

          StyledText {
            anchors.verticalCenter: parent.verticalCenter
            visible: search.text === ""
            text: root.wallpaperMode ? "Search wallpapers…" : "Search applications…"
            color: Colors.fgDim
            font.pixelSize: 18
          }
        }

        ModeChip {
          label: "Apps"
          active: !root.wallpaperMode
          onClicked: LauncherState.open(LauncherState.modeApps)
        }

        ModeChip {
          label: "Walls"
          active: root.wallpaperMode
          onClicked: LauncherState.open(LauncherState.modeWallpapers)
        }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Colors.outlineSoft
      }

      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Loader {
          anchors.fill: parent
          sourceComponent: root.wallpaperMode ? wallpaperView : appView
        }

        StyledText {
          anchors.centerIn: parent
          width: parent.width
          visible: root.results.length === 0
          text: root.wallpaperMode && Wallpapers.files.length === 0
            ? `No wallpapers in ${Wallpapers.directory}`
            : "No matches"
          color: Colors.fgDim
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.Wrap
        }
      }

      RowLayout {
        Layout.fillWidth: true

        StyledText {
          text: Wallpapers.applying ? "Applying wallpaper…"
            : `${root.results.length} result${root.results.length === 1 ? "" : "s"}`
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
        }

        Item {
          Layout.fillWidth: true
        }

        StyledText {
          text: "enter open  ·  tab switch mode  ·  esc close"
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
        }
      }
    }
  }

  // `results` and the Loader's component both depend on the mode, and QML
  // doesn't promise which re-evaluates first -- so each view takes its results
  // only while its own mode is active, and never sees the other kind of entry.
  Component {
    id: appView

    AppResults {
      results: root.wallpaperMode ? [] : root.results
      selection: root.selection
      onPicked: index => {
        root.selection = index;
        root.activate();
      }
    }
  }

  Component {
    id: wallpaperView

    WallpaperResults {
      results: root.wallpaperMode ? root.results : []
      selection: root.selection
      columns: root.columns
      onPicked: index => {
        root.selection = index;
        root.activate();
      }
    }
  }
}
