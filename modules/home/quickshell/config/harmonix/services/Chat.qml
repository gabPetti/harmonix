pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The bar's chat with Claude, through the Claude Code CLI that is already
// configured on this machine (scripts/chat) -- its credentials, its account,
// no key of the bar's own.
//
// `claude -p --input-format stream-json` is a daemon, so it is held open for
// the life of the shell the way the translator's is (services/Translator.qml
// for why that shape): the conversation lives in that process, which is what
// lets the panel be closed and reopened mid-thread. What is kept here is only
// what the panel draws.
QtObject {
  id: root

  readonly property string script: Quickshell.shellPath("scripts/chat")

  // The CLI says nothing until it is asked something, so there is no startup
  // handshake to wait for: the process being up *is* the ready state, and it
  // only goes down if `claude` is missing or refuses to start.
  property bool ready: false
  property string error: ""

  // The turns already finished, each { role: "user"|"assistant", text }.
  // Replaced wholesale rather than appended to, which is what a Repeater
  // watches for.
  property var messages: []

  // The turn in flight, kept apart from `messages` so that a delta arriving
  // sixty times a second redraws one bubble instead of the whole thread.
  property string streaming: ""
  // Whatever of its reasoning the model chooses to publish, shown only while
  // the turn it belongs to is still coming in. Usually empty -- Claude Code
  // streams thinking blocks with their text omitted -- which is what the
  // panel's "Thinking…" line is there to cover.
  property string thinking: ""

  property bool busy: false
  // Whether the stop that is about to end the turn was asked for. The CLI
  // reports an interrupted turn as a failed one, and a turn the panel stopped
  // on purpose is not a failure to report.
  property bool interrupting: false

  readonly property bool empty: root.messages.length === 0 && !root.busy

  function send(text: string): void {
    const trimmed = text.trim();

    if (trimmed === "" || root.busy)
      return;

    root.error = "";

    if (!root.ready) {
      root.error = "the claude CLI isn't running -- check `qs log` for why";
      return;
    }

    root.messages = root.messages.concat([{ role: "user", text: trimmed }]);
    root.streaming = "";
    root.thinking = "";
    root.busy = true;
    root.interrupting = false;
    root.daemon.write(JSON.stringify({
      type: "user",
      message: { role: "user", content: [{ type: "text", text: trimmed }] }
    }) + "\n");
  }

  // Stop the reply where it is and keep what arrived: a partial answer is
  // often already the answer. The CLI's own interrupt rather than a signal,
  // so the session survives it and the next question still has the thread.
  function cancel(): void {
    if (!root.busy)
      return;

    root.interrupting = true;
    root.daemon.write(JSON.stringify({
      type: "control_request",
      request_id: "interrupt",
      request: { subtype: "interrupt" }
    }) + "\n");
  }

  // A new thread is a new process: the CLI has no message for forgetting a
  // conversation, and it holds this one for as long as it is up.
  function reset(): void {
    root.busy = false;
    root.interrupting = false;
    root.messages = [];
    root.streaming = "";
    root.thinking = "";
    root.error = "";
    root.daemon.running = false;
    root.daemon.running = true;
  }

  // The last thing Claude said, which is what a reply is usually wanted for:
  // a command to run, a snippet to paste.
  function copyLast(): void {
    for (let at = root.messages.length - 1; at >= 0; at--) {
      if (root.messages[at].role !== "assistant")
        continue;

      root.copier.command = ["wl-copy", "--", root.messages[at].text];
      root.copier.running = true;
      return;
    }
  }

  // A singleton builds its object-typed properties on first access, and
  // nothing reads these until they are needed -- without this the daemon
  // would not exist to be started. Same trap services/Translator.qml hits.
  Component.onCompleted: {
    root.daemon;
    root.copier;
  }

  readonly property Process daemon: Process {
    id: daemon

    command: [root.script, "serve"]
    running: true
    stdinEnabled: true

    onRunningChanged: {
      root.ready = daemon.running;
      if (!daemon.running)
        root.busy = false;
    }

    stdout: SplitParser {
      onRead: line => root._handle(line)
    }

    stderr: SplitParser {
      onRead: line => console.log("Chat:", line)
    }

    onExited: (code, status) => {
      // Nothing restarts it from here: it only exits if it crashed or its
      // stdin closed, and a crash loop would be worse than one dead pill.
      // The panel's new-thread button starts a fresh one.
      if (code !== 0 && root.error === "")
        root.error = "the claude CLI stopped (exit " + code + ") -- is it signed in?";
    }
  }

  // One event per line, as `claude -p --output-format stream-json` emits
  // them. Most of what comes past is the CLI narrating a session the panel
  // has no interest in -- init, status, rate limits, the assembled assistant
  // message it is already drawing from deltas -- so the three that matter are
  // picked out and the rest ignored by design.
  function _handle(line: string): void {
    let event;
    try {
      event = JSON.parse(line);
    } catch (error) {
      console.warn("Chat: unreadable event:", line);
      return;
    }

    switch (event.type) {
    case "stream_event":
      root._delta(event.event);
      break;
    case "result": {
      // The turn, either way. `result` carries the final text whole, which
      // is what gets kept: the deltas were for watching it arrive. An
      // interrupted turn carries none, so what was streamed before the stop
      // is what it leaves behind.
      const stopped = root.interrupting;
      const ok = event.subtype === "success" && !event.is_error;

      root.interrupting = false;
      root._settle(ok ? event.result : "");

      if (!ok && !stopped)
        root.error = event.result || `the turn ended as ${event.subtype}`;
      break;
    }
    case "control_response":
      if (event.response?.subtype === "error")
        root.error = event.response.error ?? "the interrupt failed";
      break;
    }
  }

  function _delta(event: var): void {
    if (event?.type !== "content_block_delta")
      return;

    if (event.delta?.type === "thinking_delta") {
      root.thinking += event.delta.thinking;
      return;
    }

    if (event.delta?.type === "text_delta") {
      // The first words of the answer are where the reasoning stops being
      // worth the space it takes in the panel.
      root.thinking = "";
      root.streaming += event.delta.text;
    }
  }

  // Move the finished turn into the thread, where it is one more turn like
  // any other.
  function _settle(text: string): void {
    root.busy = false;
    root.thinking = "";

    const kept = (text || root.streaming).trim();
    if (kept !== "")
      root.messages = root.messages.concat([{ role: "assistant", text: kept }]);

    root.streaming = "";
  }

  readonly property Process copier: Process {
    id: copier
  }
}
