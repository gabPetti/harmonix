import QtQuick
import "../theme"
import "../components"
import "../services"

// The password field: a pill with a dot per character typed into it, and a
// real TextInput sitting invisibly over the whole thing.
//
// The dots are drawn here rather than left to the TextInput's own password
// echo so that each one can arrive with its own pop, and so that every
// monitor's field can show them from LockState -- but the input itself is a
// TextInput, because held keys, selection and the dead keys this keyboard's
// layout needs are all things a hand-rolled Keys handler gets subtly wrong,
// and getting them wrong in a password field means being locked out by a
// character you can't see.
Rectangle {
  id: root

  // How far the pill is thrown aside by a wrong password. Animated by the
  // shake below rather than set, and added to the item's own x through a
  // transform so the layout that positions the field keeps control of it.
  property real nudge: 0

  implicitWidth: Theme.lockCardWidth
  implicitHeight: Theme.lockFieldHeight
  radius: height / 2

  color: Qt.alpha(Colors.bg0, Theme.barOpacity)
  border.width: 2
  border.color: LockState.error ? Colors.critical
    : input.activeFocus ? Qt.alpha(Colors.accent, 0.8)
    : Colors.outlineSoft

  Behavior on border.color {
    ColorAnimation { duration: Theme.animNormal }
  }

  transform: Translate { x: root.nudge }

  // A wrong password is reported by the field itself moving, not only by the
  // line of text under it: the eye is on the dots, which is where the answer
  // should arrive.
  SequentialAnimation {
    id: shake

    // Out hard and back in halving steps -- a decaying wobble rather than a
    // single bounce, which at this amplitude reads as a head shake.
    NumberAnimation { target: root; property: "nudge"; to: 12; duration: 55; easing.type: Easing.OutQuad }
    NumberAnimation { target: root; property: "nudge"; to: -9; duration: 70; easing.type: Easing.InOutQuad }
    NumberAnimation { target: root; property: "nudge"; to: 5; duration: 70; easing.type: Easing.InOutQuad }
    NumberAnimation { target: root; property: "nudge"; to: 0; duration: 70; easing.type: Easing.InQuad }
  }

  Connections {
    target: LockState

    // Every rejection, not merely the first: the second wrong password has
    // to be as visible as the first.
    function onRejected() {
      shake.restart();
    }

    function onCleared() {
      input.clear();
    }

    // PAM has let go of the password, so the field takes the keyboard back.
    function onBusyChanged() {
      if (!LockState.busy && !LockState.unlocking) input.forceActiveFocus();
    }
  }

  // Invisible, and the full size of the pill: it holds the keyboard, and the
  // pill is only its skin. Opacity rather than `visible: false`, which would
  // take it out of the focus chain along with the rendering.
  //
  // Declared before the content so the submit button is drawn over it and
  // gets its own clicks; an input laid over the button would swallow them.
  TextInput {
    id: input

    anchors.fill: parent
    opacity: 0
    focus: true
    activeFocusOnPress: true
    // While PAM has the password, so a key pressed during the conversation
    // isn't folded into the answer being checked.
    readOnly: LockState.busy || LockState.unlocking
    // Nothing of it is drawn, but a selection or a cursor still costs a
    // repaint of a full-screen surface on every keypress.
    cursorVisible: false
    selectByMouse: false
    echoMode: TextInput.Password
    passwordCharacter: " "
    inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

    onTextChanged: LockState.password = input.text
    onAccepted: LockState.submit()

    // Clears the field rather than dismissing anything: there is nothing to
    // dismiss, and starting the password over is what the key is for here.
    Keys.onEscapePressed: LockState.clearPassword()

    Component.onCompleted: input.forceActiveFocus()
  }

  Row {
    anchors {
      left: parent.left
      right: parent.right
      verticalCenter: parent.verticalCenter
      leftMargin: Theme.popupPadding
      rightMargin: Theme.popupPadding - 4
    }
    spacing: Theme.contentSpacing

    StyledText {
      id: keyGlyph

      anchors.verticalCenter: parent.verticalCenter
      text: Icons.key
      color: LockState.error ? Colors.critical : Colors.fgDim
      font.pixelSize: Theme.iconSize
    }

    // The dots, and the placeholder they stand in for. One slot for both, so
    // the two never shift each other along.
    Item {
      // Whatever the glyph and the button leave. The Row is anchored to both
      // of the pill's sides, so its width comes from the anchors rather than
      // from its children -- reading it here is not the binding loop it
      // would be in a Row that sized itself.
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - keyGlyph.width - submit.width - parent.spacing * 2
      height: Theme.lockFieldHeight

      StyledText {
        anchors.verticalCenter: parent.verticalCenter
        visible: LockState.password === ""
        text: LockState.busy ? "Checking…" : "Password"
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
      }

      Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.lockDotSpacing

        // Capped rather than scrolled: the row is feedback that a key
        // landed, not a character count, and a passphrase should not be
        // able to push the dots out of the pill.
        Repeater {
          model: Math.min(LockState.password.length, Theme.lockDotMax)

          Rectangle {
            id: dot

            required property int index

            width: Theme.lockDotSize
            height: Theme.lockDotSize
            radius: width / 2
            color: LockState.error ? Colors.critical : Colors.accent

            // Each dot lands with a pop of its own. The last one in is the
            // only one that animates, the ones before it having already
            // finished -- which is what makes the row feel like typing
            // rather than like a progress bar filling.
            scale: 0

            Component.onCompleted: pop.start()

            SequentialAnimation {
              id: pop

              NumberAnimation { target: dot; property: "scale"; to: 1.35; duration: Theme.animFast; easing.type: Easing.OutQuad }
              NumberAnimation { target: dot; property: "scale"; to: 1; duration: Theme.animFast; easing.type: Easing.InOutQuad }
            }
          }
        }
      }
    }

    // Submit, for a mouse. Disabled on an empty field rather than hidden, so
    // the pill's right-hand end doesn't change shape as the first character
    // is typed.
    IconButton {
      id: submit

      anchors.verticalCenter: parent.verticalCenter
      icon: LockState.busy ? Icons.progressSymbol : Icons.submitSymbol
      symbol: true
      size: Theme.lockFieldHeight - 12
      enabled: LockState.password !== "" && !LockState.busy
      opacity: enabled || LockState.busy ? 1 : 0.35
      accentColor: Colors.accent
      active: LockState.password !== ""
      onClicked: LockState.submit()

      // Only while PAM has it: pam_faildelay sleeps for a second or two
      // after a wrong password, and a field that simply stopped answering
      // for that long reads as broken.
      NumberAnimation on rotation {
        running: LockState.busy
        from: 0
        to: 360
        duration: 900
        loops: Animation.Infinite
      }
    }
  }

}
