pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower

// Session actions and the battery the bar should display.
QtObject {
  id: root

  readonly property UPowerDevice battery: UPower.displayDevice
  readonly property bool hasBattery: root.battery?.isLaptopBattery ?? false
  readonly property bool charging: root.battery?.state === UPowerDeviceState.Charging
    || root.battery?.state === UPowerDeviceState.FullyCharged
  readonly property real percent: root.battery?.percentage ?? 0
  readonly property bool low: root.hasBattery && !root.charging && root.percent <= 20
  readonly property bool critical: root.hasBattery && !root.charging && root.percent <= 10

  // Seconds until empty/full, 0 when UPower hasn't estimated one yet.
  readonly property int secondsRemaining: root.charging
    ? (root.battery?.timeToFull ?? 0)
    : (root.battery?.timeToEmpty ?? 0)

  function profileName(profile) {
    switch (profile) {
      case PowerProfile.PowerSaver: return "Power saver";
      case PowerProfile.Performance: return "Performance";
      default: return "Balanced";
    }
  }

  function setProfile(profile) {
    PowerProfiles.profile = profile;
  }

  function cycleProfile() {
    const order = PowerProfiles.hasPerformanceProfile
      ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
      : [PowerProfile.PowerSaver, PowerProfile.Balanced];
    const next = (order.indexOf(PowerProfiles.profile) + 1) % order.length;
    PowerProfiles.profile = order[next];
  }

  function formatDuration(seconds) {
    if (!seconds || seconds <= 0) return "";
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
  }

  function lock() {
    Quickshell.execDetached(["hyprlock"]);
  }

  function logout() {
    Hyprland.dispatch("exit");
  }

  function suspend() {
    Quickshell.execDetached(["systemctl", "suspend"]);
  }

  function reboot() {
    Quickshell.execDetached(["systemctl", "reboot"]);
  }

  function shutdown() {
    Quickshell.execDetached(["systemctl", "poweroff"]);
  }
}
