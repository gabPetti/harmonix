pragma Singleton
import QtQuick

// Nerd Font glyphs, in one place. Widgets ask for a glyph by meaning
// ("battery at 40%, charging") instead of pasting a codepoint, so a font
// change only has to be made here.
QtObject {
  readonly property string distro: "󱄅"
  readonly property string search: "󰍉"
  readonly property string apps: "󰀻"
  readonly property string close: "󰅖"
  readonly property string check: "󰄬"
  readonly property string chevronLeft: "󰅁"
  readonly property string chevronRight: "󰅂"
  readonly property string lock: "󰌾"
  readonly property string cpu: "󰍛"
  readonly property string ram: "󰘚"
  readonly property string disk: "󰋊"
  readonly property string calendar: "󰸗"
  readonly property string nightLight: "󰖔"
  readonly property string wallpaper: "󰋩"
  readonly property string wired: "󰈀"
  readonly property string wifiOff: "󰤮"
  readonly property string bluetoothOff: "󰂲"
  readonly property string bluetoothOn: "󰂯"
  readonly property string bluetoothConnected: "󰂱"
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
