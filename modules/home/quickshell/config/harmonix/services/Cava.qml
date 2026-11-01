pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../theme"

// Audio spectrum for the bar's visualizer, backed by scripts/visualizer.
//
// Quickshell's PipeWire bindings carry devices, volumes and routes but never
// samples, so there is nothing here to run an FFT over -- cava taps the sink
// monitor itself and this just reads the frames it prints.
QtObject {
  id: root

  readonly property string script: Quickshell.shellPath("scripts/visualizer")
  readonly property int bars: Theme.visualizerBars

  // One entry per bar, 0..1. Shared instance rather than a fresh array, so
  // the flat state doesn't allocate on every stop.
  readonly property var silence: new Array(root.bars).fill(0)

  property var levels: root.silence

  // Tapping the monitor costs a process waking 60 times a second, so it only
  // runs while something is actually audible.
  //
  // The gate is PipeWire rather than MPRIS: a player's reported status is
  // metadata, and Firefox in particular sits at Paused while its audio is
  // plainly coming out of the speakers -- which left the bars flat through a
  // whole track. A link into the sink is the sound itself, and it also
  // catches everything that publishes no MPRIS player at all.
  readonly property PwNodeLinkTracker sinkLinks: PwNodeLinkTracker {
    node: Pipewire.defaultAudioSink
  }

  // A link group reports Unlinked until something binds it, the same way a
  // node reports no volume until tracked.
  readonly property PwObjectTracker linkTracker: PwObjectTracker {
    objects: root.sinkLinks.linkGroups
  }

  // cava reads the sink's *monitor*, and PwNodeLinkTracker leaves monitors
  // out of a sink's groups -- so the reader can't see its own capture here
  // and hold itself open.
  readonly property bool audible: root.sinkLinks.linkGroups
    .some(group => group.state === PwLinkState.Active)

  // A singleton's object-typed properties are built on first access, and
  // nothing else here ever reads the reader -- the widget only wants
  // `levels`. Left alone it would never be constructed, so `running` would
  // never be applied and the bars would sit flat through every track.
  Component.onCompleted: root.reader

  readonly property Process reader: Process {
    id: reader

    command: [root.script, String(root.bars)]
    running: root.audible

    stdout: SplitParser {
      // One frame per line, "<level>;<level>;...;" with levels of 0-100.
      // The trailing delimiter leaves an empty final field, which is why
      // this walks `bars` entries rather than everything the split returns.
      onRead: frame => {
        const fields = frame.split(";");
        const next = [];
        for (let bar = 0; bar < root.bars; bar++)
          next.push(Math.max(0, Math.min(1, (parseInt(fields[bar]) || 0) / 100)));
        root.levels = next;
      }
    }

    // Without this the bars would freeze at whatever was playing when the
    // sound stopped, rather than settling flat.
    onRunningChanged: if (!reader.running) root.levels = root.silence;
  }
}
