import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

// The chat pill: a question to Claude without leaving what you were doing,
// through services/Chat.qml.
//
// Its panel is the one that drops from the bar's left end rather than from
// under the pill (BarPopup.leftAligned): it is the widest thing the bar
// opens apart from the launcher, it is read left-to-right like a document,
// and the pill it hangs off is already at that end.
//
// Typing is the point here, as in the launcher and the translator, so the
// panel's own hjkl walk is off and the field keeps the keyboard.
BarPill {
  id: root

  active: popup.visible || Chat.busy

  tooltipText: Chat.busy ? "Claude is answering…"
    : Chat.messages.length > 0 ? `Claude  ·  ${Chat.messages.length} messages in this thread`
    : "Ask Claude  ·  super+i"

  onClicked: popup.toggle()
  // The thread is worth keeping across a dozen openings and not worth
  // keeping forever, and this is the gesture that doesn't need the panel
  // open to reach.
  onMiddleClicked: Chat.reset()

  StyledText {
    text: Icons.chatSymbol
    color: Chat.busy ? Colors.accent : Colors.fgDim
    font.family: Theme.symbolFont
    font.pixelSize: Theme.iconSize
    font.variableAxes: ({ "FILL": Chat.busy ? 1 : 0, "opsz": Theme.iconSize })

    Behavior on color {
      ColorAnimation { duration: Theme.animNormal }
    }
  }

  // A dot rather than a count: that the thread has something in it is worth
  // knowing at a glance, how much of it is not.
  Rectangle {
    visible: Chat.messages.length > 0 && !Chat.busy
    implicitWidth: 6
    implicitHeight: 6
    radius: width / 2
    color: Colors.accent
    opacity: 0.8
  }

  BarPopup {
    id: popup

    anchorItem: root
    panelId: "chat"
    contentWidth: Theme.chatWidth
    keyNav: false
    leftAligned: true

    // The field only gets the keyboard once the panel is actually opening;
    // a Connections rather than an onShouldShowChanged handler, which would
    // replace the one BarPopup runs its own animation from.
    Connections {
      target: popup

      function onShouldShowChanged() {
        if (popup.shouldShow)
          Qt.callLater(() => field.forceActiveFocus());
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.pillSpacing

      SectionLabel {
        Layout.fillWidth: true
        text: Chat.ready ? "Claude Code  ·  sonnet  ·  medium effort" : "Claude Code  ·  unavailable"
      }

      IconButton {
        icon: Icons.stopSymbol
        symbol: true
        size: Theme.stepperButton
        iconSize: Theme.fontSize
        visible: Chat.busy
        tooltipText: "Stop and keep what arrived"
        onClicked: Chat.cancel()
      }

      IconButton {
        icon: Icons.copySymbol
        symbol: true
        size: Theme.stepperButton
        iconSize: Theme.fontSize
        visible: !Chat.empty
        tooltipText: "Copy the last reply"
        onClicked: Chat.copyLast()
      }

      IconButton {
        icon: Icons.newChatSymbol
        symbol: true
        size: Theme.stepperButton
        iconSize: Theme.fontSize
        visible: !Chat.empty
        tooltipText: "Start a new thread"
        onClicked: {
          Chat.reset();
          field.forceActiveFocus();
        }
      }
    }

    // The thread. Capped rather than left to grow: the panel hangs off the
    // bar, so a long conversation would otherwise reach the bottom of the
    // screen.
    Flickable {
      id: thread

      // Whether the view is following the reply in. Lost the moment the
      // thread is scrolled back by hand, so reading something further up
      // isn't yanked away by the next delta.
      property bool pinned: true

      function toEnd(): void {
        thread.contentY = Math.max(0, thread.contentHeight - thread.height);
      }

      visible: !Chat.empty || Chat.error !== ""
      Layout.fillWidth: true
      Layout.preferredHeight: Math.min(turns.implicitHeight, Theme.chatThreadHeight)
      contentWidth: width
      contentHeight: turns.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      onMovementEnded: thread.pinned = thread.atYEnd
      onContentHeightChanged: if (thread.pinned) Qt.callLater(thread.toEnd)

      ColumnLayout {
        id: turns

        width: thread.width
        spacing: Theme.popupGap

        Repeater {
          model: Chat.messages

          delegate: Item {
            required property var modelData

            readonly property bool mine: modelData.role === "user"

            Layout.fillWidth: true
            implicitHeight: Math.max(bubble.height, body.height)

            // What you said, as a bubble pulled to the right: a thread of
            // two voices is read by shape before it is read at all.
            Rectangle {
              id: bubble

              visible: parent.mine
              x: parent.width - width
              width: visible ? question.width + Theme.chatBubblePadding * 2 : 0
              height: visible ? question.height + Theme.chatBubblePadding * 2 : 0
              radius: Theme.chatBubbleRadius
              color: Colors.accentSoft

              StyledText {
                id: question

                x: Theme.chatBubblePadding
                y: Theme.chatBubblePadding
                width: Math.min(implicitWidth, thread.width * Theme.chatBubbleMax - Theme.chatBubblePadding * 2)
                height: implicitHeight
                text: parent.visible ? modelData.text : ""
                wrapMode: Text.Wrap
              }
            }

            // What Claude said, as the panel's own text rather than a
            // bubble: it is the half that gets read closely, and markdown
            // inside a tinted capsule reads as a quotation of itself.
            // Selectable, because half of what an answer is for is getting
            // part of it somewhere else.
            TextEdit {
              id: body

              visible: !parent.mine
              width: parent.width
              height: visible ? implicitHeight : 0
              text: parent.mine ? "" : modelData.text
              textFormat: TextEdit.MarkdownText
              color: Colors.fg
              font.family: Theme.font
              font.pixelSize: Theme.fontSize
              wrapMode: TextEdit.Wrap
              readOnly: true
              selectByMouse: true
              selectionColor: Colors.accent
              selectedTextColor: Colors.accentFg
              onLinkActivated: link => Qt.openUrlExternally(link)
            }
          }
        }

        // Claude's own summary of what it is working out, while it is doing
        // it. Dropped the moment the answer starts: by then it is the
        // answer that is worth the space.
        StyledText {
          Layout.fillWidth: true
          visible: Chat.thinking !== ""
          text: Chat.thinking
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
          font.italic: true
          wrapMode: Text.Wrap
        }

        // The reply as it arrives. Drawn like a settled one, so nothing
        // moves when the turn finishes and it becomes one.
        TextEdit {
          Layout.fillWidth: true
          visible: Chat.streaming !== ""
          text: Chat.streaming
          textFormat: TextEdit.MarkdownText
          color: Colors.fg
          font.family: Theme.font
          font.pixelSize: Theme.fontSize
          wrapMode: TextEdit.Wrap
          readOnly: true
          selectByMouse: true
          selectionColor: Colors.accent
          selectedTextColor: Colors.accentFg
        }

        // The gap between asking and the first token, which at medium effort
        // is a second or two of nothing to show.
        StyledText {
          Layout.fillWidth: true
          visible: Chat.busy && Chat.streaming === "" && Chat.thinking === ""
          text: "Thinking…"
          color: Colors.fgDim
          font.pixelSize: Theme.fontSizeSmall
        }

        StyledText {
          Layout.fillWidth: true
          visible: Chat.error !== ""
          text: Chat.error
          color: Colors.critical
          font.pixelSize: Theme.fontSizeSmall
          wrapMode: Text.Wrap
        }
      }
    }

    // What you are asking. A TextEdit rather than a TextInput: a question
    // worth opening this for is often two sentences and sometimes has a log
    // line pasted into it.
    Rectangle {
      Layout.fillWidth: true
      implicitHeight: Math.max(Theme.chatFieldHeight, field.implicitHeight + Theme.popupGap * 2)
      radius: Theme.chatBubbleRadius
      color: field.activeFocus ? Colors.accentSoft : Qt.alpha(Colors.bg1, 0.5)
      border.width: field.activeFocus ? 1 : 0
      border.color: Colors.accent

      Behavior on color {
        ColorAnimation { duration: Theme.animFast }
      }

      TextEdit {
        id: field

        anchors.fill: parent
        anchors.margins: Theme.popupGap
        color: Colors.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        wrapMode: TextEdit.Wrap
        selectByMouse: true
        selectionColor: Colors.accent
        selectedTextColor: Colors.accentFg

        // The draft is the panel's own, unlike the thread: a half-typed
        // question that outlived the panel being closed would be sent, days
        // later, by one stray Enter.
        Keys.onPressed: event => {
          switch (event.key) {
          case Qt.Key_Return:
          case Qt.Key_Enter:
            // Shift keeps the newline, which is the only way to paste a
            // block of anything in here and still describe it.
            if (event.modifiers & Qt.ShiftModifier)
              return;
            if (Chat.busy)
              break;
            Chat.send(field.text);
            field.clear();
            break;
          case Qt.Key_L:
            if (!(event.modifiers & Qt.ControlModifier))
              return;
            Chat.reset();
            field.clear();
            break;
          case Qt.Key_C:
            // Only when there is no selection, so ctrl+c over an answer is
            // still a copy of that answer.
            if (!(event.modifiers & Qt.ControlModifier) || !Chat.busy)
              return;
            Chat.cancel();
            break;
          case Qt.Key_Escape:
            popup.close();
            break;
          default:
            return;
          }
          event.accepted = true;
        }

        StyledText {
          anchors.left: parent.left
          anchors.top: parent.top
          visible: field.text === ""
          text: Chat.ready ? "Ask Claude something…" : "The claude CLI isn't answering"
          color: Colors.fgDim
        }
      }
    }

    StyledText {
      Layout.fillWidth: true
      text: Chat.busy ? "ctrl+c stop  ·  shift+enter newline  ·  esc close"
        : "enter send  ·  shift+enter newline  ·  ctrl+l new thread  ·  esc close"
      color: Colors.fgDim
      font.pixelSize: Theme.fontSizeSmall
    }
  }
}
