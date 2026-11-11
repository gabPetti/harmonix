import QtQuick
import "../theme"
import "../services"

// One monitor's worth of lock screen: the wallpaper pushed back behind a
// drifting colour field, the clock across the top of the content, the
// password card under it, and the media and status readouts in the corners.
//
// Everything in here arrives and leaves off one number, `reveal`. Each block
// takes a slice of it through `stage()`, offset by its position in the order,
// so the screen assembles itself in sequence from one animation instead of
// from seven that have to be kept in step. Reverse it and the same ordering
// takes the screen apart.
Item {
  id: root

  // 0 while the lock is folded away, 1 fully present. Driven by the Behavior
  // below: it is set once on completion, and again when the password is
  // accepted.
  property real reveal: 0

  // How much of the entrance belongs to each block, leaving room for the
  // stagger of the ones after it. Eight stages, so no block is still
  // arriving when the one after it starts.
  readonly property int stages: 8
  readonly property real stageSpan: 1 / root.stages

  // The slice of `reveal` belonging to stage `index`, as its own 0..1.
  // Blocks bind their opacity and their offset to this, so a block is still
  // and invisible until its turn comes round.
  function stage(index) {
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

  Behavior on reveal {
    NumberAnimation {
      duration: LockState.unlocking ? Theme.lockExit : Theme.lockReveal + Theme.lockStagger * root.stages
      easing.type: Easing.BezierSpline
      easing.bezierCurve: LockState.unlocking ? Theme.easeExit : Theme.easeEnter
    }
  }

  LockBackground {
    anchors.fill: parent
    reveal: root.reveal
  }

  Aurora {
    anchors.fill: parent
    opacity: root.stage(0) * Theme.lockAuroraOpacity
  }

  // The clock and the card as one column, centred: the two are read together
  // and should stay on one axis whatever the screen's aspect ratio is.
  Column {
    anchors.centerIn: parent
    spacing: 44

    LockClock {
      anchors.horizontalCenter: parent.horizontalCenter
      timeStage: root.stage(1)
      dateStage: root.stage(2)
    }

    LockCard {
      anchors.horizontalCenter: parent.horizontalCenter
      stage: root.stage(3)
    }
  }

  LockStatus {
    anchors {
      top: parent.top
      right: parent.right
      margins: Theme.lockEdgeMargin
    }
    stage: root.stage(4)
  }

  LockMedia {
    anchors {
      bottom: parent.bottom
      left: parent.left
      margins: Theme.lockEdgeMargin
    }
    stage: root.stage(5)
  }

  // The one line of instruction on the screen, and the last thing to arrive:
  // by then everything it could refer to is already there.
  LockHint {
    anchors {
      bottom: parent.bottom
      right: parent.right
      margins: Theme.lockEdgeMargin
    }
    stage: root.stage(6)
  }
}
