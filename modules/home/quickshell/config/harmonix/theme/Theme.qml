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

  // The spectrum, drawn as one wave along the whole bar (bar/Wave.qml)
  // rather than as a row of capsules in the media pill. One band per point,
  // smoothed into a curve by subdividing each span.
  // Bands narrow enough that a peak is a peak rather than a swell: at a
  // quarter of this count each band owned some 30px of a 1080p bar, which
  // rounded the whole spectrum into one rolling ribbon.
  readonly property int waveBars: 48
  readonly property int waveSmoothing: 5
  // How far a full-scale band reaches down the bar from its top edge. Short
  // of barHeight so the loudest peak still leaves the pills a strip of plain
  // background to sit against instead of covering the text outright.
  readonly property real waveHeight: barHeight * 1
  // Applied to each band before it is drawn. Above 1 it holds the quiet
  // bands down while leaving the loud ones where they are, so a peak stands
  // out of the surface instead of riding a swell the whole bar shares.
  readonly property real waveCurve: 1.4
  // The wave is behind every pill in the bar, so it is lit well under the
  // text it passes beneath: this is the level at which it reads as the
  // bar's material moving rather than as something written over it.
  readonly property real waveOpacity: 0.55

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

  // How far the media panel's relative-seek buttons jump, in seconds.
  readonly property int mediaSeekStep: 10

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
  // The in-place number editor's two sizes (components/StepperRow.qml). The
  // field is wide enough for three digits, so a value doesn't shift the
  // buttons either side of it as it grows.
  readonly property int stepperButton: 28
  readonly property int stepperField: 54

  // The translation panel's input box (bar/Translator.qml). Three lines or
  // so at rest -- enough that a pasted paragraph doesn't start out scrolling
  // -- and it grows with the text from there.
  readonly property int translateFieldHeight: 78

  // The pomodoro panel's clock. Deliberately the largest type in the shell:
  // it is the one number the panel exists to show.
  readonly property int pomodoroReadout: 38
  readonly property int pomodoroTrack: 4

  readonly property int popupOverlap: 0
  readonly property int popupAttach: barPadding + pillInset - popupOverlap
  readonly property int popupWidth: 360

  // The launcher panel (launcher/LauncherPanel.qml). Much wider than an
  // ordinary bar panel -- it carries a three-column thumbnail grid -- and a
  // fixed body height, so switching between the two modes doesn't resize the
  // window and the drop animation has one distance to cover either way.
  readonly property int launcherWidth: 820
  readonly property int launcherHeight: 420

  // The lock screen (lock/). Its own scale throughout: the bar is read at a
  // glance from a screen you are already working at, where the lock owns the
  // whole display and is read from wherever you left the laptop.
  readonly property int lockClockSize: 124
  readonly property int lockDateSize: 22
  // The card holding the avatar and the password field. Narrow on purpose --
  // it is one column of content, and a wide one would leave the field
  // stranded in the middle of it.
  readonly property int lockCardWidth: 360
  readonly property int lockCardPadding: 26
  // Rounder than a popup: the card floats free over the wallpaper instead of
  // hanging off an edge, and at this size popupRadius reads as square.
  readonly property int lockRadius: 32
  readonly property int lockAvatar: 104
  // Clearance between the avatar's edge and the foot of the spectrum ring,
  // so a silent ring still reads as a ring around the avatar rather than as
  // a halo touching it.
  readonly property int lockSpectrumGap: 9
  readonly property int lockSpectrumWidth: 3
  // What a band is at rest and how far a full-scale one reaches outward.
  readonly property int lockSpectrumFloor: 4
  readonly property int lockSpectrumReach: 26

  readonly property int lockFieldHeight: 48
  readonly property int lockDotSize: 11
  readonly property int lockDotSpacing: 9
  // Beyond this many characters the dots stop being added rather than
  // overflowing the field -- the row is feedback that a key landed, not a
  // character count.
  readonly property int lockDotMax: 14

  readonly property int lockMediaWidth: 332
  readonly property int lockArtSize: 64
  readonly property int lockEdgeMargin: 36

  // How far the wallpaper is pushed back while the lock is up: 0..1 of
  // MultiEffect's blur, the radius it maps to, and how far the whole image
  // is darkened under it.
  readonly property real lockBlur: 0.75
  readonly property int lockBlurMax: 64
  readonly property real lockDim: 0.36
  // The slow push-in the wallpaper never stops making, as a fraction of its
  // own size. Small enough that it reads as the image breathing rather than
  // as a zoom going somewhere.
  readonly property real lockZoom: 0.06
  readonly property int lockZoomDuration: 40000

  // The drifting colour field behind the content (lock/Aurora.qml): blob
  // diameter, how long one takes to cross its arc, and how much of it is
  // left after the blur.
  readonly property int lockAuroraBlob: 520
  readonly property int lockAuroraDrift: 24000
  readonly property real lockAuroraOpacity: 0.22
  // The field is blurred past all detail, so it is rendered at a fraction of
  // the screen's resolution and scaled up -- a full-resolution gaussian over
  // the whole display, every frame, for an image with no edges in it.
  readonly property int lockAuroraDownscale: 6
  // Multiplies the blur's reach past the radius MultiEffect caps itself at.
  readonly property real lockAuroraSpread: 2.5

  // The entrance: how long one element takes to arrive, how far apart the
  // elements start, and how far they travel on the way in.
  readonly property int lockReveal: 620
  readonly property int lockStagger: 90
  readonly property int lockRise: 28
  // The exit is the entrance in reverse and deliberately quicker: the
  // password was already right, and what follows is the desktop.
  readonly property int lockExit: 360

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
