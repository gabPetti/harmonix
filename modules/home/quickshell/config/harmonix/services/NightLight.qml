pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Warm-screen toggle, backed by scripts/nightlight (which owns the hyprsunset
// process and its state file), plus an optional nightly window it turns
// itself on and off in.
QtObject {
  id: root

  readonly property string script: Quickshell.shellPath("scripts/nightlight")

  property bool active: false

  // The schedule. Hours only: the whole point of the window is "after dark",
  // and nobody reaches for a night light at a precision the hour misses.
  property bool scheduled: false
  property int startHour: 21
  property int endHour: 7

  // Whether the clock is inside the window right now. A start past the end
  // is the normal case, not an error -- the window wraps midnight.
  readonly property bool inWindow: root.startHour === root.endHour
    ? false
    : root.startHour < root.endHour
      ? root.hour >= root.startHour && root.hour < root.endHour
      : root.hour >= root.startHour || root.hour < root.endHour

  // Current hour, as a property so `inWindow` re-evaluates when the ticker
  // moves it rather than on whatever happens to re-read it.
  property int hour: new Date().getHours()

  readonly property string windowLabel: `${root.format(root.startHour)} - ${root.format(root.endHour)}`

  function format(hourOfDay) {
    return `${String(hourOfDay).padStart(2, "0")}:00`;
  }

  // The state the schedule wants the screen in, 1 or 0, or -1 for nothing
  // pending. Asked for here and delivered by `flush` a moment later: walking
  // a stepper from 21 down to 14 crosses every hour in between, and each one
  // is a state of its own -- run them all and the screen flicks on and off
  // under you, with whichever hour you actually stopped on no more final
  // than the ones you passed through.
  property int desired: -1

  function apply(on) {
    root.desired = on ? 1 : 0;
    root.applier.restart();
  }

  function flush() {
    if (root.desired === -1)
      return;
    // One run of the script at a time. Reassigning `command` under a running
    // Process is ignored and re-asserting `running` is a no-op, so without
    // this the state meant to land last is precisely the one that gets
    // dropped -- the screen keeps whatever an earlier hour asked for.
    if (root.setter.running)
      return;

    const on = root.desired === 1;
    root.desired = -1;
    root.setter.command = [root.script, on ? "on" : "off"];
    root.setter.running = true;
  }

  function toggle() {
    // Flipping it by hand wins over a schedule change still settling: the
    // switch you just pressed must not be undone a moment later by an hour
    // you were only passing through.
    root.desired = -1;
    root.applier.stop();
    root.held = root.inWindow;
    root.toggler.running = true;
  }

  function setScheduled(enabled) {
    root.scheduled = enabled;
    // Enabling is a request for the window to hold now, not at its next
    // edge -- and disabling leaves the screen as it is, because that is the
    // state you can see and can toggle yourself.
    if (enabled) {
      root.held = root.inWindow;
      root.apply(root.inWindow);
    }
    root.save();
  }

  function setHour(which, value) {
    const wrapped = ((Math.round(value) % 24) + 24) % 24;

    if (which === "start")
      root.startHour = wrapped;
    else
      root.endHour = wrapped;

    if (root.scheduled) {
      root.held = root.inWindow;
      root.apply(root.inWindow);
    }
    root.save();
  }

  // What the schedule last drove the screen to, set rather than bound: only
  // an edge is acted on, so a manual toggle inside the window stays put until
  // the window ends rather than being undone by the next tick.
  property bool held: false

  onInWindowChanged: {
    if (!root.scheduled || root.inWindow === root.held)
      return;
    root.held = root.inWindow;
    root.apply(root.inWindow);
  }

  // A singleton builds its object-typed properties on first access; nothing
  // outside reads these, so without this neither the ticker nor the stored
  // schedule would ever exist. Same trap as Pomodoro's store.
  Component.onCompleted: {
    root.store;
    root.ticker;
    root.query;
    root.applier;
    root.setter;
  }

  // Half a minute: the window only turns on the hour, and this is just how
  // late an edge may be noticed -- including the first one after a resume,
  // which a longer beat would leave the screen cold through.
  readonly property Timer ticker: Timer {
    running: true
    interval: 30000
    repeat: true
    onTriggered: root.hour = new Date().getHours()
  }

  readonly property Process query: Process {
    command: [root.script, "status"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.active = text.trim() === "state=on"
    }
  }

  readonly property Process toggler: Process {
    command: [root.script, "toggle"]
    stdout: StdioCollector {
      onStreamFinished: root.active = text.trim() === "state=on"
    }
  }

  // Settles once the stepper has: long enough that a walk across several
  // hours is one run of the script, short enough that a single nudge still
  // feels like it did something.
  readonly property Timer applier: Timer {
    interval: 400
    onTriggered: root.flush()
  }

  readonly property Process setter: Process {
    stdout: StdioCollector {
      onStreamFinished: root.active = text.trim() === "state=on"
    }
    // A state that arrived while this was running waits for it rather than
    // being dropped.
    onExited: root.flush()
  }

  // The window outlives the session; `active` does not -- the script's state
  // file is the authority on that, and `query` reads it at startup.
  readonly property FileView store: FileView {
    id: store

    path: Quickshell.statePath("nightlight.json")
    preload: true
    // Silent on a missing file: there is none until the schedule is first
    // touched, and a first run shouldn't log an error for that.
    printErrors: false

    onLoaded: {
      try {
        const saved = JSON.parse(store.text());
        root.startHour = saved.startHour ?? root.startHour;
        root.endHour = saved.endHour ?? root.endHour;
        root.scheduled = saved.scheduled ?? root.scheduled;
        if (root.scheduled) {
          root.held = root.inWindow;
          root.apply(root.inWindow);
        }
      } catch (error) {
        console.warn("NightLight: ignoring unreadable nightlight.json:", error);
      }
    }
  }

  function save() {
    root.store.setText(JSON.stringify({
      scheduled: root.scheduled,
      startHour: root.startHour,
      endHour: root.endHour
    }));
  }
}
