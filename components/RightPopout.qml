import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import QtCore
import QtQuick.Controls
import QtQuick.Layouts
import "../wal" as Wal

RowLayout {
  id: rightPopoutRow
  required property var modelData
  property int volume
  property bool volumeMuted
  property var defaultAudioSink
  property color color0: Wal.Colors.color(0)
  property color color1: Wal.Colors.color(1)
  property color color2: Wal.Colors.color(2)
  property color color3: Wal.Colors.color(3)
  property color color4: Wal.Colors.color(4)
  property color color5: Wal.Colors.color(5)
  property color color6: Wal.Colors.color(6)
  property color color7: Wal.Colors.color(7)
  property color color8: Wal.Colors.color(8)
  property color color9: Wal.Colors.color(9)
  property color color10: Wal.Colors.color(10)
  property color color11: Wal.Colors.color(11)
  property color color12: Wal.Colors.color(12)
  property color color13: Wal.Colors.color(13)
  property color color14: Wal.Colors.color(14)
  property color color15: Wal.Colors.color(15)

  property int brightness
  property int bus: -1
  property bool brightnessInitialized: false

  PanelWindow {
    id: rightPopoutRowTrigger
    anchors.right: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 3
    implicitHeight: 500
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay

    MouseArea {
      id: triggerHoverArea
      anchors.fill: parent
      hoverEnabled: true
      propagateComposedEvents: true
      acceptedButtons: Qt.NoButton

      onEntered: {
        backgroundShape.show()
      }
    }
  }

  PanelWindow {
    id: rightPopout
    anchors.right: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 50
    implicitHeight: 500
    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay

    margins {
      top: 0
      left: 0
      right: 0
    }

    Process {
      id: detectBusProc
      command: ["sh", "-c", "ddcutil detect --brief"]
      stdout: SplitParser {
        onRead: data => {
          if (!data) return
          var lines = data.split("\n")
          var busLine = lines.find(l => l.trim().startsWith("I2C bus:"))
          if (busLine) {
            rightPopoutRow.bus = parseInt(busLine.split("/dev/i2c-")[1])
            brightnessProc.running = true
          }
        }
      }
      Component.onCompleted: running = true
    }

    Process {
      id: brightnessProc
      command: ["sh", "-c", "ddcutil -b " + rightPopoutRow.bus + " getvcp 10 --brief"]
      stdout: SplitParser {
        onRead: data => {
          if (!data) return
          var match = data.match(/VCP\s+10\s+[A-Z]\s+(\d+)\s+\d+/)
          if (match && match[1]) {
            rightPopoutRow.brightness = parseInt(match[1])
            rightPopoutRow.brightnessInitialized = true
          }
        }
      }
    }

    Process {
      id: setBrightnessProc
      command: ["sh", "-c", "ddcutil --noverify --sleep-multiplier=0.1 -b " + rightPopoutRow.bus + " setvcp 10 " + rightPopoutRow.brightness]
    }

    Shape {
      id: backgroundShape
      width: parent.width
      height: parent.height
      antialiasing: true
      smooth: true
      layer.enabled: true
      layer.smooth: true
      layer.samples: 32
      transformOrigin: Item.Right | Item.VerticalCenter

      property bool hiding: false
      x: hiding ? 0 : 50
      opacity: hiding ? 0 : 1


      function show() {
        rightPopout.visible = true
        hideAnimation.stop()
        showAnimation.start()
      }

      function hide() {
        showAnimation.stop()
        hideAnimation.start()
      }

      PropertyAnimation {
        id: showAnimation
        target: backgroundShape
        properties: "x"
        from: 50
        to: 0
        duration: 150
      }

      PropertyAnimation {
        id: hideAnimation
        target: backgroundShape
        properties: "x"
        from: 0
        to: 50
        duration: 150
        onStopped: rightPopout.visible = false
      }

      ShapePath {
        strokeWidth: -1
        fillColor: rightPopoutRow.color0
        startX: rightPopout.width
        startY: 0
        PathArc {
          x: rightPopout.width - 15
          y: 15
          radiusX: 15
          radiusY: 15
          direction: PathArc.Clockwise
        }
        PathLine {
          x: 15
          y: 15
        }
        PathArc {
          x: 0
          y: 30
          radiusX: 15
          radiusY: 15
          direction: PathArc.Counterclockwise
        }
        PathLine {
          x: 0
          y: rightPopout.height - 30
        }
        PathArc {
          x: 15
          y: rightPopout.height - 15
          radiusX: 15
          radiusY: 15
          direction: PathArc.Counterclockwise
        }
        PathLine {
          x: rightPopout.width - 15
          y: rightPopout.height - 15
        }
        PathArc {
          x: rightPopout.width
          y: rightPopout.height
          radiusX: 15
          radiusY: 15
          direction: PathArc.Clockwise
        }
      }

      ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height
        spacing: 10
        visible: backgroundShape.opacity > 0

        // ───────── TOP ARROW ─────────
        Rectangle {
          Layout.preferredHeight: 24
          Layout.preferredWidth: 24
          Layout.alignment: Qt.AlignHCenter
          Layout.bottomMargin: 1
          Layout.leftMargin: 4
          color: "transparent"

          Text {
            anchors.fill: parent
            text: ""
            color: rightPopoutRow.color3
            rotation: 90
            transformOrigin: Item.BottomLeft
            font.family: "Jetbrains Mono Nerd Font"
            font.pixelSize: 18
            font.bold: true
          }
        }

        // ───────── VOLUME BAR ─────────
        Rectangle {
          id: volumeBar
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignHCenter
          Layout.leftMargin: 4
          width: 24
          color: "transparent"

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true
            onWheel: wheel => {
              let delta = wheel.angleDelta.y > 0 ? 5 : -5
              let newVolume = Math.max(0, Math.min(100, rightPopoutRow.volume + delta))
              rightPopoutRow.volume = newVolume
              if (rightPopoutRow.defaultAudioSink && rightPopoutRow.defaultAudioSink.audio) {
                rightPopoutRow.defaultAudioSink.audio.volume = newVolume / 100
              }
              wheel.accepted = true
            }
          }

          Rectangle {
            anchors.fill: parent
            color: rightPopoutRow.color3

            Rectangle {
              id: volumeFill
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.bottom: parent.bottom
              height: (rightPopoutRow.volume / 100) * parent.height
              color: rightPopoutRow.color9
            }

            Rectangle {
              anchors.bottom: volumeFill.top
              height: 25
              width: 24
              color: "transparent"
              Text {
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: -1
                text: ""
                color: rightPopoutRow.color9
                rotation: 90
                transformOrigin: Item.BottomLeft
                font.family: "Jetbrains Mono Nerd Font"
                font.pixelSize: 18
                font.bold: true
              }
            }
          }

          Slider {
            id: volumeSlider
            anchors.fill: parent
            from: 0
            to: 100
            value: rightPopoutRow.volume
            stepSize: 1
            orientation: Qt.Vertical
            padding: 0

            background: Item {}
            contentItem: Item {}
            handle: Rectangle {
              implicitWidth: parent.width
              implicitHeight: 20
              radius: 10
              color: "transparent"
            }

            onMoved: rightPopoutRow.volume = value
            onValueChanged: {
              if (rightPopoutRow.defaultAudioSink && rightPopoutRow.defaultAudioSink.audio)
                rightPopoutRow.defaultAudioSink.audio.volume = value / 100
            }
          }

          Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            height: 24
            width: 24
            color: "transparent"

            Text {
              anchors.bottom: parent.bottom
              anchors.left: parent.left
              text: ""
              color: rightPopoutRow.color9
              rotation: 90
              transformOrigin: Item.BottomLeft
              font.family: "Jetbrains Mono Nerd Font"
              font.pixelSize: 18
              font.bold: true
            }
          }
        }

        // ───────── VOLUME LABEL ─────────
        Text {
          Layout.alignment: Qt.AlignHCenter
          Layout.leftMargin: 4
          text: (
            rightPopoutRow.volumeMuted ? "" :
            rightPopoutRow.volume >= 66 ? "" :
            rightPopoutRow.volume >= 33 ? "" :
            ""
          ) + " " + rightPopoutRow.volume + "%"
          color: rightPopoutRow.color15
          font.family: "Jetbrains Mono Nerd Font"
          font.pixelSize: 12
          font.bold: true
          topPadding: 10
          bottomPadding: 10
          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              rightPopoutRow.volumeMuted = !rightPopoutRow.volumeMuted
              if (rightPopoutRow.defaultAudioSink && rightPopoutRow.defaultAudioSink.audio) {
                rightPopoutRow.defaultAudioSink.audio.muted = rightPopoutRow.volumeMuted
              }
            }
          }
        }

        // ───────── middle ARROW ─────────
        Rectangle {
          Layout.preferredHeight: 24
          Layout.preferredWidth: 24
          Layout.alignment: Qt.AlignHCenter
          Layout.topMargin: -35
          Layout.leftMargin: 4
          color: "transparent"

          Text {
            anchors.fill: parent
            text: ""
            color: rightPopoutRow.color3
            rotation: 90
            transformOrigin: Item.BottomLeft
            font.family: "Jetbrains Mono Nerd Font"
            font.pixelSize: 18
            font.bold: true
          }
        }

        // ───────── BRIGHTNESS BAR ─────────
        Rectangle {
          id: brightnessBar
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignHCenter
          Layout.topMargin: -4
          Layout.bottomMargin: 4
          Layout.leftMargin: 4
          width: 24
          color: "transparent"

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton  // Don't accept clicks, only wheel
            propagateComposedEvents: true
            onWheel: wheel => {
              if (!rightPopoutRow.brightnessInitialized) return
              let delta = wheel.angleDelta.y > 0 ? 5 : -5
              let newBrightness = Math.max(0, Math.min(100, rightPopoutRow.brightness + delta))
              rightPopoutRow.brightness = newBrightness
              setBrightnessProc.running = true
              wheel.accepted = true
            }
          }

          Rectangle {
            anchors.fill: parent
            color: rightPopoutRow.color3

            Rectangle {
              id: brightnessFill
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.bottom: parent.bottom
              height: (rightPopoutRow.brightness / 100) * parent.height
              color: rightPopoutRow.color9
            }

            Rectangle {
              anchors.bottom: brightnessFill.top
              height: 25
              width: 24
              color: "transparent"

              Text {
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: -1
                text: ""
                color: rightPopoutRow.color9
                rotation: 90
                transformOrigin: Item.BottomLeft
                font.family: "Jetbrains Mono Nerd Font"
                font.pixelSize: 18
                font.bold: true
              }
            }
          }

          Slider {
            id: brightnessSlider
            anchors.fill: parent
            anchors.bottomMargin: 10
            from: 0
            to: 100
            value: rightPopoutRow.brightness
            stepSize: 1
            orientation: Qt.Vertical
            padding: 0

            background: Item {}
            contentItem: Item {}
            handle: Rectangle {
              implicitWidth: parent.width
              implicitHeight: 20
              radius: 10
              color: "transparent"
            }

            onMoved: rightPopoutRow.brightness = value
            onValueChanged: {
              if (!rightPopoutRow.brightnessInitialized) return
              rightPopoutRow.brightness = value
              setBrightnessProc.running = true
            }
          }

          Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            height: 24
            width: 24
            color: "transparent"

            Text {
              anchors.bottom: parent.bottom
              anchors.left: parent.left
              text: ""
              color: rightPopoutRow.color9
              rotation: 90
              transformOrigin: Item.BottomLeft
              font.family: "Jetbrains Mono Nerd Font"
              font.pixelSize: 18
              font.bold: true
            }
          }
        }

        // ───────── BRIGHTNESS LABEL ─────────
        Text {
          Layout.alignment: Qt.AlignHCenter
          Layout.leftMargin: 4
          Layout.bottomMargin: 12
          text: "󰃞 " + rightPopoutRow.brightness + "%"
          color: rightPopoutRow.color15
          font.family: "Jetbrains Mono Nerd Font"
          font.pixelSize: 12
          font.bold: true
          topPadding: 10
          bottomPadding: 10
        }
      }
    }

    // ───────── HOVER POP-OUT LOGIC ─────────
    MouseArea {
      id: panelHoverArea
      anchors.fill: parent
      hoverEnabled: true
      propagateComposedEvents: true
      acceptedButtons: Qt.NoButton

      onExited: {
        backgroundShape.hide()
      }
    }
  }
}

