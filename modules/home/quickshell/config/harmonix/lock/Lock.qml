import QtQuick
import Quickshell.Wayland
import "../theme"
import "../services"

// The session lock itself, instantiated once from shell.qml.
//
// A WlSessionLock is the compositor's own lock: Hyprland stops compositing
// everything else and shows nothing but these surfaces, so unlike a plain
// fullscreen window there is no stacking order to lose and no way to reveal
// the desktop by killing the shell. It builds its surface component once per
// monitor on its own, which is why there is no Variants here.
//
// Locking and unlocking are two different shapes for that reason: `locked`
// goes true immediately, but a correct password only sets LockState.unlocking
// -- the surfaces are still up, animating away -- and the lock is released a
// beat later, by a timer LockState owns itself.
//
// The surface below is the only thing that can be declared in here:
// WlSessionLock's default property is `surface`, a Component, so any second
// child is assigned to it as well and silently becomes the surface the lock
// tries to build -- which aborts the lock.
WlSessionLock {
  id: lock

  locked: LockState.locked

  WlSessionLockSurface {
    // The surface paints the whole screen itself (LockBackground), so the
    // compositor's own fill is only what shows for the frame before the
    // wallpaper's texture is ready. Black rather than transparent: a session
    // lock with holes in it is a session lock you can read through.
    color: Colors.bg0

    LockSurface {
      anchors.fill: parent
    }
  }
}
