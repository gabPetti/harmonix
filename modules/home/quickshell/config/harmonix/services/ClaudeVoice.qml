pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The voice conversation behind the bar's Claude pill: record what you say,
// hand it to scripts/claude-voice, and let that transcribe it, ask the
// `claude` CLI and speak the answer back.
//
// Recording lives here rather than in the script so the pill can show that
// it is listening and how long for; everything after the recording is one
// shell-out, because none of it is state the bar has to watch -- it only
// wants the stages and the two pieces of text that come back.
QtObject {
  id: root

  readonly property string script: Quickshell.shellPath("scripts/claude-voice")

  // Scratch, not a saved recording: the wav only has to survive from the
  // stop click to the transcription. XDG_RUNTIME_DIR is already tmpfs and
  // already cleaned up at logout.
  readonly property string recordingPath:
    `${Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"}/harmonix-claude-voice.wav`

  property bool recording: false

  // How loudly Claude answers, 0-1, and whether it answers out loud at all.
  // Its own level rather than the system volume: the reply plays over
  // whatever you were already listening to.
  property real volume: 0.8
  property bool speechMuted: false
  // What the script is doing, as it reports it: "", "fetching",
  // "transcribing", "thinking" or "speaking". Anything but "" means a turn
  // is still in flight.
  property string stage: ""
  property string transcript: ""
  property string reply: ""
  property string error: ""

  // Seconds of the recording in progress, for the pill's readout.
  property int elapsed: 0

  // mm:ss, two digits either side, so the pill keeps its width as it counts.
  readonly property string label:
    `${String(Math.floor(root.elapsed / 60)).padStart(2, "0")}:${String(root.elapsed % 60).padStart(2, "0")}`

  readonly property bool busy: root.stage !== ""
  readonly property bool active: root.recording || root.busy

  readonly property string stageLabel: root.stage === "fetching" ? "Fetching models"
    : root.stage === "transcribing" ? "Transcribing"
    : root.stage === "thinking" ? "Thinking"
    : root.stage === "speaking" ? "Speaking"
    : root.recording ? "Listening"
    : "Idle"

  function start() {
    if (root.recording || root.busy)
      return;

    root.transcript = "";
    root.reply = "";
    root.error = "";
    root.elapsed = 0;
    root.recording = true;
    root.recorder.running = true;
  }

  // Stopping is what sends the turn: a recording nobody asked about is just
  // a wav in the runtime directory.
  function stop() {
    if (!root.recording)
      return;

    root.recording = false;
    // SIGTERM, which pw-record handles -- it closes the file through
    // libsndfile on the way out, and that is what writes the real length
    // into the WAV header. Killed outright, the recording would claim to be
    // zero samples long and whisper would hear nothing.
    root.recorder.running = false;
  }

  function toggle() {
    if (root.recording)
      root.stop();
    else
      root.start();
  }

  function setVolume(value) {
    root.volume = Math.max(0, Math.min(1, value));
    // Moving the slider off zero is the same gesture as unmuting; leaving it
    // muted would make the slider look broken.
    root.speechMuted = false;
    root.save();
  }

  function toggleSpeech() {
    root.speechMuted = !root.speechMuted;
    root.save();
  }

  // A singleton builds its object-typed properties on first access, and the
  // pill reads none of these directly -- without this the recorder would not
  // exist to be started. Same trap as Cava's reader.
  Component.onCompleted: {
    root.recorder;
    root.asker;
    root.ticker;
    root.store;
  }

  // The level outlives the session; nothing else here does.
  readonly property FileView store: FileView {
    id: store

    path: Quickshell.statePath("claude-voice.json")
    preload: true
    // Silent on a missing file: there is none until the level is first
    // changed, and a first run shouldn't log an error for that.
    printErrors: false

    onLoaded: {
      try {
        const saved = JSON.parse(store.text());
        root.volume = saved.volume ?? root.volume;
        root.speechMuted = saved.speechMuted ?? root.speechMuted;
      } catch (error) {
        console.warn("ClaudeVoice: ignoring unreadable claude-voice.json:", error);
      }
    }
  }

  function save() {
    root.store.setText(JSON.stringify({
      volume: root.volume,
      speechMuted: root.speechMuted
    }));
  }

  readonly property Timer ticker: Timer {
    running: root.recording
    interval: 1000
    repeat: true
    onTriggered: root.elapsed++
  }

  // 16kHz mono s16 because that is the only thing whisper takes; anything
  // else it would have to resample first.
  readonly property Process recorder: Process {
    id: recorder

    command: [
      "pw-record",
      "--rate", "16000",
      "--channels", "1",
      "--format", "s16",
      root.recordingPath
    ]

    onExited: (code, status) => {
      // A recording that ended on its own -- no source, or the device went
      // away -- never reached stop(), so there is nothing worth asking about.
      if (root.recording) {
        root.recording = false;
        root.error = "the microphone stopped recording";
        return;
      }

      // Too short to be speech. whisper would return an empty transcript
      // after several seconds of work, which reads as the feature being
      // broken rather than as a misclick.
      if (root.elapsed < 1) {
        root.error = "that was too short to hear";
        return;
      }

      root.stage = "transcribing";
      root.asker.running = true;
    }
  }

  readonly property Process asker: Process {
    id: asker

    // Zero is how the script is told to answer silently -- it skips the
    // synthesis too, rather than playing it at no volume.
    command: [
      root.script,
      "ask",
      root.recordingPath,
      String(root.speechMuted ? 0 : root.volume)
    ]

    // One `key value` line per step; see the script's header.
    stdout: SplitParser {
      onRead: line => {
        const at = line.indexOf(" ");
        const key = at === -1 ? line : line.slice(0, at);
        const value = at === -1 ? "" : line.slice(at + 1);

        if (key === "stage")
          root.stage = value;
        else if (key === "transcript")
          root.transcript = value;
        else if (key === "reply")
          root.reply = value;
        else if (key === "error")
          root.error = value;
      }
    }

    stderr: SplitParser {
      onRead: line => console.warn("ClaudeVoice:", line)
    }

    // The stage only clears here, not on the last line the script printed:
    // speaking is the one stage that outlasts its own announcement, and the
    // pill should keep saying so until the voice has actually finished.
    onExited: (code, status) => {
      root.stage = "";
      if (code !== 0 && root.error === "")
        root.error = "the voice helper exited with code " + code;
    }
  }
}
