import QtQuick
import QtQuick.Layouts

RowLayout {
  id: rightRowLayout
  spacing: -1

  required property var panel

  //---- Music arrow -----
  Text {
    text: ""
    color: panel.color1
    font { family: panel.fontFamily; pixelSize: 20 }
  }
  //---- Music module -----
  Rectangle {
    id: music
    Layout.preferredWidth: musicIcon.paintedWidth + musicText.paintedWidth
    Layout.maximumWidth: 200
    height: 30
    color: panel.color1
    clip: true

    Behavior on Layout.preferredWidth {
      NumberAnimation {
        duration: 100
        easing.type: Easing.InOutQuad
      }
    }


    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: (mouse) => {
        if (mouse.button === Qt.RightButton) {
          console.log("Right click - calling openMusicClient()")
          panel.openMusicClient()
        } else {
          panel.toggleMusic()
        }
      }
    }

    Row {
      anchors.fill: parent
      spacing: 2

      // Icon stays in place
      Text {
        id: musicIcon
        text: panel.isPlaying ? "  " : "  "
        font.pixelSize: 14
        font.bold: true
        color: panel.color15
        anchors.verticalCenter: parent.verticalCenter
      }

      // Scrollable song title
      Flickable {
        id: flick
        width: parent.width - musicIcon.width
        height: parent.height
        contentWidth: musicText.paintedWidth
        interactive: false
        clip: true

        Text {
          id: musicText
          text: panel.songTitle + "  "
          font.pixelSize: 14
          font.bold: true
          color: panel.color15
          anchors.verticalCenter: parent.verticalCenter
        }

        SequentialAnimation on contentX {
          loops: Animation.Infinite
          running: musicText.paintedWidth > flick.width
          NumberAnimation { from: 0; to: musicText.paintedWidth - flick.width; duration: 10000 }
          PauseAnimation { duration: 100 }
          NumberAnimation { from: musicText.paintedWidth - flick.width; to: 0; duration: 10000 }
          PauseAnimation { duration: 100 }
        }
      }
    }
  }
  //---- Music arrow -----
  Rectangle {
    Layout.preferredWidth: 0
    Layout.preferredHeight: 26
    color: "transparent"
    Text {
      text: ""
      color: panel.color1
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }

  //----- Color Picker arrow -----
  Text {
    text: ""
    color: panel.color2
    font { family: panel.fontFamily; pixelSize: 20 }
  }
  //----- Color Picker -----
  Rectangle {
    id: colorPicker
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: colorPickDisplay.paintedWidth + colorPickName.paintedWidth + 10
    color: panel.color2
    Text {
      id: colorPickDisplay
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: " "
      color: panel.pickedColor ? panel.pickedColor : panel.color15
      font { family: panel.fontFamily}
    }
    Text {
      id: colorPickName
      anchors.left: colorPickDisplay.right
      anchors.verticalCenter: parent.verticalCenter
      color: panel.color15
      text: panel.pickedColor ? panel.pickedColor : " "
      font { family: panel.fontFamily; pixelSize: panel.fontSize; bold: true }
    }
    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        panel.pickColor()
      }
    }
  }
  //----- Color Picker arrow -----
  Rectangle {
    Layout.preferredWidth: 0
    Layout.preferredHeight: 26
    color: "transparent"
    Text {
      text: ""
      color: panel.color2
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  //----- Notifications arrow -----
  Text {
      text: ""
      color: panel.color3
      font { family: panel.fontFamily; pixelSize: 20 }
  }
  Rectangle {
    id: notif
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: 25
    color: panel.color3
    Text {
      anchors.centerIn: parent
      text: " "
      color: panel.color15
      font { family: panel.fontFamily; pixelSize: 16; bold: true }
    }
    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        panel.showNotifications()
      }
    }
  }
  //----- Notifications arrow -----
  Rectangle {
    Layout.preferredWidth: 0
    Layout.preferredHeight: 26
    color: "transparent"
    Text {
      text: ""
      color: panel.color3
      font { family: panel.fontFamily; pixelSize: 20 }
    }
  }
  //----- Power arrow -----
  Text {
    text: ""
    color: panel.color0
    font { family: panel.fontFamily; pixelSize: 20 }
  }
  //----- Power module -----
  Rectangle {
    Layout.preferredHeight: parent.height
    Layout.preferredWidth: 25
    color: panel.color0
    Text {
      anchors.centerIn: parent
      text: ""
      color: panel.color15
      font { family: panel.fontFamily; pixelSize: 16; bold: true }
    }
    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
          panel.showPowerMenu()
      }
    }
  }
}
