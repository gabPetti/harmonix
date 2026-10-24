import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import "../theme"
import "../components"

// Now-playing readout over MPRIS. Prefers whichever player is actually
// playing, so pausing Spotify to watch a video follows the video.
BarPill {
  id: root

  readonly property var players: Mpris.players.values
  readonly property var player: root.players.find(candidate => candidate.isPlaying) ?? root.players[0] ?? null
  readonly property string label: !root.player ? ""
    : root.player.trackArtist ? `${root.player.trackArtist} — ${root.player.trackTitle}`
    : (root.player.trackTitle || root.player.identity)

  // MPRIS position is only recomputed when read, so sample it while the popup
  // is open rather than binding to it.
  property real position: 0

  visible: root.player !== null
  active: popup.visible
  tooltipText: root.player ? `${root.label}\n${root.player.identity}` : ""

  onClicked: popup.toggle()
  onMiddleClicked: root.player?.togglePlaying()
  onScrolled: direction => {
    if (direction > 0) root.player?.next();
    else root.player?.previous();
  }

  function formatTime(seconds) {
    if (!isFinite(seconds) || seconds < 0) return "0:00";
    const total = Math.floor(seconds);
    const minutes = Math.floor(total / 60);
    return `${minutes}:${String(total % 60).padStart(2, "0")}`;
  }

  Timer {
    interval: 1000
    running: popup.visible && (root.player?.isPlaying ?? false)
    repeat: true
    triggeredOnStart: true
    onTriggered: root.position = root.player?.position ?? 0
  }

  StyledText {
    text: Icons.note
    color: root.player?.isPlaying ? Colors.accent : Colors.fgDim
    font.pixelSize: Theme.iconSize
  }

  StyledText {
    Layout.maximumWidth: 190
    text: root.label
    elide: Text.ElideRight
  }

  BarPopup {
    id: popup

    anchorItem: root
    contentWidth: 320

    RowLayout {
      Layout.fillWidth: true
      spacing: 12

      // Same reason as the wallpaper grid: a Rectangle's clip is rectangular,
      // so album art would show square corners over the rounded frame.
      ClippingRectangle {
        implicitWidth: 64
        implicitHeight: 64
        radius: 12
        color: Colors.bg1

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
          sourceSize.width: 128
          sourceSize.height: 128
          asynchronous: true
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        StyledText {
          Layout.fillWidth: true
          text: root.player?.trackTitle || "Nothing playing"
          font.weight: Font.DemiBold
          elide: Text.ElideRight
        }

        StyledText {
          Layout.fillWidth: true
          visible: text !== ""
          text: root.player?.trackArtist ?? ""
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
          elide: Text.ElideRight
        }

        StyledText {
          Layout.fillWidth: true
          visible: text !== ""
          text: root.player?.trackAlbum ?? ""
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
          elide: Text.ElideRight
        }
      }
    }

    RowLayout {
      Layout.fillWidth: true
      visible: root.player?.lengthSupported ?? false
      spacing: 8

      StyledText {
        text: root.formatTime(root.position)
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
      }

      ValueSlider {
        enabled: root.player?.canSeek ?? false
        value: (root.player?.length ?? 0) > 0 ? root.position / root.player.length : 0
        onMoved: target => {
          if (root.player?.canSeek) root.player.position = target * root.player.length;
        }
      }

      StyledText {
        text: root.formatTime(root.player?.length ?? 0)
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      Item {
        Layout.fillWidth: true
      }

      IconButton {
        icon: Icons.previous
        enabled: root.player?.canGoPrevious ?? false
        opacity: enabled ? 1 : 0.4
        onClicked: root.player?.previous()
      }

      IconButton {
        icon: root.player?.isPlaying ? Icons.pause : Icons.play
        size: 40
        iconSize: Theme.iconSizeLarge
        active: root.player?.isPlaying ?? false
        enabled: root.player?.canTogglePlaying ?? false
        onClicked: root.player?.togglePlaying()
      }

      IconButton {
        icon: Icons.next
        enabled: root.player?.canGoNext ?? false
        opacity: enabled ? 1 : 0.4
        onClicked: root.player?.next()
      }

      Item {
        Layout.fillWidth: true
      }
    }

    SectionLabel {
      visible: root.players.length > 1
      text: "Players"
    }

    Repeater {
      model: root.players.length > 1 ? root.players : []

      delegate: ListRow {
        required property var modelData

        active: modelData === root.player
        icon: modelData.isPlaying ? Icons.play : Icons.pause
        title: modelData.identity
        subtitle: modelData.trackTitle
        onClicked: modelData.togglePlaying()
      }
    }
  }
}
