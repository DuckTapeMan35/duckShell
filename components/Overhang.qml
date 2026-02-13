import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtCore
import QtQuick.Controls
import "../wal" as Wal

PanelWindow {
  id: overhang
  color: "transparent"
  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: 16
  margins {
    top: 0
    left: 0
    right: 0
    bottom: -16
  }
  property color color0: Wal.Colors.color(0)
  required property var modelData

  Shape {
    anchors.fill: parent
    antialiasing: true
    smooth: true
    layer.enabled: true
    layer.smooth: true
    layer.samples: 32
    ShapePath {
      strokeWidth: -1
      fillColor: overhang.color0
      startX: 0
      startY: 0
      // Top edge
      PathLine { x: overhang.width; y: 0 }
      // Right edge down to bottom
      PathLine { x: overhang.width; y: 15 }
      // Bottom-right OUTWARD curve (going left and up)
      PathArc {
        x: overhang.width - 16
        y: 0
        radiusX: 16
        radiusY: 16
        direction: PathArc.Counterclockwise
      }
      PathLine { x: 16; y: 0 }
      // Bottom-left OUTWARD curve (going left and down)
      PathArc {
        x: 0
        y: 16
        radiusX: 16
        radiusY: 16
        direction: PathArc.Counterclockwise
      }
      // Left edge back to start
      PathLine { x: 0; y: 0 }
    }
  }
}
