pragma Singleton
import QtQuick

// Nerd Font glyphs, in one place. Widgets ask for a glyph by meaning
// ("battery at 40%, charging") instead of pasting a codepoint, so a font
// change only has to be made here.
QtObject {
  readonly property string distro: "󱄅"
  readonly property string search: "󰍉"
  readonly property string apps: "󰀻"
  readonly property string check: "󰄬"
  readonly property string chevronLeft: "󰅁"
  readonly property string chevronRight: "󰅂"
  readonly property string lock: "󰌾"
  readonly property string disk: "󰋊"

  // Material Symbols are ligatures, not codepoints: the font renders the
  // name itself, so these are only meaningful on a Text whose family is
  // Theme.symbolFont. The two names are the ones end-4's bar uses for the
  // same dials (dots-hyprland, modules/ii/bar/Resources.qml).
  readonly property string cpuSymbol: "planner_review"
  readonly property string ramSymbol: "memory"
  // The media panel's relative seek, used when the player publishes no track
  // length to lay a scrub bar over.
  readonly property string seekBackSymbol: "replay_10"
  readonly property string seekForwardSymbol: "forward_10"
  readonly property string calendar: "󰸗"
  readonly property string nightLight: "󰖔"
  readonly property string wallpaper: "󰋩"
  readonly property string download: "󰇚"
  // The wallpaper picker's light/dark switch shows the mode it would move
  // to, so the sun is the button in dark mode and the moon in light mode.
  readonly property string lightMode: "󰖙"
  readonly property string darkMode: "󰖔"
  readonly property string wired: "󰈀"
  readonly property string wifiOff: "󰤮"
  readonly property string bluetoothOff: "󰂲"
  readonly property string bluetoothOn: "󰂯"
  readonly property string bluetoothConnected: "󰂱"
  readonly property string mic: "󰍬"
  readonly property string micMuted: "󰍭"
  readonly property string note: "󰎆"
  readonly property string play: "󰐊"
  readonly property string pause: "󰏤"
  readonly property string next: "󰒭"
  readonly property string previous: "󰒮"
  readonly property string power: "󰐥"
  readonly property string reboot: "󰜉"
  readonly property string suspend: "󰤄"
  readonly property string logout: "󰍃"
  readonly property string lockScreen: "󰌾"
  readonly property string spinner: "󰔛"

  // The pomodoro pill and its panel (bar/Pomodoro.qml), plus the stepper's
  // two nudge buttons. Material Symbols rather than Nerd Font: these are
  // drawn beside each other in one control row, and the two fonts carry
  // visibly different weight at the same pixel size.
  readonly property string timerSymbol: "timer"
  readonly property string focusSymbol: "hourglass_top"
  readonly property string breakSymbol: "coffee"
  readonly property string playSymbol: "play_arrow"
  readonly property string pauseSymbol: "pause"
  readonly property string restartSymbol: "restart_alt"
  readonly property string skipSymbol: "fast_forward"
  readonly property string minus: "remove"
  readonly property string plus: "add"

  // The Claude voice pill (bar/Voice.qml). A Material Symbol for the same
  // reason the pomodoro's is: it sits in the bar next to one.
  readonly property string voiceSymbol: "assistant"
  readonly property string record: "󰑊"
  readonly property string stop: "󰓛"

  readonly property var _battery: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
  readonly property var _batteryCharging: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰂊", "󰂋", "󰂅", "󰂅"]
  readonly property var _wifi: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
  readonly property var _volume: ["󰕿", "󰖀", "󰕾"]
  readonly property var _brightness: ["󰃞", "󰃟", "󰃠"]
  readonly property var _powerProfile: ["󰾆", "󰾅", "󰓅"]

  function battery(percent, charging) {
    const step = Math.max(0, Math.min(10, Math.round(percent / 10)));
    return charging ? _batteryCharging[step] : _battery[step];
  }

  function wifi(strength) {
    const step = Math.max(0, Math.min(4, Math.ceil(strength / 25)));
    return _wifi[step];
  }

  function volume(percent, muted) {
    if (muted) return "󰝟";
    return _volume[_bucket(percent, 3)];
  }

  function brightness(percent) {
    return _brightness[_bucket(percent, 3)];
  }

  // 0 = PowerSaver, 1 = Balanced, 2 = Performance (matches PowerProfile.Enum).
  function powerProfile(profile) {
    return _powerProfile[Math.max(0, Math.min(2, profile))];
  }

  function _bucket(percent, buckets) {
    const index = Math.floor(percent / (100 / buckets));
    return Math.max(0, Math.min(buckets - 1, index));
  }
}
