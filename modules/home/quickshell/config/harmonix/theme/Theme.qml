pragma Singleton
import QtQuick

// Every spatial and typographic constant the shell uses. Widgets never
// hardcode a size, so the whole bar can be rescaled from one place.
QtObject {
  readonly property string font: "JetBrainsMono Nerd Font"
  // Second icon font, used only where a Material Symbol is wanted over a
  // Nerd Font glyph. Installed by modules/core/fonts.nix.
  readonly property string symbolFont: "Material Symbols Rounded"

  // The bar nests three rounded containers -- bar body, group, pill -- and
  // each one's height is derived from the one above it, so the insets stay
  // even no matter what barHeight is set to.
  readonly property int barHeight: 48
  // Mirrors Hyprland's general:gaps_out (default/appearance.lua) -- equal is
  // what lines the bar's sides up with the windows beneath it.
  readonly property int barMargin: 10
  readonly property int barRadius: barHeight / 2
  // Shared with the panels the bar drops (components/BarPopup.qml) rather than
  // each picking its own, which is what keeps the two reading as one surface
  // across a palette change.
  readonly property real barOpacity: 0.9

  // Vertical inset of a group inside the bar body.
  readonly property int barPadding: 5
  // Inset at the bar's ends. The ends are a half-circle of barRadius, so a
  // group placed only barPadding in would run into the curve.
  readonly property int barEndPadding: 5

  readonly property int groupHeight: barHeight - barPadding * 2

  // The bar is flat, so a section is bounded by a hairline. Well short of
  // groupHeight, or it slices the bar across instead of grouping.
  readonly property int dividerHeight: 20

  // Keeps a pill's hover highlight reading as a chip around the content
  // rather than as a block of the bar lighting up.
  readonly property int pillInset: 4
  readonly property int pillHeight: groupHeight - pillInset * 2
  readonly property int pillPadding: 12

  // Workspace dots. The row is drawn at a fixed length -- a dot per
  // workspace up to workspaceCount whether Hyprland has created it or not --
  // so that switching workspaces never shifts everything to its right.
  readonly property int workspaceCount: 5
  readonly property int workspaceDot: 10
  // Empty workspaces read as a smaller dot, the focused one as a stretched
  // one; only the width grows, so the row stays on one centreline.
  readonly property int workspaceDotEmpty: 8
  readonly property int workspaceDotActive: 24
  readonly property int workspaceDotSpacing: 5
  // How far the dots blur back behind a special workspace's name. Capped by
  // the padding around the row, since a layer's blur is clipped to its
  // item's bounds and would otherwise end in a visible straight edge.
  readonly property int workspaceBlur: 12
  // How far the dots drop back while the special workspace's name sits over
  // them. Blur alone leaves the focused dot bright enough to fight the label
  // for the same pixels, since both are drawn in the accent colour.
  readonly property real workspaceSpecialDim: 0.45
  // The chip carrying the special workspace's name. Short of pillHeight so
  // it reads as something laid over the dots rather than as another pill in
  // the group's own lane.
  readonly property int specialChipHeight: fontSizeSmall + pillInset * 2

  // The level rule under a volume/brightness/battery pill. Thin enough to
  // read as an underline rather than as a second background.
  readonly property int levelHeight: 2
  // Clearance between the pill's bottom edge and the rule below it. Has to
  // stay under pillInset or the rule leaves the group's lane.
  readonly property int levelGap: 1

  // Three gaps, smallest to largest, so grouping reads by distance: within a
  // pill, between pills, between groups. With no group backgrounds this
  // spacing is the only thing carrying the grouping.
  readonly property int contentSpacing: 7
  readonly property int pillSpacing: 5
  readonly property int groupSpacing: 14

  readonly property int fontSize: 16
  readonly property int fontSizeSmall: 13
  readonly property int fontSizeLarge: 18
  // Sized against pillHeight, not the text beside them: a glyph's line box
  // runs about 1.3x its pixel size, so this is the largest that still clears
  // its pill. Growing these eats headroom; it can't grow the bar.
  readonly property int iconSize: 22
  readonly property int iconSizeLarge: 24

  // The CPU/RAM/disk dials. The glyph is knocked out of a filled disc
  // (UsageRing), so ringIconSize is a hole, sized to leave a rim of load
  // colour around it -- which is why it isn't just iconSize.
  readonly property int ringSize: 26
  readonly property int ringIconSize: 16
  // Material Symbols are drawn to fill their em square, where a Nerd Font
  // glyph leaves slack around itself -- so the same hole needs a noticeably
  // larger pixelSize in one font than the other.
  readonly property int ringSymbolSize: 20

  readonly property int popupRadius: 22
  // Radius of the concave corners where a panel leaves the bar. The panel is
  // that much wider than its body on each side, the extra being the material
  // that curves out into the bar's underside.
  readonly property int popupFillet: 14
  readonly property int popupPadding: 17
  readonly property int popupGap: 10

  // How far a panel drops to come out flush with the bar. A pill is inset by
  // barPadding + pillInset at the top and the body centres it, so the same
  // figure is what is left underneath.
  // Zero at an integer scale: a panel placed on the body's edge lands on it.
  // Lapping onto the bar covers the hairline fractional scaling rounds into
  // the join, at the cost of a strip where both fills blend and read dark.
  readonly property int popupOverlap: 0
  readonly property int popupAttach: barPadding + pillInset - popupOverlap
  readonly property int popupWidth: 360

  readonly property int animFast: 110
  readonly property int animNormal: 190
  // For things that cover ground: a panel leaving the bar, a dial crossing to
  // a new reading. Split because a panel that takes as long to go as it did
  // to arrive feels like it's dragging.
  readonly property int animEnter: 320
  readonly property int animExit: 200
  // Paced against SystemUsage's 2s sampler rather than against the eye: at
  // animNormal a dial jumps and then sits still for most of the interval,
  // where this keeps it visibly travelling between readings.
  readonly property int animDrift: 900

  // Material 3's emphasized pair as bezierCurve control points, each
  // [x1, y1, x2, y2, 1, 1] -- QML wants the final (1, 1) spelled out. Enter
  // decelerates, which reads as weight; exit is its mirror; standard is the
  // unemphasized version for moves that shouldn't draw attention.
  readonly property var easeEnter: [0.05, 0.7, 0.1, 1.0, 1, 1]
  readonly property var easeExit: [0.3, 0.0, 0.8, 0.15, 1, 1]
  readonly property var easeStandard: [0.2, 0.0, 0.0, 1.0, 1, 1]
}
