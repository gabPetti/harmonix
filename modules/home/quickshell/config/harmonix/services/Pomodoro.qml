pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The focus timer behind the bar's Pomodoro pill: two phases that alternate,
// each with its own length, and a desktop notification whenever one runs out.
//
// A phase never rolls straight into the next one. The notification is the
// whole point of the thing, and a break that started itself while you were
// reading the notification is a break you have already half spent -- so the
// next phase is loaded, stopped, waiting for you to start it.
QtObject {
  id: root

  readonly property string phaseWork: "work"
  readonly property string phaseBreak: "break"

  // Bounds for the editable lengths. A zero-minute phase would expire the
  // instant it started, and the stepper has to stop somewhere at the top.
  readonly property int minMinutes: 1
  readonly property int maxMinutes: 180

  property int workMinutes: 25
  property int breakMinutes: 5

  property string phase: root.phaseWork
  property bool running: false

  // Seconds left in the current phase.
  property int remaining: root.workMinutes * 60

  // When the current phase ends, as ms since the epoch. The countdown is
  // derived from this rather than from counting ticks: a tick the compositor
  // delays (or sleeps through, across a suspend) would otherwise make the
  // timer run long by exactly as much as it was held up.
  property double deadline: 0

  readonly property int phaseSeconds: root.minutesFor(root.phase) * 60
  readonly property string phaseName: root.phase === root.phaseWork ? "Focus" : "Break"
  readonly property real progress: root.phaseSeconds > 0
    ? 1 - root.remaining / root.phaseSeconds
    : 0
  // Minutes are always two digits so the pill keeps its width as the clock
  // runs down -- the bar must not reflow every time a digit is dropped.
  readonly property string label: root.format(root.remaining)

  function minutesFor(which) {
    return which === root.phaseWork ? root.workMinutes : root.breakMinutes;
  }

  function format(seconds) {
    const total = Math.max(0, seconds);
    return `${String(Math.floor(total / 60)).padStart(2, "0")}:${String(total % 60).padStart(2, "0")}`;
  }

  function start() {
    if (root.running)
      return;
    // Starting from an expired clock restarts the phase rather than firing
    // again immediately.
    if (root.remaining <= 0)
      root.remaining = root.phaseSeconds;
    root.deadline = Date.now() + root.remaining * 1000;
    root.running = true;
  }

  function pause() {
    if (!root.running)
      return;
    root.remaining = root.secondsLeft();
    root.running = false;
  }

  function toggle() {
    if (root.running)
      root.pause();
    else
      root.start();
  }

  // Back to the top of the current phase, stopped.
  function reset() {
    root.running = false;
    root.remaining = root.phaseSeconds;
  }

  // Move on without a notification: this is you deciding to cut a phase
  // short, and you hardly need telling that you just did it.
  function skip() {
    root.running = false;
    root.phase = root.phase === root.phaseWork ? root.phaseBreak : root.phaseWork;
    root.remaining = root.phaseSeconds;
  }

  function setMinutes(which, minutes) {
    const clamped = Math.max(root.minMinutes, Math.min(root.maxMinutes, Math.round(minutes)));

    if (which === root.phaseWork)
      root.workMinutes = clamped;
    else
      root.breakMinutes = clamped;

    // A new length only moves the clock for a phase that is sitting idle:
    // rewriting the deadline under a running timer would hand a stray
    // keypress the power to end the session you are in the middle of.
    if (!root.running && root.phase === which)
      root.remaining = root.phaseSeconds;

    root.save();
  }

  function secondsLeft() {
    return Math.max(0, Math.round((root.deadline - Date.now()) / 1000));
  }

  function complete() {
    const finished = root.phase;

    root.running = false;
    root.phase = finished === root.phaseWork ? root.phaseBreak : root.phaseWork;
    root.remaining = root.phaseSeconds;
    root.announce(finished);
  }

  // swaync is the daemon on the other end of this; notify-send is pulled in
  // by modules/home/quickshell/default.nix. Critical urgency because the
  // notification *is* the timer going off -- one that times out on its own
  // while you are heads-down is a timer you didn't hear.
  function announce(finished) {
    const work = finished === root.phaseWork;

    Quickshell.execDetached([
      "notify-send",
      "--app-name=Pomodoro",
      "--urgency=critical",
      "--icon=alarm-symbolic",
      // Collapses onto the previous one instead of stacking a column of
      // expired timers down the corner of the screen.
      "--hint=string:x-canonical-private-synchronous:harmonix-pomodoro",
      work ? "Focus session done" : "Break over",
      work ? `Time for a ${root.breakMinutes} minute break.`
        : `Back to it -- ${root.workMinutes} minutes of focus.`
    ]);
  }

  // A singleton builds its object-typed properties on first access, and
  // nothing reads either of these from outside -- so without this neither the
  // tick nor the saved lengths would ever exist. Same trap as Cava's reader.
  Component.onCompleted: {
    root.store;
    root.ticker;
  }

  // 250ms rather than a second: the readout is derived from the deadline, so
  // this only decides how soon the display catches up with the clock, and at
  // a one-second beat a phase can visibly sit on 00:00 before it fires.
  readonly property Timer ticker: Timer {
    running: root.running
    interval: 250
    repeat: true

    onTriggered: {
      root.remaining = root.secondsLeft();
      if (root.remaining <= 0)
        root.complete();
    }
  }

  // The two lengths outlive the session; nothing else here does. A timer
  // restored mid-phase after a reboot would be counting down against a
  // deadline from before the machine was off.
  readonly property FileView store: FileView {
    id: store

    path: Quickshell.statePath("pomodoro.json")
    preload: true
    // Silent on a missing file: there is none until the lengths are first
    // changed, and a first run shouldn't log an error for that.
    printErrors: false

    onLoaded: {
      try {
        const saved = JSON.parse(store.text());
        root.workMinutes = saved.workMinutes ?? root.workMinutes;
        root.breakMinutes = saved.breakMinutes ?? root.breakMinutes;
        if (!root.running)
          root.remaining = root.phaseSeconds;
      } catch (error) {
        console.warn("Pomodoro: ignoring unreadable pomodoro.json:", error);
      }
    }
  }

  function save() {
    root.store.setText(JSON.stringify({
      workMinutes: root.workMinutes,
      breakMinutes: root.breakMinutes
    }));
  }
}
