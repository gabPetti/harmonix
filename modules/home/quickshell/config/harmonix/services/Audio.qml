pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

// Default sink/source state straight from PipeWire. Replaces polling `wpctl`:
// changes made anywhere (keys, pavucontrol, another app) land here instantly.
QtObject {
  id: root

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property PwNode source: Pipewire.defaultAudioSource

  readonly property bool ready: root.sink?.ready ?? false
  readonly property real volume: root.sink?.audio?.volume ?? 0
  readonly property bool muted: root.sink?.audio?.muted ?? false
  readonly property real micVolume: root.source?.audio?.volume ?? 0
  readonly property bool micMuted: root.source?.audio?.muted ?? false

  readonly property string sinkName: root.sink?.nickname || root.sink?.description || root.sink?.name || "No output"

  // Every real audio sink, for the output picker in the volume popup.
  readonly property list<var> sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)

  // PipeWire objects only publish volume once something is tracking them.
  readonly property PwObjectTracker tracker: PwObjectTracker {
    objects: [root.sink, root.source]
  }

  function setVolume(value) {
    if (!root.sink?.audio) return;
    root.sink.audio.muted = false;
    root.sink.audio.volume = Math.max(0, Math.min(1, value));
  }

  function adjustVolume(delta) {
    root.setVolume(root.volume + delta);
  }

  function toggleMute() {
    if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted;
  }

  function setMicVolume(value) {
    if (!root.source?.audio) return;
    root.source.audio.muted = false;
    root.source.audio.volume = Math.max(0, Math.min(1, value));
  }

  function toggleMicMute() {
    if (root.source?.audio) root.source.audio.muted = !root.source.audio.muted;
  }

  function setSink(node) {
    Pipewire.preferredDefaultAudioSink = node;
  }
}
