import QtQuick
import QtQuick.Effects
import "../theme"

// Four palette-coloured blobs drifting across the screen, blurred past all
// detail. The lock screen's one piece of pure decoration: it exists so that a
// screen that is otherwise still has something slowly moving on it, and it is
// drawn from the matugen palette so it re-themes with the wallpaper like
// everything else.
//
// Blurred as one field rather than per blob, both because overlapping blobs
// should bleed into each other and because it is one effect pass instead of
// four. The field is also rendered at a fraction of the screen's resolution
// and scaled back up (layer.textureSize): there is nothing in it sharper
// than the blur radius, so a full-resolution gaussian over the whole display
// every frame would be paying for detail that is thrown away.
Item {
  id: root

  readonly property var blobs: [
    { color: Colors.accent, x: 0.22, y: 0.3, span: 0.16, scale: 1.0, period: 1.0 },
    { color: Colors.secondary, x: 0.78, y: 0.26, span: -0.2, scale: 0.85, period: 1.35 },
    { color: Colors.tertiary, x: 0.68, y: 0.74, span: 0.24, scale: 1.15, period: 0.8 },
    { color: Colors.accent, x: 0.3, y: 0.8, span: -0.14, scale: 0.7, period: 1.6 }
  ]

  Item {
    id: field

    anchors.fill: parent
    visible: false
    layer.enabled: true
    layer.smooth: true
    layer.textureSize: Qt.size(Math.max(1, root.width / Theme.lockAuroraDownscale),
                               Math.max(1, root.height / Theme.lockAuroraDownscale))

    Repeater {
      model: root.blobs

      Rectangle {
        id: blob

        required property var modelData
        required property int index

        // 0..1 along this blob's own arc, each one starting at a different
        // point of it so the four never line up.
        property real phase: 0

        width: Theme.lockAuroraBlob * blob.modelData.scale
        height: blob.width
        radius: blob.width / 2
        color: Qt.alpha(blob.modelData.color, 0.55)

        // A lazy figure-of-eight: the blob slides along its span while
        // rising and falling at twice the rate, which reads as wandering
        // rather than as sliding back and forth on a rail.
        x: root.width * (blob.modelData.x + blob.modelData.span * Math.sin(blob.phase * 2 * Math.PI)) - blob.width / 2
        y: root.height * (blob.modelData.y + 0.08 * Math.sin(blob.phase * 4 * Math.PI)) - blob.height / 2

        // Through a full turn rather than out and back: the path already
        // returns to where it started, so there is nothing to snap.
        NumberAnimation on phase {
          running: true
          loops: Animation.Infinite
          from: blob.index / root.blobs.length
          to: blob.index / root.blobs.length + 1
          duration: Theme.lockAuroraDrift * blob.modelData.period
        }
      }
    }
  }

  MultiEffect {
    anchors.fill: parent
    source: field
    blurEnabled: true
    blurMax: Theme.lockBlurMax
    blur: 1
    // Past what blurMax alone can reach: at this scale a blob still has a
    // visible edge to it with the radius capped, and an edge is the one
    // thing a colour field must not have.
    blurMultiplier: Theme.lockAuroraSpread
  }
}
