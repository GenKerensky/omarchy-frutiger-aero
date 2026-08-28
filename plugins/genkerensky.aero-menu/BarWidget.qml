import QtQuick
import qs.Commons
import qs.Ui

// The Omarchy menu button as a Windows XP Media Center start button.
//
// A bar-widget only. The stock omarchy.menu plugin ships both this button and
// the 1420-line menu overlay behind it; cloning it to restyle one button would
// fork the overlay too. The button's whole job is one IPC call, so this is a
// separate widget that makes the same call and leaves omarchy.menu to go on
// providing the menu.
//
// Geometry and colour are measured from ~/Projects/fa-menu.xcf rather than
// guessed: the mock's button is 44x29 in a 29px bar, flush into the top-left
// corner, square on the screen edge and capped on the desktop side.
//
// The green is fixed rather than tinted from Color.accent, unlike the bar
// gloss and the workspace pills. A start button that changes colour with the
// theme stops being a quotation.
BarWidget {
  id: root
  moduleName: "genkerensky.aero-menu"

  readonly property bool lit: button.tooltipHovered

  // 44:29 in the mock. Derived from bar height so it survives a font-scale
  // change instead of pinning pixels.
  readonly property real gelWidth: Math.round(root.barSize * 1.52)

  // Breathing room before the workspace pills, so the button reads as its own
  // thing rather than as the first item in the row. Part of the widget's width
  // but not of the gel or the click target: the gap must not open the menu.
  readonly property real trailingGap: Style.spaceReal(6)

  implicitWidth: Math.round(root.gelWidth + root.trailingGap)
  implicitHeight: root.barSize

  Rectangle {
    id: gel

    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: root.gelWidth

    // Flush into the corner on the screen edge, capped on the desktop side.
    topLeftRadius: 0
    bottomLeftRadius: 0
    topRightRadius: Math.round(height * 0.42)
    bottomRightRadius: Math.round(height * 0.42)

    // Dark outer edge, sampled at #19430a. It traces the cap as well as the
    // straight runs, which a gradient stop cannot do.
    border.width: 1
    border.color: "#19430a"

    // Fill sampled off the mock, column x=4:
    //   y=1            #dcffc9   specular peak
    //   y=1 -> 14      ramp down to #478627
    //   y=15           #2d7009   hard break -- the moulding line
    //   y=15 -> 27     ramp UP to #398c0f, light bouncing back off the desk
    // The bottom half getting brighter rather than darker is what separates a
    // real gel from a plain top-lit gradient.
    gradient: Gradient {
      GradientStop { position: 0.030; color: root.lit ? "#eeffe0" : "#dcffc9" }
      GradientStop { position: 0.500; color: root.lit ? "#57a032" : "#478627" }
      GradientStop { position: 0.520; color: root.lit ? "#3a8a12" : "#2d7009" }
      GradientStop { position: 1.000; color: root.lit ? "#48a615" : "#398c0f" }
    }

    // Bright lime rim one pixel inside the dark edge (#adf975 on the cap,
    // #b1ff70 along the bottom). This is the highlight that makes the button
    // sit proud of the bar rather than lie flat in it, and it has to follow
    // the cap, so it is a border rather than another gradient stop.
    Rectangle {
      anchors.fill: parent
      anchors.margins: 1
      color: "transparent"
      border.width: 1
      border.color: "#b1ff70"
      topLeftRadius: 0
      bottomLeftRadius: 0
      topRightRadius: Math.max(0, gel.topRightRadius - 1)
      bottomRightRadius: Math.max(0, gel.bottomRightRadius - 1)
    }
  }

  // The mark, white with a dark outline so it holds its shape against both the
  // pale top of the gel and the deep green below it. The outline is the same
  // glyph painted at four one-pixel offsets; cheaper and crisper at this size
  // than a blurred shadow.
  Item {
    id: mark

    anchors.centerIn: gel
    // The cap adds visual weight on the right, so the mark sits a hair left of
    // true centre, as it does in the mock.
    anchors.horizontalCenterOffset: -2
    width: glyph.implicitWidth
    height: glyph.implicitHeight

    Repeater {
      model: [[-1, 0], [1, 0], [0, -1], [0, 1]]

      Text {
        required property var modelData

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: modelData[0]
        anchors.verticalCenterOffset: modelData[1]
        text: ""
        font.family: "omarchy"
        font.pixelSize: Math.round(root.barSize * 0.63)
        color: "#1a440b08"
        renderType: Text.NativeRendering
      }
    }

    Text {
      id: glyph

      anchors.centerIn: parent
      text: ""
      font.family: "omarchy"
      font.pixelSize: Math.round(root.barSize * 0.63)
      color: "#ffffff"
      renderType: Text.NativeRendering
    }
  }

  WidgetButton {
    id: button

    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: root.gelWidth
    bar: root.bar
    text: ""
    fontFamily: "omarchy"
    // The mark is drawn above instead, so it can carry its own outline.
    labelVisible: false
    tooltipText: "Omarchy menu"
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
    }
  }
}
