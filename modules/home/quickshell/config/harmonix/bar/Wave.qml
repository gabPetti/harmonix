import QtQuick
import QtQuick.Shapes
import "../theme"
import "../services"

// The spectrum, drawn as one filled wave hanging from the bar's top edge
// under every pill -- cava's bands as a ceiling the bar hangs from rather
// than as a row of capsules inside the media pill.
//
// Rooted at the top, not standing on the bottom: the fill runs from y = 0
// and a band's level pushes its underside further down, so the wave is a
// single sheet that never lifts off the edge it hangs from.
//
// Placed inside the bar body, which clips it: the wave runs the full width
// and would otherwise square off the bar's rounded ends.
Item {
  id: root

  // Already smoothed by cava, so the wave follows the levels frame for
  // frame; a Behavior on top of that would only add lag at 60fps.
  readonly property var levels: Cava.levels

  // Faded out rather than hidden when nothing is playing: cava stops with
  // the sound, so the levels flatten first and the wave sinks into the bar
  // instead of being cut off mid-peak.
  opacity: Cava.audible ? Theme.waveOpacity : 0

  Behavior on opacity {
    NumberAnimation {
      duration: Theme.animEnter
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.easeStandard
    }
  }

  // The whole outline, in this item's coordinates: the two top corners with
  // the undersides of the bands between them. The corners are part of the
  // list rather than a start point and a closing line around it, because
  // PathPolyline moves to its own first point -- a ShapePath's startX/startY
  // are discarded, and the fill then closed itself along a diagonal from the
  // far corner back to the first band instead of along the bar's top edge.
  //
  // A plain polyline is visibly faceted at this width, so each span between
  // bands is subdivided along a Catmull-Rom spline -- which passes through
  // the bands themselves, so the peaks stay where cava put them.
  readonly property var points: root.buildPoints()

  function buildPoints() {
    const count = Theme.waveBars;
    const levels = root.levels;
    const width = root.width;
    const span = Theme.waveHeight;

    if (width <= 0 || count < 2)
      return [];

    const step = width / (count - 1);
    const bands = [];
    for (let band = 0; band < count; band++) {
      const level = Math.max(0, Math.min(1, levels[band] ?? 0));
      // Measured down from the bar's top edge, with zero *on* it: a silent
      // band has no depth at all, so silence leaves nothing behind rather
      // than a strip of colour along the top.
      bands.push(Qt.point(band * step, span * level));
    }

    // Down the left edge; the matching corner is added after the last band.
    const curve = [Qt.point(0, 0)];
    const divisions = Theme.waveSmoothing;
    for (let segment = 0; segment < count - 1; segment++) {
      // The two bands either side of the span steer the curve through it;
      // at the ends the nearest band stands in for the missing neighbour.
      const before = bands[Math.max(0, segment - 1)];
      const start = bands[segment];
      const end = bands[segment + 1];
      const after = bands[Math.min(count - 1, segment + 2)];

      // A span never leaves the depths of the two bands that bound it.
      // Unclamped, the spline overshoots a loud band's neighbours -- it
      // swings past the root line above (where the clip cuts it off, which
      // is what tore the sheet away from the top edge) and bulges below on
      // the way back, and a spectrum this jagged puts a 0 next to a 100
      // constantly. Clamping leaves the curve monotone across each span, so
      // the only places it changes direction are the bands themselves.
      const shallowest = Math.min(start.y, end.y);
      const deepest = Math.max(start.y, end.y);

      for (let step = 0; step < divisions; step++) {
        const t = step / divisions;
        const t2 = t * t;
        const t3 = t2 * t;

        const depth = 0.5 * (2 * start.y + (end.y - before.y) * t
          + (2 * before.y - 5 * start.y + 4 * end.y - after.y) * t2
          + (-before.y + 3 * start.y - 3 * end.y + after.y) * t3);

        curve.push(Qt.point(
          start.x + (end.x - start.x) * t,
          Math.max(shallowest, Math.min(deepest, depth))));
      }
    }
    curve.push(bands[count - 1]);
    // Back up the right edge. The fill closes the last corner to the first
    // along the top of the bar, which is what roots the sheet to it.
    curve.push(Qt.point(width, 0));

    return curve;
  }

  Shape {
    anchors.fill: parent
    // The curve renderer antialiases in the shader rather than by
    // multisampling the whole item, which is what keeps a shape this wide
    // from costing a full-bar resolve every frame.
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      // Negative rather than zero: a ShapePath strokes in white by default,
      // and only a negative width turns stroking off outright.
      strokeWidth: -1

      // Fixed to the bar, not to the wave: the colour a point is drawn in
      // then depends on how far down it reached, which is what makes the
      // crests read as crests. Tertiary at the root, secondary at the tips.
      fillGradient: LinearGradient {
        x1: 0
        y1: 0
        x2: 0
        y2: Theme.waveHeight

        GradientStop { position: 0; color: Colors.tertiary }
        GradientStop { position: 1; color: Colors.secondary }
      }

      // Both top corners are in `points`, so the polyline is the whole
      // outline: down the left edge, across the bands, back up the right.
      PathPolyline {
        path: root.points
      }
    }
  }
}
