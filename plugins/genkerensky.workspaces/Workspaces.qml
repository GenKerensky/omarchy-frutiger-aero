import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  function focusAdjacentWorkspace(wheelDelta) {
    if (wheelDelta === 0) return
    var target = wheelDelta > 0 ? "e-1" : "e+1"
    Hyprland.dispatch("hl.dsp.focus({ workspace = \"" + target + "\" })")
  }

  // ---------------------------------------------------------------------
  // Frutiger Aero gel pill.
  //
  // Hyprland cannot draw gloss on window chrome, but the bar is QML, not a
  // themed config file — so here we can build the real thing: a two-tone
  // vertical fill with a hard midline, a specular cap over the top half, and
  // a bright rim. That is exactly how an Aero button was constructed.
  //
  // Note that shell.toml alone could never express this: Color.bar.background
  // and friends resolve to a flat QML `color`, and a gradient string handed to
  // one of them collapses to its first stop. Gradients in tokens are a border
  // feature. Fills have to be drawn.
  // ---------------------------------------------------------------------
  component GelPill: Item {
    id: gel

    property bool lit: false
    property color tint: Color.accent

    Rectangle {
      id: body

      anchors.fill: parent
      // A screen has corners, not a waistline. Just enough radius to read
      // as a moulded bezel rather than a sharp-cornered box.
      radius: Math.max(2, Math.round(height * 0.16))
      border.width: 1
      border.color: Qt.rgba(1, 1, 1, gel.lit ? 0.55 : 0.16)

      // The hard break at the midline is the whole trick. A smooth gradient
      // reads as a soft panel; the discontinuity reads as a curved, moulded
      // surface catching a light source above it.
      gradient: Gradient {
        GradientStop { position: 0.00; color: gel.lit ? Qt.lighter(gel.tint, 1.50) : Qt.rgba(1, 1, 1, 0.15) }
        GradientStop { position: 0.49; color: gel.lit ? gel.tint                   : Qt.rgba(1, 1, 1, 0.08) }
        GradientStop { position: 0.51; color: gel.lit ? Qt.darker(gel.tint, 1.30)  : Qt.rgba(1, 1, 1, 0.03) }
        GradientStop { position: 1.00; color: gel.lit ? Qt.darker(gel.tint, 1.70)  : Qt.rgba(1, 1, 1, 0.09) }
      }

      Behavior on border.color { ColorAnimation { duration: 160 } }
    }

    // Specular cap: the blown-out highlight sitting on the top half.
    Rectangle {
      anchors {
        top: body.top
        left: body.left
        right: body.right
        margins: 1
      }
      height: Math.max(2, body.height * 0.40)
      radius: body.radius

      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, gel.lit ? 0.44 : 0.22) }
        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
      }
    }
  }

  // Centring a digit on its line box drops it low, because the box reserves
  // room for a descender the digit does not have. Correcting from font
  // metrics (ascent/descent/capHeight) still missed by ~1.5px under native
  // rendering, so measure the glyph's actual painted box instead and centre
  // on that. "0" stands in for every digit: the bar font is monospaced and
  // all digits share a cap height, so the box is stable whatever number a
  // pill shows.
  TextMetrics {
    id: labelMetrics
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.body
    text: "0"
  }

  // A workspace stands for a screen, so it is drawn as one: a wide panel at
  // roughly 16:10, not a dot.
  readonly property real pillHeight: Math.max(10, root.barSize - Style.spaceReal(8))
  readonly property real pillWidth: Math.round(pillHeight * 1.6)

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        id: slot
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        // Every pill shows its number now, focused included. The lit gel
        // already says which one is current, and a screen with a number on it
        // beats a screen with a blob on it.
        bar: root.bar
        text: modelData === 10 ? "0" : String(modelData)
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Math.round(root.pillWidth + Style.spaceReal(2))
        fixedHeight: root.barSize
        // The label is drawn below instead, so it can be centred on the pill
        // rather than on WidgetButton's line box.
        labelVisible: false
        onPressed: function() { root.focusWorkspace(modelData) }
        onWheelMoved: function(delta) { root.focusAdjacentWorkspace(delta) }

        GelPill {
          z: -1
          anchors.centerIn: parent
          width: root.vertical ? root.pillWidth : parent.width - Style.spaceReal(2)
          height: root.pillHeight
          visible: slot.focused || slot.occupied
          lit: slot.focused
          tint: Color.accent
        }

        Text {
          id: label

          anchors.horizontalCenter: parent.horizontalCenter
          // Put the middle of the painted glyph on the middle of the pill.
          y: Math.round(parent.height / 2
                        - label.baselineOffset
                        - labelMetrics.tightBoundingRect.y
                        - labelMetrics.tightBoundingRect.height / 2)
          text: slot.text
          // Dark ink on the lit pill: a bright accent fill leaves white type
          // with too little contrast once the pill is this large.
          color: slot.focused ? Color.background : (root.bar ? root.bar.barForeground : Color.foreground)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          renderType: Text.NativeRendering
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
      }
    }
  }
}
