import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

// The translation pill: Portuguese in, English, German or Spanish out,
// through the local Argos models (services/Translator.qml).
//
// The pill carries the target language rather than only a glyph, because
// that is the one piece of state the panel can't show while it is closed --
// and the one you want to check before pasting into it.
//
// Typing is the point here, as in the launcher, so the panel's own hjkl walk
// is off and the field keeps the keyboard; the rows below it are for the
// pointer.
BarPill {
  id: root

  active: popup.visible || Translator.busy

  tooltipText: Translator.busy ? `Translating into ${Translator.language.title}…`
    : `Portuguese into ${Translator.language.title}\nMiddle click translates the clipboard`

  onClicked: popup.toggle()
  // The common way in: the text was selected in another window, and opening
  // the panel to paste it is a step the clipboard already took.
  onMiddleClicked: {
    popup.open();
    Translator.translateClipboard();
  }
  // The same gesture as Tab in the panel, and scrolling has a direction to
  // spend now that there are three languages to walk.
  onScrolled: direction => Translator.cycle(direction)

  StyledText {
    text: Icons.translateSymbol
    color: Translator.busy ? Colors.accent : Colors.fgDim
    font.family: Theme.symbolFont
    font.pixelSize: Theme.iconSize
    font.variableAxes: ({ "FILL": Translator.busy ? 1 : 0, "opsz": Theme.iconSize })

    Behavior on color {
      ColorAnimation { duration: Theme.animNormal }
    }
  }

  StyledText {
    text: Translator.language.label
    color: Translator.busy ? Colors.accent : Colors.fgDim
    font.pixelSize: Theme.fontSizeSmall
  }

  BarPopup {
    id: popup

    anchorItem: root
    panelId: "translate"
    contentWidth: 400
    keyNav: false

    // The field only gets the keyboard once the panel is actually opening;
    // a Connections rather than an onShouldShowChanged handler, which would
    // replace the one BarPopup runs its own animation from.
    Connections {
      target: popup

      function onShouldShowChanged() {
        if (popup.shouldShow)
          Qt.callLater(() => {
            field.forceActiveFocus();
            field.selectAll();
          });
      }
    }

    SectionLabel {
      text: "Portuguese into"
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.pillSpacing

      Repeater {
        model: Translator.languages

        delegate: Chip {
          required property var modelData

          label: modelData.title
          active: Translator.target === modelData.code
          onClicked: Translator.setTarget(modelData.code)
        }
      }

      Item {
        Layout.fillWidth: true
      }
    }

    // The text going in. A TextEdit rather than a TextInput: what gets
    // pasted in here is as often a paragraph as a phrase, and a single line
    // scrolling sideways is unreadable either way.
    Rectangle {
      Layout.fillWidth: true
      implicitHeight: Math.max(Theme.translateFieldHeight, field.implicitHeight + Theme.popupGap * 2)
      radius: 12
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
        text: Translator.input
        color: Colors.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        wrapMode: TextEdit.Wrap
        selectByMouse: true
        selectionColor: Colors.accent
        selectedTextColor: Colors.accentFg

        // Typed text is the panel's own until it is sent, but it still has
        // to reach the service: the service is where it survives the panel
        // closing, and where switching language finds it to re-run.
        onTextChanged: Translator.input = field.text

        // Typing breaks the initial binding on purpose, so text the panel
        // didn't type -- the clipboard, or Clear -- has to be pushed back in.
        Connections {
          target: Translator

          function onInputChanged() {
            if (field.text !== Translator.input)
              field.text = Translator.input;
          }
        }

        Keys.onPressed: event => {
          switch (event.key) {
          case Qt.Key_Return:
          case Qt.Key_Enter:
            // Shift keeps the newline, which is the only way to translate
            // something with a line break in it.
            if (event.modifiers & Qt.ShiftModifier)
              return;
            Translator.translate(field.text);
            break;
          case Qt.Key_Tab:
          case Qt.Key_Backtab:
            // Tab belongs to the language, not to the field: there is nothing
            // else in this panel for it to move between, and switching is the
            // one thing you do more than once per visit.
            Translator.cycle(event.key === Qt.Key_Backtab ? -1 : 1);
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
          text: "Type or paste something…"
          color: Colors.fgDim
        }
      }
    }

    StyledText {
      Layout.fillWidth: true
      text: "enter translate  ·  tab switch language  ·  esc close"
      color: Colors.fgDim
      font.pixelSize: Theme.fontSizeSmall
    }

    ListRow {
      visible: Translator.ready
      icon: Icons.pasteSymbol
      symbol: true
      iconColor: Colors.fgDim
      title: "Translate the clipboard"
      subtitle: `Whatever was last copied, in ${Translator.language.title}`
      busy: Translator.busy
      enabled: !Translator.busy
      opacity: enabled ? 1 : 0.6
      onClicked: Translator.translateClipboard()
    }

    // Argos ships no weights: the first run has to fetch the pt->en, en->de
    // and pt->es models before anything here can work.
    ListRow {
      visible: !Translator.ready
      icon: Icons.download
      iconColor: Colors.fgDim
      title: Translator.fetching ? "Downloading language models" : "Download the language models"
      subtitle: "English, German and Spanish · about 290 MB, once"
      busy: Translator.fetching
      enabled: !Translator.fetching
      opacity: enabled ? 1 : 0.6
      onClicked: Translator.fetch()
    }

    SectionLabel {
      visible: Translator.output !== ""
      text: Translator.language.title
    }

    // Selectable, because half of what a translation is for is getting part
    // of it into something else; the copy row below takes the whole thing.
    TextEdit {
      Layout.fillWidth: true
      visible: Translator.output !== ""
      text: Translator.output
      // Dimmed once the field has moved on from what this was translated
      // from: the words are still true, they are just no longer the answer
      // to what the panel is showing.
      color: Translator.stale ? Colors.fgDim : Colors.fg
      font.family: Theme.font
      font.pixelSize: Theme.fontSize
      wrapMode: TextEdit.Wrap
      readOnly: true
      selectByMouse: true
      selectionColor: Colors.accent
      selectedTextColor: Colors.accentFg
    }

    ListRow {
      visible: Translator.output !== ""
      icon: Icons.copySymbol
      symbol: true
      iconColor: Colors.fgDim
      title: "Copy the translation"
      subtitle: Translator.stale ? "Translated from earlier text" : ""
      onClicked: {
        Translator.copy();
        popup.close();
      }
    }

    ListRow {
      visible: Translator.input !== "" || Translator.output !== ""
      icon: Icons.clearSymbol
      symbol: true
      iconColor: Colors.fgDim
      title: "Clear"
      onClicked: {
        Translator.clear();
        field.forceActiveFocus();
      }
    }

    StyledText {
      Layout.fillWidth: true
      visible: Translator.error !== ""
      text: Translator.error
      color: Colors.critical
      font.pixelSize: Theme.fontSizeSmall
      wrapMode: Text.WordWrap
    }
  }
}
