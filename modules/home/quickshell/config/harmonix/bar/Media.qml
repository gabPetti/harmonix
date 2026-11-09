import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import "../theme"
import "../components"

// The bar's music widget: one glyph that drops a panel with the transport
// and a seek bar. Prefers whichever player is actually playing, so pausing
// Spotify to watch a video follows the video.
//
// Only the glyph is in the bar. The track's text lives in the panel and the
// tooltip instead: a widget that changes width with every track would drag
// its neighbours with it on each one. The spectrum used to be here too and
// is now the bar's own backdrop (bar/Wave.qml).
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

  // No player, no pill. The spectrum is what used to need showing for
  // untracked audio -- a tab Firefox never registered, anything played
  // straight to PipeWire -- and it is the whole bar's backdrop now, so a
  // glyph that opens nothing has no reason to be here.
  visible: root.player !== null
  active: popup.visible
  tooltipText: root.player ? `${root.label}\n${root.player.identity}` : ""

  // No panel without a player: the transport and seek bar have nothing to
  // act on, and an empty popup is worse than none.
  onClicked: if (root.player) popup.toggle()
  onMiddleClicked: root.player?.togglePlaying()
  onScrolled: direction => root.skip(direction)

  // What h and l do anywhere in the panel, and what the pill's scroll wheel
  // does: step tracks. Bound through the popup's fallbackAdjust, so the seek
  // slider keeps h and l for scrubbing when the selection is on it.
  function skip(direction) {
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

    Behavior on color {
      ColorAnimation { duration: Theme.animNormal }
    }
  }

  BarPopup {
    id: popup

    anchorItem: root
    panelId: "media"
    contentWidth: 384
    fallbackAdjust: direction => root.skip(direction)

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
      spacing: Theme.popupGap

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
      spacing: Theme.popupGap

      Item {
        Layout.fillWidth: true
      }

      // Firefox and other players that publish no mpris:length leave the
      // scrub bar above with nothing to lay itself over, but MPRIS `Seek`
      // takes a relative offset and works without a known length -- so
      // these stand in as the only way to move within such a track.
      IconButton {
        visible: (root.player?.canSeek ?? false) && !(root.player?.lengthSupported ?? false)
        icon: Icons.seekBackSymbol
        symbol: true
        tooltipText: "Back 10s"
        onClicked: root.player?.seek(-Theme.mediaSeekStep)
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

      IconButton {
        visible: (root.player?.canSeek ?? false) && !(root.player?.lengthSupported ?? false)
        icon: Icons.seekForwardSymbol
        symbol: true
        tooltipText: "Forward 10s"
        onClicked: root.player?.seek(Theme.mediaSeekStep)
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
