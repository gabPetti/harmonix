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
  // Mirrors Hyprland's general:gaps_out (modules/home/hyprland/config/default/
  // appearance.lua). Keeping the two equal is what makes the bar sit the same
  // distance from the screen edge as the windows beneath it do, and line its
  // sides up with theirs.
  readonly property int barMargin: 10
  readonly property int barRadius: barHeight / 2
  // Shared with the panels the bar drops (components/BarPopup.qml) rather than
  // each picking its own, which is what keeps the two reading as one surface
  // across a palette change.
  readonly property real barOpacity: 0.9

  // Vertical inset of a group inside the bar body.
  readonly property int barPadding: 5
  // Horizontal inset at the bar's ends. Deliberately larger than barPadding:
  // the ends are a half-circle of barRadius, so a group placed barPadding
  // from the edge would run into the curve instead of clearing it.
  readonly property int barEndPadding: 5

  readonly property int groupHeight: barHeight - barPadding * 2

  // The bar is flat -- no filled group containers -- so a section is bounded
  // by a hairline instead. Kept well short of groupHeight so it separates
  // what's beside it rather than slicing the bar across.
  readonly property int dividerHeight: 20

  // A pill's hover highlight shouldn't fill its section's full height --
  // the inset is what keeps the highlight reading as a chip around the
  // content rather than as a block of the bar lighting up.
  readonly property int pillInset: 4
  readonly property int pillHeight: groupHeight - pillInset * 2
  readonly property int pillPadding: 12

  // The level rule under a volume/brightness/battery pill. Thin enough to
  // read as an underline rather than as a second background.
  readonly property int levelHeight: 2
  // Clearance between the pill's bottom edge and the rule below it. Has to
  // stay under pillInset or the rule leaves the group's lane.
  readonly property int levelGap: 1

  // Three distinct gaps, smallest to largest, so grouping reads by distance:
  // within a pill, between pills, between groups. With the group backgrounds
  // gone this spacing is the only thing carrying the grouping, so the two
  // outer steps are wider than they were when a capsule did that work.
  readonly property int contentSpacing: 7
  readonly property int pillSpacing: 5
  readonly property int groupSpacing: 14

  readonly property int fontSize: 16
  readonly property int fontSizeSmall: 13
  readonly property int fontSizeLarge: 18
  // Sized against pillHeight rather than against the text beside them: a
  // glyph's line box runs about 1.3x its pixel size, so this is roughly the
  // largest that still clears the pill it sits in. Everything in the bar is
  // derived from barHeight, so growing these can't grow the bar -- it only
  // eats the headroom inside a pill.
  readonly property int iconSize: 22
  readonly property int iconSizeLarge: 24

  // The CPU/RAM/disk dials. The glyph is knocked out of a filled disc
  // (components/UsageRing.qml), so ringIconSize is a hole rather than text:
  // sized to leave a readable rim of load colour around it, which is why it
  // isn't just iconSize.
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

  // Distance from a pill's bottom edge down to the bar body's bottom edge.
  // A pill is inset from the body by barPadding + pillInset at the top, and
  // the body centres it, so the same figure is what is left underneath --
  // which is exactly how far a panel has to drop to come out flush with the
  // bar instead of floating under the button.
  // No overlap is needed at an integer scale: a panel placed exactly on the
  // body's edge lands on it. It used to lap 2px onto the bar to cover the
  // hairline of wallpaper that fractional scaling rounded into the join --
  // at the cost of a strip where both fills blended and read darker than
  // either surface. Restore it only if a gap ever reappears.
  readonly property int popupOverlap: 0
  readonly property int popupAttach: barPadding + pillInset - popupOverlap
  readonly property int popupWidth: 360

  readonly property int animFast: 110
  readonly property int animNormal: 190
  // For things that have to cover ground: a panel coming out of the bar, a
  // dial crossing to a new reading. Split because arriving and leaving don't
  // deserve the same amount of time -- a panel that takes as long to go as it
  // did to come feels like it's dragging.
  readonly property int animEnter: 320
  readonly property int animExit: 200
  // Paced against SystemUsage's 2s sampler rather than against the eye: at
  // animNormal a dial jumps and then sits still for most of the interval,
  // where this keeps it visibly travelling between readings.
  readonly property int animDrift: 900

  // Material 3's emphasized pair, as bezierCurve control points. The
  // decelerate curve spends most of its run at the end of the move, which is
  // what reads as weight rather than as speed; accelerate is its mirror, for
  // things on their way out. Standard is the unemphasized version, for moves
  // that shouldn't draw attention to themselves.
  //
  // Each is [x1, y1, x2, y2, 1, 1] -- QML wants the final (1, 1) spelled out.
  readonly property var easeEnter: [0.05, 0.7, 0.1, 1.0, 1, 1]
  readonly property var easeExit: [0.3, 0.0, 0.8, 0.15, 1, 1]
  readonly property var easeStandard: [0.2, 0.0, 0.0, 1.0, 1, 1]
}
