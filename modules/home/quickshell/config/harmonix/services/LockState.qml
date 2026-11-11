pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import "../theme"

// Whether the session is locked, the password being typed into it, and the
// PAM conversation that checks it. The surfaces themselves are in lock/ --
// one per monitor, all of them reading this, which is what lets the dots and
// the error appear on every screen while only the focused one has the
// keyboard.
//
// The lock is a Wayland session lock (lock/Lock.qml), so Hyprland holds the
// screen blanked until the surface says otherwise: nothing can be revealed
// by killing the shell, and `allow_session_lock_restore` in
// hyprland/config/default/general.lua is what lets the surface come back if
// the shell is restarted while it is up.
QtObject {
  id: root

  // The compositor's lock, which outlives `unlocking` -- see below.
  property bool locked: false
  // True from a correct password until the exit animation has finished. The
  // surface is still up through it; dropping the lock the instant PAM
  // returned would cut the animation off at its first frame.
  property bool unlocking: false
  // True while PAM has the password and hasn't answered yet.
  readonly property bool busy: root.pam.active
  property string password: ""

  // What the card shows under the field: PAM's own message where there is
  // one, since that is where "password expired" and the like come from.
  property string message: ""
  property bool error: false
  // Only ever counted up, and only to colour the field and to say how many
  // tries have failed -- the lockout itself is PAM's (pam_faildelay and the
  // retry limit), not ours to enforce.
  property int failures: 0

  readonly property string user: Quickshell.env("USER") || "user"
  // Set by the systemd unit from vars.fullName, so the greeting isn't a
  // hardcoded name in a QML file.
  readonly property string fullName: Quickshell.env("HARMONIX_FULL_NAME") || root.user
  readonly property string greeting: {
    const hour = new Date().getHours();
    if (hour < 5) return "Still up?";
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  }

  // The avatar the card shows, or "" for the monogram it falls back to.
  // Probed once at startup rather than handed to an Image to try: an Image
  // pointed at a file that isn't there prints a warning for every monitor,
  // every time the screen locks, and nothing in this repo installs one.
  readonly property string avatarPath: `${Quickshell.env("HOME")}/.face`
  property string avatar: ""

  readonly property Process avatarProbe: Process {
    command: ["test", "-f", root.avatarPath]
    running: true
    onExited: code => root.avatar = code === 0 ? root.avatarPath : ""
  }

  // Modifier state, polled rather than listened for: Hyprland publishes caps
  // lock and the active layout in `hyprctl devices` but emits no event when
  // either changes, and Qt can't see a modifier the surface hasn't been sent.
  property bool capsLock: false
  property string keymap: ""

  signal cleared
  // Every way a password can be turned down, in one signal -- the field
  // shakes on this rather than watching the failure count, because a PAM
  // that refuses to start is as much a rejection as a wrong password and
  // should look like one.
  signal rejected

  // Asks whether the lock can be opened before putting it up; the answer
  // comes back through pamProbe, which is what actually locks.
  function lock(): void {
    if (root.locked) return;
    root.pamProbe.running = true;
  }

  function reset(): void {
    root.password = "";
    root.message = "";
    root.error = false;
    root.failures = 0;
    root.cleared();
  }

  function clearPassword(): void {
    root.password = "";
    root.cleared();
  }

  // Hands the typed password to PAM. `start` opens the conversation; the
  // password itself goes back through `respond` when PAM asks for it, which
  // is the only point at which it is given out.
  //
  // Checked rather than fired and forgotten: a conversation that cannot even
  // be started -- no /etc/pam.d/harmonix-lock, because the system hasn't
  // been rebuilt since this module landed -- reports through the return
  // value and never reaches onCompleted, which would otherwise leave the
  // field looking like it had swallowed the password.
  function submit(): void {
    if (root.busy || root.unlocking || root.password === "")
      return;

    root.error = false;
    root.message = "";

    if (!root.pam.start()) {
      root.fail("Authentication unavailable", false);
    }
  }

  // The one way back out of a submitted password. `countAsFailure` is false
  // for the failures that are the system's rather than the typist's: those
  // should say so without being counted against the attempts.
  function fail(message, countAsFailure): void {
    if (countAsFailure) root.failures++;
    root.error = true;
    root.message = message;
    root.rejected();
    root.clearPassword();
  }

  // Waits out the exit animation and then lets go of the lock. It lives here
  // rather than beside the surfaces in lock/Lock.qml, because that file can
  // hold nothing but the surface component itself, and one timer for the
  // session beats one per monitor.
  readonly property Timer exit: Timer {
    interval: Theme.lockExit
    running: root.unlocking
    onTriggered: root.release()
  }

  // Lets go of the compositor's lock once the surfaces have animated away.
  function release(): void {
    root.locked = false;
    root.unlocking = false;
    root.password = "";
    root.message = "";
    root.error = false;
    root.failures = 0;
  }

  // Whether the PAM service this lock authenticates against exists, asked
  // afresh every time something locks the screen.
  //
  // Checked rather than assumed, because a session lock whose PAM
  // conversation cannot start is one that nothing typed at it will ever
  // open, and the only way out of that is a TTY. The file appears when the
  // system is rebuilt with the module that declares it, which is a thing
  // that can happen while this shell is running -- hence a probe per lock
  // rather than one answer cached at startup. One process to put the screen
  // down is not a cost worth optimising away.
  readonly property string pamPath: "/etc/pam.d/harmonix-lock"

  readonly property Process pamProbe: Process {
    command: ["test", "-f", root.pamPath]

    onExited: code => {
      if (code === 0) {
        root.reset();
        root.locked = true;
        return;
      }

      // hyprlock rather than a lock that cannot be opened -- it is still
      // installed for exactly this, and locking the screen is not something
      // to decline merely because this shell's own lock isn't usable yet.
      console.warn(`LockState: ${root.pamPath} is missing, falling back to hyprlock`);
      Quickshell.execDetached(["hyprlock"]);
    }
  }

  readonly property PamContext pam: PamContext {
    // /etc/pam.d/harmonix-lock, declared by modules/system/hyprland.nix.
    // Its own service rather than borrowing login's: a lock authenticates an
    // already-open session, and should not inherit whatever a future
    // fingerprint or autologin change does to the login stack.
    configDirectory: "/etc/pam.d"
    config: "harmonix-lock"
    user: root.user

    onPamMessage: {
      // The password prompt. Anything else PAM has to say is shown instead,
      // which is how an expiry warning reaches the card.
      if (pam.responseRequired) pam.respond(root.password);
      else if (pam.message !== "") {
        root.message = pam.message;
        root.error = pam.messageIsError;
      }
    }

    onCompleted: result => {
      pam.active = false;

      if (result === PamResult.Success) {
        root.unlocking = true;
        return;
      }

      root.fail(result === PamResult.MaxTries ? "Too many attempts"
        : result === PamResult.Error ? "Authentication unavailable"
        : "Wrong password", result !== PamResult.Error);
    }

    onError: error => {
      pam.active = false;
      root.fail(`PAM: ${PamError.toString(error)}`, false);
    }
  }

  // Both polls only run while the lock is up, so an unlocked session pays
  // nothing for them.
  readonly property Process modifiers: Process {
    command: ["hyprctl", "devices", "-j"]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const keyboards = JSON.parse(text).keyboards ?? [];
          // The built-in keyboard is the one marked main; a plugged-in one
          // reports its own caps state, so an active lock on any of them is
          // worth warning about.
          const main = keyboards.find(keyboard => keyboard.main) ?? keyboards[0];
          root.capsLock = keyboards.some(keyboard => keyboard.capsLock);
          root.keymap = main?.active_keymap ?? "";
        } catch (e) {
          // hyprctl answering with anything but JSON is not worth an error
          // on the lock screen; the indicator just stays as it was.
        }
      }
    }
  }

  readonly property Timer modifierPoll: Timer {
    interval: 300
    running: root.locked
    repeat: true
    triggeredOnStart: true
    onTriggered: root.modifiers.running = true
  }

  // A singleton's object-typed properties are built on first access, so the
  // poll would never start if nothing read it -- see Cava, which has the
  // same problem with its reader.
  Component.onCompleted: {
    root.modifierPoll;
    root.avatarProbe;
    root.exit;
  }
}
