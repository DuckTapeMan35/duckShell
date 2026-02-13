import QtQuick
import QtQuick.Layouts

RowLayout {
  id: leftRowLayout
  spacing: -1

  property var panel: parent.parent

  //----- Distro Icon -----
  Rectangle {
    id: distroIcon
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: 30
    color: panel.color0
    Text {
      anchors.centerIn: parent
      text: "󰣇"
      color: panel.color9
      font { family: panel.fontFamily; pixelSize: 26 }
    }
  }
  // ----- Distro Icon Arrow -----
  Text {
    text: ""
    color: panel.color0
    font { family: panel.fontFamily; pixelSize: 20 }
  }
  //----- updater Arrow -----
  Rectangle {
    Layout.preferredWidth: 0
    Layout.preferredHeight: panel.height
    color: "transparent"
    Text {
      anchors.right: parent.right
      text: ""
      color: panel.color3
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  Rectangle {
    Layout.preferredWidth: 40
    Layout.preferredHeight: panel.height
    color: panel.color3
    Text {
      anchors.centerIn: parent
      text: (panel.updatesAvailable > 0) ? " " + panel.updatesAvailable : ""
      color: panel.color15
      font { family: panel.fontFamily; pixelSize: 14; bold: true }
    }
    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        panel.triggerUpdate()
      }
    }
  }
  Text {
    text: ""
    color: panel.color3
    font { family: panel.fontFamily; pixelSize: 20 }
  }
  //----- Layout Arrow -----
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
  //----- Layout Name -----
  Rectangle {
    id: layoutNameRect
    Layout.preferredWidth: layoutNameText.paintedWidth
    Layout.preferredHeight: panel.height
    color: panel.color2
    Behavior on Layout.preferredWidth {
      NumberAnimation {
        duration: 100
        easing.type: Easing.InOutQuad
      }
    }
    Text {
      id: layoutNameText
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: " Layout: " + panel.currentLayout + " " + "(" + panel.windowCount + ")"
      color: panel.color15
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
  }
  // ----- Layout Name Arrow -----
  Text {
    text: ""
    color: panel.color2
    font { family: panel.fontFamily; pixelSize: 20 }
  }
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
  // ----- Window Title -----
  Rectangle {
    id: windowTitleRect
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: windowTitleIcon.implicitWidth + windowTitleText.implicitWidth + appidText.implicitWidth + appidIcon.implicitWidth + 10
    Layout.maximumWidth: 300
    color: panel.color1
    Behavior on Layout.preferredWidth {
      NumberAnimation {
        duration: 100
        easing.type: Easing.InOutQuad
      }
    }
    Text {
      id: appidIcon
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: {
        switch (panel.appid) {
          case "librewolf": return " 󰈹"
          case "spotify": return " "
          case "thunderbird": return " "
          case "vesktop": return " "
          case "vlc": return " 󰕼"
          case "org.pwmt.zathura": return " "
          case "kitty": return " "
          case "wofi": return " "
          default: return ""
        }
      }
      color: {
        switch (panel.appid) {
          case "librewolf": return "#86E1FC"
          case "spotify": return "#C7FB6D"
          case "thunderbird": return "#86E1FC"
          case "vesktop": return "#82AAFF"
          case "vlc": return "#F5A97F"
          case "org.pwmt.zathura": return panel.color15
          case "kitty": return panel.color15
          case "wofi": return panel.color15
          default: return panel.color15
        }
      }
      font { family: panel.fontFamily; pixelSize: 16; bold: true }
    }
    Text {
      id: appidText
      anchors.left: appidIcon.right
      anchors.verticalCenter: parent.verticalCenter
      text: {
        if (panel.appid) {
          switch (panel.appid) {
          case "org.pwmt.zathura":
            return " Zathura: "
          default:
            return " " + panel.appid + ": "
          }
        } else {
          return ""
        }
      }
      color: panel.color15
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
    Text {
      id: windowTitleIcon
      anchors.left: appidText.right
      anchors.verticalCenter: parent.verticalCenter
      text: {
        switch (panel.windowTitle) {
        case "nvim":
          return " "
          case "Yazi:":
          return "󰇥 "
        case "":
        case null:
        case undefined:
        case "mango":
          return "  "
        default:
          return ""
        }
      }
      color: {
        switch (panel.windowTitle) {
          case "nvim": return "#C7FB6D"
          case "Yazi:": return "#F9E2AF"
          case "mango": return "#F5A97F"
          default: return panel.color15
        }
      }
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
    Text {
      id: windowTitleText
      width: 200
      elide: Text.ElideRight
      anchors.left: windowTitleIcon.right
      anchors.verticalCenter: parent.verticalCenter
      text: (panel.windowTitle == "Yazi:") ? "yazi" : panel.windowTitle
      color: panel.color15
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
  }
  //----- Window Title Arrow -----
  Text {
    text: ""
    color: panel.color1
    font { family: panel.fontFamily; pixelSize: 20 }
  }
}
