import QtQuick
import "../theme"
import "../components"
import "../services"

// The bottom-right corner: the one line of instruction on the screen, and the
// count of failed attempts once there have been any.
//
// It fades out as soon as there is a password being typed -- by then it has
// said everything it had to say, and a locked screen should be as quiet as it
// can get away with.
Row {
  id: root

  // 0..1, from LockSurface.stage.
  property real stage: 1

  spacing: Theme.pillSpacing
  opacity: root.stage * (LockState.password === "" ? 1 : 0)
  transform: Translate { y: Theme.lockRise * (1 - root.stage) }

  Behavior on opacity {
    NumberAnimation {
      duration: Theme.animNormal
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.easeStandard
    }
  }

  LockChip {
    visible: LockState.failures > 0
    icon: Icons.lock
    label: LockState.failures === 1
      ? "1 failed attempt"
      : `${LockState.failures} failed attempts`
    tone: Colors.critical
  }

  LockChip {
    icon: Icons.keyboardSymbol
    symbol: true
    label: "Type to unlock  ·  Esc clears"
  }
}
