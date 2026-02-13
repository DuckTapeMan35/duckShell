import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

RowLayout {
  id: middleRowLayout
  spacing: -1

  property var panel: parent.parent

  //----- Temperature arrow -----
  Rectangle {
    Layout.preferredWidth: panel.height
    Layout.preferredHeight: panel.height
    color: "transparent"
    Text {
      anchors.right: parent.right
      text: ""
      color: panel.color1
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  //----- Temperature module -----
  Rectangle {
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: 50
    color: panel.color1
    Text {
      anchors.centerIn: parent
      text: (panel.temperatureValue < 50) ? " " + panel.temperatureValue + "°C " : " " + panel.temperatureValue + "°C "
      color: (panel.temperatureValue < 50) ? panel.color15 : "#FF757F"
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
  }
  //----- Temperature arrow -----
  Rectangle {
    Layout.preferredWidth: 0
    Layout.preferredHeight: panel.height
    color: "transparent"
    Text {
      anchors.left: parent.left
      text: ""
      color: panel.color1
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  //----- Memory arrow -----
  Text {
    text: ""
    color: panel.color2
    font { family: panel.fontFamily; pixelSize: 20 }
  }
  //----- Memory module -----
  Rectangle {
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: 50
    color: panel.color2
    Text {
      anchors.centerIn: parent
      text: "  " + panel.memUsage + "% "
      color: (panel.memUsage < 80) ? panel.color15 : "#FF757F"
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
  }
  //----- Memory arrow -----
  Rectangle {
    Layout.preferredWidth: 0
    Layout.preferredHeight: panel.height
    color: "transparent"
    Text {
      anchors.left: parent.left
      text: ""
      color: panel.color2
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  //----- CPU arrow -----
  Text {
    text: ""
    color: panel.color3
    font { family: panel.fontFamily; pixelSize: 20 }
  }
  //----- CPU module -----
  Rectangle {
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: 50
    color: panel.color3
    Text {
      anchors.centerIn: parent
      text: "󰍛 " + panel.cpuUsage + "%"
      color: (panel.cpuUsage < 80) ? panel.color15 : "#FF757F"
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
  }
  //----- CPU arrow -----
  Rectangle {
    Layout.preferredWidth: panel.height
    Layout.preferredHeight: panel.height
    color: "transparent"
    Text {
      anchors.left: parent.left
      text: ""
      color: panel.color3
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  //----- Tags module -----
  Repeater {
    model: panel.tags
    delegate: Row {
      spacing: -1
      visible: modelData.hasWindows || modelData.focused
      // Arrow
      Text {
        text: ""
        color: panel.color3
        font.family: panel.fontFamily
        font.pixelSize: 20
        visible: modelData.focused
      }
      // Number
      Rectangle {
        width: modelData.focused ? 20 : 15
        height: 26
        color: modelData.focused ? panel.color3 : "transparent"
        Text {
          anchors.centerIn: parent
          text: index + 1
          color: panel.color15
          font.family: panel.fontFamily
          font.pixelSize: 12
          font.bold: true
        }
      }
      // Arrow
      Text {
        text: ""
        color: panel.color3
        font.family: panel.fontFamily
        font.pixelSize: 20
        visible: modelData.focused
      }
    }
  }
  //----- Time arrow -----
  Rectangle {
    Layout.preferredWidth: panel.height
    Layout.preferredHeight: panel.height
    color: "transparent"
    Text {
      anchors.right: parent.right
      text: ""
      color: panel.color3
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  //----- Time module -----
  Rectangle {
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: 60
    color: panel.color3
    Text {
      anchors.centerIn: parent
      text: panel.timeStr
      color: panel.color15
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
  }
  //----- Time arrow -----
  Text {
    text: ""
    color: panel.color3
    font { family: panel.fontFamily; pixelSize: 20 }
  }
  //----- Date arrow -----
  Rectangle {
    Layout.preferredWidth: 0
    Layout.preferredHeight: panel.height
    color: "transparent"
    Text {
      anchors.right: parent.right
      text: ""
      color: panel.color2
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  //----- Date module -----
  Rectangle {
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: 60
    color: panel.color2
    Text {
      anchors.centerIn: parent
      text: panel.dateStr
      color: panel.color15
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
  }
  //----- Date arrow -----
  Text {
    text: ""
    color: panel.color2
    font { family: panel.fontFamily; pixelSize: 20 }
  }
  //----- Tray arrow -----
  Rectangle {
    Layout.preferredWidth: 0
    Layout.preferredHeight: panel.height
    color: "transparent"
    Text {
      anchors.right: parent.right
      text: ""
      color: panel.color1
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  //----- System Tray module -----
  Rectangle {
    id: trayContainer
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: trayRow.implicitWidth + 20
    color: panel.color1
    Behavior on Layout.preferredWidth {
      NumberAnimation {
        duration: 100
        easing.type: Easing.InOutQuad
      }
    }
    Row {
      id: trayRow
      anchors.centerIn: parent
      spacing: 4
      Repeater {
        model: SystemTray.items
        delegate: Image {
          id: trayIcon
          width: 20
          height: 20
          source: modelData.icon
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
              if (mouse.button === Qt.LeftButton) {
                modelData.activate()
              } else if (mouse.button === Qt.RightButton) {
                var globalPos = parent.mapToGlobal(Qt.point(0, parent.height))
                modelData.display(panel, globalPos.x-20, globalPos.y-10)
              }
            }
          }
        }
      }
    }
  }
  //----- Tray arrow -----
  Text {
    text: ""
    color: panel.color1
    font { family: panel.fontFamily; pixelSize: 20 }
  }
}
