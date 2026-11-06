//@ pragma UseQApplication

// QApplication is required for the system tray's platform menus; without it
// right-clicking a tray icon can't open the app's own menu.

import Quickshell
import Quickshell.Io
import "bar"
import "services"

ShellRoot {
  Variants {
    model: Quickshell.screens

    Bar {
      required property var modelData

      screen: modelData
    }
  }

  // Hyprland keybinds reach a bar panel through this, e.g.
  //   qs -c harmonix ipc call panels toggle bluetooth
  // The id is the panel's own panelId; the one on the focused monitor wins.
  IpcHandler {
    target: "panels"

    function toggle(id: string): void {
      Panels.toggleNamed(id);
    }

    function close(): void {
      Panels.close();
    }
  }

  // Hyprland keybinds reach the launcher through this, e.g.
  //   qs -c harmonix ipc call launcher apps
  IpcHandler {
    target: "launcher"

    function toggle(): void {
      LauncherState.toggle(LauncherState.modeApps);
    }

    function apps(): void {
      LauncherState.open(LauncherState.modeApps);
    }

    function wallpapers(): void {
      LauncherState.open(LauncherState.modeWallpapers);
    }

    function close(): void {
      LauncherState.close();
    }
  }
}
