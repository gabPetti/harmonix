pragma Singleton
import QtQuick

// Every spatial and typographic constant the shell uses. Widgets never
// hardcode a size, so the whole bar can be rescaled from one place.
QtObject {
  readonly property string font: "JetBrainsMono Nerd Font"

  // The bar nests three rounded containers -- bar body, group, pill -- and
  // each one's height is derived from the one above it, so the insets stay
  // even no matter what barHeight is set to.
  readonly property int barHeight: 40
  // Mirrors Hyprland's general:gaps_out (modules/home/hyprland/config/default/
  // appearance.lua). Keeping the two equal is what makes the bar sit the same
  // distance from the screen edge as the windows beneath it do, and line its
  // sides up with theirs.
  readonly property int barMargin: 8
  readonly property int barRadius: barHeight / 2
  readonly property real barOpacity: 0.82

  // Vertical inset of a group inside the bar body.
  readonly property int barPadding: 4
  // Horizontal inset at the bar's ends. Deliberately larger than barPadding:
  // the ends are a half-circle of barRadius, so a group placed barPadding
  // from the edge would run into the curve instead of clearing it.
  readonly property int barEndPadding: 4

  readonly property int groupHeight: barHeight - barPadding * 2
  readonly property int groupPadding: 3

  readonly property int pillHeight: groupHeight - groupPadding * 2
  readonly property int pillPadding: 10

  // Three distinct gaps, smallest to largest, so grouping reads by distance:
  // within a pill, between pills, between groups.
  readonly property int contentSpacing: 6
  readonly property int pillSpacing: 2
  readonly property int groupSpacing: 8

  readonly property int fontSize: 13
  readonly property int fontSizeSmall: 11
  readonly property int fontSizeLarge: 15
  readonly property int iconSize: 15
  readonly property int iconSizeLarge: 18

  readonly property int popupRadius: 18
  readonly property int popupPadding: 14
  readonly property int popupGap: 8
  readonly property int popupWidth: 300

  readonly property int animFast: 110
  readonly property int animNormal: 190
}
