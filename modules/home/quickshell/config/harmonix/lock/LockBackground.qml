import QtQuick
import QtQuick.Effects
import "../theme"
import "../services"

// The wallpaper, pushed back out of the way: blurred, darkened and slowly
// pushing in, with a gradient down the bottom edge so the media and status
// readouts have something even to sit on.
//
// The same image the desktop is wearing (Wallpapers.current, the symlink
// scripts/wallpaper repoints), not a screenshot of the session the way
// hyprlock took one -- a lock screen that shows your open windows blurred is
// still showing your open windows.
//
// Both the blur and the darkening ride `reveal`, so the wallpaper settles
// back as the content arrives and comes forward again as it leaves. That
// alone is most of what the unlock feels like.
//
// Every one of them -- blur, dim, desaturation, scale, the gradient at the
// foot -- is written so that at `reveal` 0 this item draws the wallpaper
// exactly as hyprpaper is drawing it on the desktop. That is what makes both
// ends of the lock a cut between two identical frames instead of a jump: the
// compositor swaps the lock surface for the session underneath it and the
// wallpaper does not move.
Item {
  id: root

  // 0..1, from LockSurface.
  property real reveal: 0

  // The push-in's own 0..1, driven by the loop below. Separate from `reveal`
  // because the two are multiplied into one scale: this one never stops, and
  // that one only moves when the lock opens or closes.
  property real zoomPhase: 0

  // Drawn into a texture rather than onto the surface, because it is the
  // input to the blur below; `visible: false` hides the unblurred version.
  // Clipped, so the push-in never shows an edge of the screen the image has
  // moved off of.
  Item {
    id: plate

    anchors.fill: parent
    visible: false
    layer.enabled: true
    clip: true

    Image {
      id: wallpaper

      anchors.fill: parent
      source: Wallpapers.current ? `file://${Wallpapers.current}` : ""
      fillMode: Image.PreserveAspectCrop
      // The wallpaper is a full-resolution photograph and this is a
      // full-screen item, so it is read at the screen's size rather than at
      // the file's -- the blur that follows would throw the rest away.
      sourceSize.width: root.width
      sourceSize.height: root.height
      cache: true
      // Decoded on the GUI thread, which is the one thing in this file worth
      // blocking for. ext-session-lock has the compositor blank the session
      // the moment the lock is taken and hold it blank until the surface
      // commits a frame, so an asynchronous load does not save anyone the
      // wait -- it just spends it showing black, and then pops the sharp
      // wallpaper in halfway through the blur animating on. Loading it here
      // costs the shell one decode at lock time and buys a first frame that
      // already matches the desktop.
      asynchronous: false

      // The push-in that never stops, plus a touch more of it that the
      // lock's own arrival adds on top -- and the whole of it multiplied by
      // `reveal`, so a folded-away lock sits at exactly 1. Scaled up out of
      // the desktop's own framing rather than settling back into it: the
      // match at 0 is worth more than the direction the image moves in, and
      // the breathing is a 40s cycle whose phase at lock time is arbitrary,
      // so the arrival needs a push of its own to read at all.
      scale: 1 + Theme.lockZoom * root.reveal * (root.zoomPhase + 0.5 * (1 - root.reveal))

      // Out and back rather than looping from 1 to 0: a scale that jumped
      // back to its start would show as a snap every time round.
      SequentialAnimation {
        running: true
        loops: Animation.Infinite

        NumberAnimation {
          target: root
          property: "zoomPhase"
          to: 1
          duration: Theme.lockZoomDuration
          easing.type: Easing.InOutSine
        }

        NumberAnimation {
          target: root
          property: "zoomPhase"
          to: 0
          duration: Theme.lockZoomDuration
          easing.type: Easing.InOutSine
        }
      }
    }
  }

  MultiEffect {
    anchors.fill: parent
    source: plate
    blurEnabled: true
    blurMax: Theme.lockBlurMax
    blur: Theme.lockBlur * root.reveal
    // Taken down as well as blurred: a blurred photograph is still as bright
    // as the text over it, and the palette matugen drew from this very image
    // has nowhere to stand out against that.
    brightness: -Theme.lockDim * root.reveal
    // Pulled back towards grey by the same amount, which is what keeps the
    // accent colours in the content reading as the brightest thing on the
    // screen.
    saturation: -0.25 * root.reveal
  }

  // The foot of the screen, where the media card and the hint sit. Rising
  // out of the bar's own background colour, so the two corners read as the
  // same material as the shell they replaced.
  Rectangle {
    anchors {
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }
    height: parent.height * 0.4
    opacity: root.reveal

    gradient: Gradient {
      GradientStop { position: 0; color: "transparent" }
      GradientStop { position: 1; color: Qt.alpha(Colors.bg0, 0.75) }
    }
  }
}
