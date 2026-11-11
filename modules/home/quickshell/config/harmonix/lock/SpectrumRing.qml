import QtQuick
import "../theme"
import "../services"

// The bar's spectrum, bent into a ring: one band per spoke, standing out from
// a circle instead of hanging from the bar's top edge (bar/Wave.qml). Drawn
// around the lock screen's avatar, which makes the one thing on the screen
// that is always moving also the thing you are looking at while you type.
//
// Same levels, same source, same gate -- Cava only runs while something is
// audible, so a silent lock screen is a ring of dots at rest rather than a
// process woken sixty times a second.
Item {
  id: root

  // Radius of the circle the spokes stand on, i.e. the avatar's own radius
  // plus whatever clearance it should keep.
  property real ringRadius: 0

  // One spoke per band, so a level maps straight onto a spoke with no
  // resampling in between.
  readonly property int count: Theme.waveBars
  readonly property var levels: Cava.levels

  Repeater {
    model: root.count

    // A zero-sized pivot at the centre, rotated into place: the spoke itself
    // is positioned in the pivot's coordinates, so each one only has to know
    // how far out it starts and how long it is.
    Item {
      id: spoke

      required property int index

      // The spectrum is laid clockwise from the top down the right side and
      // mirrored back up the left, so each band owns two opposite spokes:
      // the ring is then symmetrical about the vertical axis, with the bass
      // meeting at the top and the treble at the bottom. Run round once
      // instead and the loudest bands would all crowd one side.
      readonly property int band: spoke.index < root.count / 2
        ? spoke.index
        : root.count - 1 - spoke.index
      // 0..1 across the spectrum, which is what the colour sweep follows --
      // mirrored spokes are the same band and so the same colour.
      readonly property real fraction: spoke.band / (root.count / 2)
      readonly property real level: Math.pow(Math.max(0, Math.min(1, root.levels[spoke.band] ?? 0)), Theme.waveCurve)

      anchors.centerIn: parent
      width: 0
      height: 0
      rotation: spoke.index / root.count * 360

      Rectangle {
        // Standing off the circle rather than crossing it, so the avatar
        // behind it stays a clean disc.
        x: -Theme.lockSpectrumWidth / 2
        y: -root.ringRadius - height
        width: Theme.lockSpectrumWidth
        height: Theme.lockSpectrumFloor + Theme.lockSpectrumReach * spoke.level
        radius: width / 2
        // Swept across the palette the same way the bar's wave is drawn from
        // more than one hue: a ring in a single colour with the length ramped
        // reads as a smear rather than as a spectrum.
        color: Colors.mix(Colors.mix(Colors.accent, Colors.secondary, Math.min(1, spoke.fraction * 2)),
                          Colors.tertiary,
                          Math.max(0, spoke.fraction * 2 - 1))
        opacity: 0.45 + 0.55 * spoke.level

        // Cava has already smoothed the bands, so the spokes follow them
        // frame for frame; this is only enough to round off the step
        // between two frames of a 60Hz feed.
        Behavior on height {
          NumberAnimation { duration: Theme.animFast }
        }
      }
    }
  }
}
