import QtQuick
import QtQuick.Layouts
import "../theme"

// A whole-number setting you can either nudge or type: glyph, name, a minus
// and plus either side of the value, and the value itself editable in place.
//
// Three ways in, because the panel has three kinds of user. The buttons are
// for the pointer; h and l are for the keyboard walk (KeyNav sees one stop
// here, not four); Enter opens the field for a number typed straight in,
// which is the only sane way to get from 25 to 90.
RowLayout {
  id: root

  property string icon: ""
  // Set when `icon` is a Material Symbols ligature rather than a Nerd Font
  // codepoint -- see UsageRing.symbol.
  property bool symbol: false
  property string title: ""
  property string unit: ""
  property int value: 0
  property int minimum: 0
  property int maximum: 999
  property int step: 1

  // One stop for the keyboard rather than four: h and l move the value and
  // Enter starts typing it. Both buttons stay clickable regardless -- this
  // is only about what KeyNav walks (components/KeyNav.qml).
  readonly property bool navigable: true
  property bool selected: false

  readonly property bool editing: field.activeFocus

  // Typing breaks the field's initial binding on purpose, so the value has
  // to be pushed back in whenever something else moves it -- the buttons,
  // h/l, or the pill's scroll wheel.
  onValueChanged: if (!field.activeFocus) field.text = String(root.value)

  signal moved(int target)
  // Raised when the field hands the keyboard back, so the panel can take its
  // navigation focus again (BarPopup.refocus).
  signal editingFinished

  function adjust(direction: int): void {
    root.commit(root.value + direction * root.step);
  }

  function activate(): void {
    field.forceActiveFocus();
    field.selectAll();
  }

  function commit(target): void {
    const number = Number(target);
    // An emptied or half-typed field is not a number; fall back to what the
    // setting already is rather than letting NaN through to an int property.
    const clamped = !isFinite(number) ? root.value
      : Math.max(root.minimum, Math.min(root.maximum, Math.round(number)));
    if (clamped !== root.value)
      root.moved(clamped);
    // Re-assert the text even when the number didn't change: a rejected
    // entry (out of range, or empty) has to be pulled back to what is real.
    field.text = String(clamped);
  }

  function stopEditing(): void {
    field.focus = false;
    root.editingFinished();
  }

  Layout.fillWidth: true
  spacing: Theme.popupGap

  StyledText {
    visible: root.icon !== ""
    text: root.icon
    color: root.selected ? Colors.accent : Colors.fgDim
    font.family: root.symbol ? Theme.symbolFont : Theme.font
    font.pixelSize: Theme.iconSize
    font.variableAxes: root.symbol ? ({ "FILL": 1, "opsz": Theme.iconSize }) : ({})
  }

  StyledText {
    Layout.fillWidth: true
    text: root.title
    color: Colors.fg
    elide: Text.ElideRight
  }

  IconButton {
    icon: Icons.minus
    size: Theme.stepperButton
    onClicked: root.adjust(-1)
  }

  // The value sits in its own chip so that it reads as the thing being
  // edited rather than as a label between two buttons -- and so the click
  // target for typing is the number, not a stretch of empty row.
  Rectangle {
    implicitWidth: Theme.stepperField
    implicitHeight: Theme.stepperButton
    radius: 8
    color: root.editing ? Colors.accentSoft : Qt.alpha(Colors.bg1, 0.5)
    border.width: root.editing ? 1 : 0
    border.color: Colors.accent

    Behavior on color {
      ColorAnimation { duration: Theme.animFast }
    }

    RowLayout {
      anchors.centerIn: parent
      spacing: 3

      TextInput {
        id: field

        text: String(root.value)
        color: Colors.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        horizontalAlignment: Text.AlignRight
        selectByMouse: true
        selectionColor: Colors.accent
        selectedTextColor: Colors.accentFg
        // Typing is bounded at the source, so the field can never show a
        // number the setting would refuse.
        validator: IntValidator {
          bottom: root.minimum
          top: root.maximum
        }

        onActiveFocusChanged: if (!field.activeFocus) root.commit(parseInt(field.text));

        Keys.onPressed: event => {
          switch (event.key) {
          case Qt.Key_Return:
          case Qt.Key_Enter:
            root.commit(parseInt(field.text));
            root.stopEditing();
            break;
          case Qt.Key_Escape:
            field.text = String(root.value);
            root.stopEditing();
            break;
          default:
            // Everything else is a character the field should get -- q and j
            // included, which is exactly why the panel's hjkl can't see them
            // while this has the keyboard.
            return;
          }
          event.accepted = true;
        }
      }

      StyledText {
        visible: root.unit !== ""
        text: root.unit
        color: Colors.fgDim
        font.pixelSize: Theme.fontSizeSmall
      }
    }
  }

  IconButton {
    icon: Icons.plus
    size: Theme.stepperButton
    onClicked: root.adjust(1)
  }
}
