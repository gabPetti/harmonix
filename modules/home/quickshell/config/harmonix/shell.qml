//@ pragma UseQApplication

// QApplication is required for the system tray's platform menus; without it
// right-clicking a tray icon can't open the app's own menu.

import Quickshell
import Quickshell.Io
import "bar"
import "lock"
import "services"

ShellRoot {
  Variants {
    model: Quickshell.screens

    Bar {
      required property var modelData

      screen: modelData
    }
  }

  // The session lock. One instance for the whole shell -- it builds its own
  // surface per monitor -- and it draws nothing until something locks it.
  Lock {}

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

  // Locking, from the SUPER+Z keybind and from the bar's power panel, e.g.
  //   qs -c harmonix ipc call lock lock
  // There is deliberately no `unlock`: the only way out of the lock is a
  // password through PAM, and an IPC call that skipped that would undo the
  // point of having one.
  IpcHandler {
    target: "lock"

    function lock(): void {
      LockState.lock();
    }

    function locked(): bool {
      return LockState.locked;
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
