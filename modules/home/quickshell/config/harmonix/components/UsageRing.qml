import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "../theme"

// The resource indicator end-4's bar uses: not a stroked ring but a filled
// disc with the load swept out of it as a pie wedge, and the glyph knocked
// *out* of that -- so the icon reads as a hole and the load is the solid area
// behind it. At this size that's the whole point: a stroked ring with a glyph
// beside it would be two competing shapes in 20 pixels, where this is one.
Item {
  id: root

  // 0..1, not a percentage -- the wedge is an angle, so the caller converting
  // once here keeps the arithmetic out of the shape.
  property real value: 0
  property string icon: ""
  property color color: Colors.fg
  // Whether `icon` is a Material Symbols ligature rather than a Nerd Font
  // codepoint. Switches the font, its size, and the weight axis with it.
  property bool symbol: false

  // The unfilled remainder. Struck from `color` rather than given its own
  // token so the indicator stays monochrome whatever palette matugen lands
  // on, and so the warning colours carry through to it for free.
  property color trackColor: Qt.alpha(root.color, 0.25)

  implicitWidth: Theme.ringSize
  implicitHeight: Theme.ringSize

  // Animate the swept angle rather than `value`: the arc then eases on its
  // own clock instead of stepping with however often SystemUsage polls.
  property real sweep: Math.max(0, Math.min(1, root.value)) * 360

  Behavior on sweep {
    NumberAnimation {
      duration: Theme.animDrift
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.easeStandard
    }
  }

  // Drawn into a texture rather than onto the bar, because it is the input to
  // the mask below; `visible: false` hides the untouched version.
  Item {
    id: disc

    anchors.fill: parent
    visible: false
    layer.enabled: true
    layer.smooth: true

    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: root.trackColor
    }

    Shape {
      anchors.fill: parent
      // The default renderer flattens a 20px arc into visible facets; the
      // curve renderer keeps the wedge's edge round at this size.
      preferredRendererType: Shape.CurveRenderer

      ShapePath {
        id: wedge

        strokeWidth: -1
        fillColor: root.color
        startX: disc.width / 2
        startY: disc.height / 2

        PathAngleArc {
          moveToStart: false
          centerX: disc.width / 2
          centerY: disc.height / 2
          radiusX: disc.width / 2
          radiusY: disc.height / 2
          // Noon, so the wedge fills clockwise from the top the way a dial does.
          startAngle: -90
          sweepAngle: root.sweep
        }

        // Back to the centre, closing the wedge into a pie slice.
        PathLine {
          x: wedge.startX
          y: wedge.startY
        }
      }
    }
  }

  // Only this glyph's alpha is ever used -- as the stencil for the hole, never
  // as drawn text. Its colour is therefore irrelevant.
  Item {
    id: stencil

    anchors.fill: parent
    visible: false
    layer.enabled: true
    layer.smooth: true

    StyledText {
      anchors.centerIn: parent
      text: root.icon
      font.family: root.symbol ? Theme.symbolFont : Theme.font
      font.pixelSize: root.symbol ? Theme.ringSymbolSize : Theme.ringIconSize
      // Nerd Font glyphs are thin enough at this size that the hole closes
      // up without the extra weight; Material Symbols carry their weight on
      // the FILL axis instead, where bolding would only smear the outline.
      font.bold: !root.symbol
      font.variableAxes: root.symbol ? ({ "FILL": 1, "opsz": Theme.ringSymbolSize }) : ({})
    }
  }

  MultiEffect {
    anchors.fill: parent
    source: disc
    maskEnabled: true
    maskSource: stencil
    maskInverted: true
    // Text alpha ramps across the glyph's antialiased edge. Cutting at half
    // coverage keeps the hole the glyph's true width, and the narrow spread
    // keeps that cut from turning into a staircase.
    maskThresholdMin: 0.45
    maskSpreadAtMin: 0.3
  }
}
