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
      asynchronous: true
      cache: true

      // Two scales multiplied: the push-in that never stops, and a touch
      // more of it while the lock is folded away, so the image eases back as
      // the content arrives.
      scale: (1 + Theme.lockZoom * root.zoomPhase) * (1 + Theme.lockZoom * 0.5 * (1 - root.reveal))

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
