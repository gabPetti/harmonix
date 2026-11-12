import QtQuick
import "../theme"
import "../services"

// One monitor's worth of lock screen: the wallpaper pushed back behind a
// drifting colour field, the clock across the top of the content, the
// password card under it, and the media and status readouts in the corners.
//
// Everything in here arrives and leaves off one number, `reveal`: 0 is the
// desktop and 1 is the lock. Each block takes a slice of it through
// `stage()`, offset by its position in the order, so the screen assembles
// itself in sequence from one animation instead of from six that have to be
// kept in step.
//
// The way out is not that ordering reversed, though, which is what it used
// to be. LockBackground is built so that `reveal` 0 draws the wallpaper
// exactly as hyprpaper draws it on the desktop, and the whole point of the
// exit is to arrive at that frame with nothing else on top of it -- so the
// blocks all have to be gone *before* `reveal` lands, not alongside it. A
// mirrored exit instead put the first block to arrive last out, which meant
// the compositor took the lock down with a clock and a colour field still
// mid-fade over the wallpaper: one frame holding the entire transition's
// worth of jank.
Item {
  id: root

  // 0 while the lock is folded away, 1 fully present. Driven by the Behavior
  // below: it is set once on completion, and again when the password is
  // accepted.
  property real reveal: 0

  // How much of the entrance belongs to each block, leaving room for the
  // stagger of the ones after it. Six stages, so no block is still arriving
  // when the one after it starts.
  readonly property int stages: 6
  readonly property real stageSpan: 1 / root.stages

  // The slice of `reveal` belonging to stage `index`, as its own 0..1.
  // Blocks bind their opacity and their offset to this, so a block is still
  // and invisible until its turn comes round.
  //
  // Leaving, the index is ignored and every block fades together over the
  // leading part of the exit, which hands `Theme.lockExitTail` of it to the
  // backdrop alone. Together rather than in some order of its own: the exit
  // is short, and six blocks each given a sixth of it would be six things
  // flickering rather than one screen being put away.
  function stage(index) {
    if (LockState.unlocking) {
      const tail = Theme.lockExitTail;
      return Math.max(0, Math.min(1, (root.reveal - tail) / (1 - tail)));
    }

    const start = index * root.stageSpan * 0.65;
    return Math.max(0, Math.min(1, (root.reveal - start) / root.stageSpan));
  }

  // Set rather than bound, so the exit can be given its own duration without
  // the binding snapping it back.
  Component.onCompleted: root.reveal = 1

  Connections {
    target: LockState

    function onUnlockingChanged() {
      if (LockState.unlocking) root.reveal = 0;
    }
  }

  // Material's emphasized decelerate in both directions, where the exit used
  // to take the accelerate pair that goes with a thing leaving the screen.
  // Nothing is leaving the screen here: the lock is coming to rest on the
  // desktop's own wallpaper, and the curve has to say so. It also puts the
  // travel where the two phases want it -- most of it spent early, clearing
  // the blocks, and the last of it easing the backdrop into the frame the
  // compositor hands back. An accelerate curve did the opposite, holding
  // near 1 and then dropping through the whole handoff in a rush.
  Behavior on reveal {
    NumberAnimation {
      duration: LockState.unlocking ? Theme.lockExit : Theme.lockReveal + Theme.lockStagger * root.stages
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.easeEnter
    }
  }

  LockBackground {
    anchors.fill: parent
    reveal: root.reveal
  }

  // Part of the backdrop rather than one of the staged blocks: it is a
  // diffuse field with no edges in it, so it has nothing to gain from a
  // stagger slot of its own, and holding it at full until the last eighth of
  // the exit -- which is what a slot did -- left it to snap out in the final
  // few frames before the handoff. On `reveal` it fades with the blur and
  // the dim it belongs to, and the three resolve together.
  Aurora {
    anchors.fill: parent
    opacity: root.reveal * Theme.lockAuroraOpacity
  }

  // The clock and the card as one column, centred: the two are read together
  // and should stay on one axis whatever the screen's aspect ratio is.
  Column {
    anchors.centerIn: parent
    spacing: 44

    LockClock {
      anchors.horizontalCenter: parent.horizontalCenter
      timeStage: root.stage(0)
      dateStage: root.stage(1)
    }

    LockCard {
      anchors.horizontalCenter: parent.horizontalCenter
      stage: root.stage(2)
    }
  }

  LockStatus {
    anchors {
      top: parent.top
      right: parent.right
      margins: Theme.lockEdgeMargin
    }
    stage: root.stage(3)
  }

  LockMedia {
    anchors {
      bottom: parent.bottom
      left: parent.left
      margins: Theme.lockEdgeMargin
    }
    stage: root.stage(4)
  }

  // The one line of instruction on the screen, and the last thing to arrive:
  // by then everything it could refer to is already there.
  LockHint {
    anchors {
      bottom: parent.bottom
      right: parent.right
      margins: Theme.lockEdgeMargin
    }
    stage: root.stage(5)
  }
}
