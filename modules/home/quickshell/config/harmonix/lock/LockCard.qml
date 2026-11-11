import QtQuick
import Quickshell
import Quickshell.Widgets
import "../theme"
import "../components"
import "../services"

// Who is logged in and the field that lets them back in: the avatar with the
// spectrum ring around it, the greeting, the password field, and whatever PAM
// last had to say.
//
// One of these stands on every monitor, all of them reading LockState, so the
// dots and the error appear on each screen while only the focused one's field
// has the keyboard.
Item {
  id: root

  // 0..1, from LockSurface.stage.
  property real stage: 1

  // The ring stands off the avatar, so the card has to be tall enough for
  // the longest spoke on top of it.
  readonly property int ringReach: Theme.lockSpectrumGap + Theme.lockSpectrumFloor + Theme.lockSpectrumReach

  implicitWidth: Theme.lockCardWidth
  implicitHeight: column.implicitHeight

  opacity: root.stage
  transform: [
    Translate { y: Theme.lockRise * (1 - root.stage) },
    // The card is the thing being waited on, so it arrives with a little
    // more than the rise the other blocks get: it grows into place, which at
    // this scale reads as the screen handing it forward.
    Scale {
      origin.x: root.width / 2
      origin.y: root.height / 2
      xScale: 0.96 + 0.04 * root.stage
      yScale: 0.96 + 0.04 * root.stage
    }
  ]

  Column {
    id: column

    width: parent.width
    spacing: 18

    // The avatar and its ring, in a box the ring's full reach wider than the
    // avatar on every side.
    Item {
      anchors.horizontalCenter: parent.horizontalCenter
      implicitWidth: Theme.lockAvatar + root.ringReach * 2
      implicitHeight: implicitWidth

      SpectrumRing {
        anchors.fill: parent
        ringRadius: Theme.lockAvatar / 2 + Theme.lockSpectrumGap
      }

      // A Rectangle's clip is rectangular, so a photograph in one would show
      // square corners over the round frame -- the same reason the launcher's
      // thumbnails and the media panel's art use this.
      ClippingRectangle {
        anchors.centerIn: parent
        implicitWidth: Theme.lockAvatar
        implicitHeight: Theme.lockAvatar
        radius: width / 2
        color: Qt.alpha(Colors.bg1, 0.75)
        border.width: 2
        border.color: Qt.alpha(Colors.accent, 0.5)

        // ~/.face if there is one, the initial if there isn't -- LockState
        // probes for the file rather than letting the Image try and fail,
        // which is why this is empty rather than broken on a machine with no
        // avatar.
        Image {
          id: face

          anchors.fill: parent
          source: LockState.avatar === "" ? "" : `file://${LockState.avatar}`
          fillMode: Image.PreserveAspectCrop
          sourceSize.width: Theme.lockAvatar * 2
          sourceSize.height: Theme.lockAvatar * 2
          asynchronous: true
          visible: face.status === Image.Ready
        }

        StyledText {
          anchors.centerIn: parent
          visible: face.status !== Image.Ready
          text: LockState.fullName.charAt(0).toUpperCase()
          color: Colors.accent
          font.pixelSize: Theme.lockAvatar * 0.42
          font.weight: Font.DemiBold
        }
      }
    }

    Column {
      width: parent.width
      spacing: 2

      StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: LockState.greeting
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
      }

      StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: LockState.fullName
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.DemiBold
      }
    }

    LockField {
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width
    }

    // The message row keeps its height whether there is a message in it or
    // not: the card is centred on the screen, and a row that appeared on the
    // first wrong password would shift the field out from under the cursor
    // mid-typing.
    Item {
      width: parent.width
      implicitHeight: message.implicitHeight

      StyledText {
        id: message

        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        text: LockState.message
        color: LockState.error ? Colors.critical : Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        opacity: text === "" ? 0 : 1

        Behavior on opacity {
          NumberAnimation { duration: Theme.animNormal }
        }
      }
    }

    // Caps lock and the active layout. A wrong-case password with no caps
    // indicator is the one failure a lock screen cannot explain, and the
    // layout matters for the same reason: this keyboard has more than one,
    // and the password was typed on a particular one of them.
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: Theme.pillSpacing

      LockChip {
        visible: LockState.capsLock
        icon: Icons.capsLockSymbol
        symbol: true
        label: "Caps Lock"
        tone: Colors.warning
      }

      LockChip {
        visible: LockState.keymap !== ""
        icon: Icons.keyboardSymbol
        symbol: true
        label: LockState.keymap
      }
    }
  }
}
