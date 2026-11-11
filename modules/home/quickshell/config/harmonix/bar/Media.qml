import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import "../theme"
import "../components"

// The music panel: the transport and a seek bar, dropped from the middle of
// the bar. Prefers whichever player is actually playing, so pausing Spotify
// to watch a video follows the video.
//
// Nothing of it is in the bar any more. It had a pill once, then the pill had
// only a glyph -- the track's text would have dragged its neighbours around
// on every song, and the spectrum that was also here became the bar's own
// backdrop (bar/Wave.qml) -- which left a pill that said nothing the panel
// behind it didn't. So the panel is reached by its keybind alone, and this
// item exists only to host it: a panel still has to live inside a bar window
// to know which monitor it belongs to.
//
// It opens with no player too, showing its "Nothing playing" placeholder.
// Suppressing that was worth it when a click on the pill was the only way in;
// a keybind that answers with nothing at all is indistinguishable from a
// keybind that is broken.
Item {
  id: root

  readonly property var players: Mpris.players.values
  readonly property var player: root.players.find(candidate => candidate.isPlaying) ?? root.players[0] ?? null

  // MPRIS position is only recomputed when read, so sample it while the popup
  // is open rather than binding to it.
  property real position: 0

  // Takes no room in the bar and draws nothing: it is an address, not a
  // widget. Zero width would make it invisible to a layout anyway, which is
  // why it hangs off the bar window rather than off one of its rows.
  implicitWidth: 0
  implicitHeight: 0

  // What h and l do anywhere in the panel: step tracks. Bound through the
  // popup's fallbackAdjust, so the seek slider keeps h and l for scrubbing
  // when the selection is on it.
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

  BarPopup {
    id: popup

    anchorItem: root
    panelId: "media"
    contentWidth: 384
    // No pill to hang off, so it drops from the middle of the bar -- which is
    // also where the clock is, the one part of the bar it now reads under.
    centered: true
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
