import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Widgets
import "../theme"
import "../components"
import "../services"

// What is playing, bottom-left, with the transport that is safe to leave on a
// locked screen: skip and pause, and nothing that reaches into the session.
//
// Collapses to nothing when no player has anything to say, rather than
// standing there as an empty frame -- the media panel in the bar shows its
// placeholder because a keybind that answers with nothing looks broken, and
// this one answers no keybind.
Rectangle {
  id: root

  // 0..1, from LockSurface.stage.
  property real stage: 1

  readonly property var players: Mpris.players.values
  readonly property var player: root.players.find(candidate => candidate.isPlaying) ?? root.players[0] ?? null
  readonly property bool present: root.player !== null && (root.player.trackTitle ?? "") !== ""

  implicitWidth: Theme.lockMediaWidth
  implicitHeight: Theme.lockArtSize + Theme.popupPadding * 2
  radius: Theme.lockRadius
  color: Qt.alpha(Colors.bg0, Theme.barOpacity)

  visible: opacity > 0
  // Both stages multiplied: the entrance's and the one that tracks whether
  // there is a player at all, so a track starting while the screen is locked
  // fades the card in on its own.
  opacity: root.stage * (root.present ? 1 : 0)
  transform: Translate { y: Theme.lockRise * (1 - root.stage) }

  Behavior on opacity {
    NumberAnimation {
      duration: Theme.animNormal
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.easeStandard
    }
  }

  Row {
    anchors {
      fill: parent
      margins: Theme.popupPadding
    }
    spacing: Theme.popupGap

    // A Rectangle's clip is rectangular, so album art in one would show
    // square corners over the rounded frame.
    ClippingRectangle {
      anchors.verticalCenter: parent.verticalCenter
      implicitWidth: Theme.lockArtSize
      implicitHeight: Theme.lockArtSize
      radius: 12
      color: Qt.alpha(Colors.bg1, 0.7)

      StyledText {
        anchors.centerIn: parent
        visible: art.status !== Image.Ready
        text: Icons.note
        color: Colors.fgDim
        font.pixelSize: 24
      }

      Image {
        id: art

        anchors.fill: parent
        source: root.player?.trackArtUrl ?? ""
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: Theme.lockArtSize * 2
        sourceSize.height: Theme.lockArtSize * 2
        asynchronous: true
      }
    }

    Column {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - Theme.lockArtSize - transport.width - parent.spacing * 2
      spacing: 2

      StyledText {
        width: parent.width
        text: root.player?.trackTitle ?? ""
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.DemiBold
        elide: Text.ElideRight
      }

      StyledText {
        width: parent.width
        visible: text !== ""
        text: root.player?.trackArtist ?? ""
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
        elide: Text.ElideRight
      }
    }

    Row {
      id: transport

      anchors.verticalCenter: parent.verticalCenter
      spacing: 2

      IconButton {
        icon: Icons.previous
        size: 32
        iconSize: Theme.fontSize
        enabled: root.player?.canGoPrevious ?? false
        opacity: enabled ? 1 : 0.4
        onClicked: root.player?.previous()
      }

      IconButton {
        icon: root.player?.isPlaying ? Icons.pause : Icons.play
        size: 36
        active: root.player?.isPlaying ?? false
        enabled: root.player?.canTogglePlaying ?? false
        onClicked: root.player?.togglePlaying()
      }

      IconButton {
        icon: Icons.next
        size: 32
        iconSize: Theme.fontSize
        enabled: root.player?.canGoNext ?? false
        opacity: enabled ? 1 : 0.4
        onClicked: root.player?.next()
      }
    }
  }
}
