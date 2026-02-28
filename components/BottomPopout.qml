import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import QtCore
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import "../wal" as Wal

ColumnLayout {
  id: bottomPopoutColumn
  objectName: "bottomPopoutColumn"
  required property var modelData
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
  property string wallpaper: ""
  property bool bgChanged: false
  property string themeChangerPath: ""
  property string wallpaperPath: ""

  SocketServer {
    active: true
    path: Quickshell.env("HOME") + "/.config/quickshell/wallpaper.sock"
    handler: Socket {
      parser: SplitParser {
        onRead: message => {
          if (message.trim() === "") return
          if (message.trim() === "toggle") {
            backgroundShape.toggle()
          }
        }
      }
    }
  }


  PanelWindow {
    id: bottomPopoutRowTrigger
    anchors.bottom: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: 3
    implicitWidth: 1200
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay

    FolderListModel {
      id: wallpaperModel
      folder: wallpaperPath
      nameFilters: ["*.jpg", "*.png", "*.jpeg", "*.webp"]
      showDirs: false
      showDotAndDotDot: false
      sortField: FolderListModel.Name
      sortReversed: false
    }

    MouseArea {
      id: triggerHoverArea
      anchors.fill: parent
      hoverEnabled: true
      propagateComposedEvents: true
      acceptedButtons: Qt.NoButton

      // Timer for delayed hover
      property bool isHovered: false
      
      Timer {
          id: hoverTimer
          interval: 200
          onTriggered: {
              if (triggerHoverArea.isHovered) {
                  backgroundShape.show()
              }
          }
      }
      
      onEntered: {
          isHovered = true
          hoverTimer.restart()
      }
      
      onExited: {
          isHovered = false
          hoverTimer.stop()
      }
      
      onCanceled: {
          isHovered = false
          hoverTimer.stop()
      }
    }
  }

  PanelWindow {
    id: bottomPopout
    anchors.bottom: true
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: 200
    implicitWidth: 1200
    visible: false
    color: "transparent"
    focusable: true

    WlrLayershell.layer: WlrLayer.Overlay

    margins {
      top: 0
      left: 0
      right: 0
      bottom: 0
    }

    Process {
      id: setBackgroundProc
      property string wallpaperPath: ""
      command: [themeChangerPath, wallpaperPath]
      running: false
    }

    // First, create a Shape for the mask (invisible, just for the shape)
    Shape {
      id: maskShape
      width: parent.width
      height: parent.height
      visible: false  // Not visible, just used as mask source
      antialiasing: true
      smooth: true
      layer.enabled: true
      layer.smooth: true
      layer.samples: 128
      ShapePath {
        strokeWidth: -1
        fillColor: "white"
        startX: bottomPopout.width
        startY: bottomPopout.height
        PathArc {
          x: bottomPopout.width - 20
          y: bottomPopout.height - 20
          radiusX: 20
          radiusY: 20
          direction: PathArc.Clockwise
        }
        PathLine {
          x: bottomPopout.width - 20
          y: 20
        }
        PathArc {
          x: bottomPopout.width - 40
          y: 0
          radiusX: 20
          radiusY: 20
          direction: PathArc.Counterclockwise
        }
        PathLine {
          x: 40
          y: 0
        }
        PathArc {
          x: 20
          y: 20
          radiusX: 20
          radiusY: 20
          direction: PathArc.Counterclockwise
        }
        PathLine {
          x: 20
          y: bottomPopout.height - 20
        }
        PathArc {
          x: 0
          y: bottomPopout.height
          radiusX: 20
          radiusY: 20
          direction: PathArc.Clockwise
        }
      }
    }

    // The visible background shape
    Rectangle {
      id: backgroundShape
      width: parent.width
      height: parent.height
      color: bottomPopoutColumn.color0
      antialiasing: true
      smooth: true
      
      // Apply the curved shape using OpacityMask
      layer.enabled: true
      layer.effect: OpacityMask {
        maskSource: maskShape
      }

      transformOrigin: Item.Bottom
      property bool hiding: false
      y: hiding ? 0 : 50
      opacity: hiding ? 0 : 1

      function toggle() {
        if (bottomPopout.visible) {
          backgroundShape.hide()
        } else {
          backgroundShape.show()
        }
      }

      function show() {
        bottomPopout.visible = true
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
        properties: "y"
        from: 250
        to: 0
        duration: 150
      }

      PropertyAnimation {
        id: hideAnimation
        target: backgroundShape
        properties: "y"
        from: 0
        to: 250
        duration: 150
        onStopped: bottomPopout.visible = false
      }
    }

    PathView {
      id: wallpaperView
      anchors.fill: backgroundShape
      anchors.bottomMargin: 40
      model: wallpaperModel
      interactive: true
      snapMode: PathView.SnapOneItem
      preferredHighlightBegin: 0.5
      preferredHighlightEnd: 0.5
      pathItemCount: 5
      property real itemSpacing: -50

      // Apply the same mask as the background
      layer.enabled: true
      layer.effect: OpacityMask {
        maskSource: maskShape
      }

      focus: true
      Keys.onPressed: (event) => {
        // Check if the key is a printable character (letter, number, punctuation)
        if (
            event.key >= Qt.Key_Space && 
            event.key <= Qt.Key_ydiaeresis && 
            event.key !== Qt.Key_Left && 
            event.key !== Qt.Key_Right && 
            event.key !== Qt.Key_Up && 
            event.key !== Qt.Key_Down && 
            event.key !== Qt.Key_Return && 
            event.key !== Qt.Key_Enter && 
            event.key !== Qt.Key_Escape
          )
        {
          // Redirect to search input
          searchInput.forceActiveFocus()
          // If it's a backspace or delete, clear the search
          if (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete) {
            searchInput.text = ""
          } else {
            // Set the text to the pressed key
            searchInput.text = event.text
          }
          event.accepted = true
        } else if (event.key === Qt.Key_Right) {
          incrementCurrentIndex()
          event.accepted = true
        } else if (event.key === Qt.Key_Left) {
          decrementCurrentIndex()
          event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          event.accepted = true
          console.log(themeChangerPath)
          // Use setTimeout to avoid immediate execution during key handling
          Qt.callLater(function() {
            var fileUrl = wallpaperModel.get(wallpaperView.currentIndex, "fileUrl")
            if (fileUrl) {
              bottomPopoutColumn.wallpaper = fileUrl
              setBackgroundProc.wallpaperPath = fileUrl.toString().replace("file://", "")
              setBackgroundProc.running = true
              wallpaperView.focus = true
              backgroundShape.hide()
            }
          })
        } else if (event.key === Qt.Key_Escape) {
          backgroundShape.hide()
          event.accepted = true
        } else if (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete) {
          // Handle backspace/delete when focused on wallpaperView
          searchInput.forceActiveFocus()
          searchInput.text = ""
          event.accepted = true
        }
      }

      path: Path {
        startX: -wallpaperView.itemSpacing
        startY: wallpaperView.height / 2

        PathLine {
          x: wallpaperView.width + wallpaperView.itemSpacing
          y: wallpaperView.height / 2
        }
      }
      
      delegate: Item {
        width: 192
        height: 108
        scale: PathView.isCurrentItem ? 1.2 : 1

        Behavior on scale { NumberAnimation { duration: 150 } }

        Image {
          id: img
          anchors.fill: parent
          anchors.centerIn: parent
          source: fileUrl
          fillMode: Image.PreserveAspectCrop
          smooth: true
          asynchronous: true
          cache: true
          sourceSize.width: 320
          sourceSize.height: 400
          property bool rounded: true
          property bool adapt: true

          layer.enabled: rounded
          layer.effect: OpacityMask {
            maskSource: Item {
              width: img.width
              height: img.height
              Rectangle {
                anchors.centerIn: parent
                width: img.adapt ? img.width : Math.min(img.width, img.height)
                height: img.adapt ? img.height : width
                radius: 7
              }
            }
          }
        }

        Text {
          id: wallpaperName
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: img.bottom
          text: fileName
          color: bottomPopoutColumn.color15
          font.pixelSize: 12
          font.bold: true
          elide: Text.ElideRight
          width: parent.width - 10
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
          anchors.fill: parent
          onWheel: (event) => {
            if (event.angleDelta.y > 0) {
              wallpaperView.currentIndex = wallpaperView.currentIndex - 1
            } else if (event.angleDelta.y < 0) {
              wallpaperView.currentIndex = wallpaperView.currentIndex + 1
            }
            event.accepted = true
          }
          onClicked: {
            wallpaperView.currentIndex = index
            bottomPopoutColumn.wallpaper = fileUrl
            setBackgroundProc.wallpaperPath = fileUrl.toString().replace("file://", "")
            setBackgroundProc.running = true
            wallpaperView.focus = true
            backgroundShape.hide()
          }
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      propagateComposedEvents: true
      acceptedButtons: Qt.LeftButton
      onClicked: (mouse) => {
        // Convert to inputBackground coordinates
        var inputPos = inputBackground.mapFromItem(this, mouse.x, mouse.y)
        // If click is NOT in inputBackground, focus wallpaperView
        if (!(inputPos.x >= 0 && inputPos.x <= inputBackground.width && 
              inputPos.y >= 0 && inputPos.y <= inputBackground.height)) {
            wallpaperView.focus = true
        }
        // Always allow event to propagate (for delegate clicks, etc.)
        mouse.accepted = false
      }
    }

    Rectangle {
      id: inputBackground
      color: bottomPopoutColumn.color8
      anchors.top: wallpaperView.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.topMargin: 5
      height: 28
      width: backgroundShape.width - 120
      radius: 10
      visible: bottomPopout.visible
      Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        anchors.leftMargin: 10
        text: ""
        color: bottomPopoutColumn.color15
        font.pixelSize: 14
      }
      TextInput {
        id: searchInput
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
        anchors.leftMargin: 30
        anchors.rightMargin: 10
        font.pixelSize: 14
        color: bottomPopoutColumn.color15
        Timer {
            id: searchTimer
            interval: 300 // Delay after typing stops
            onTriggered: {
                searchInput.findBestMatch(searchInput.text)
            }
        }
        Keys.onPressed: {
          if (event.key === Qt.Key_Escape) {
            // Clear search text
            searchInput.text = ""
            wallpaperView.focus = true
            event.accepted = true
          }
        }
        onTextChanged: {
          searchTimer.restart()
        }
        onAccepted: {
          Qt.callLater(function() {
            var fileUrl = wallpaperModel.get(wallpaperView.currentIndex, "fileUrl")
            if (fileUrl) {
              bottomPopoutColumn.wallpaper = fileUrl
              setBackgroundProc.wallpaperPath = fileUrl.toString().replace("file://", "")
              setBackgroundProc.running = true
              wallpaperView.focus = true
              backgroundShape.hide()
            }
          })
        }
        function findBestMatch(searchText) {
          if (!searchText.trim())
            return
          var bestMatchIndex = -1
          var bestMatch = null
          var searchLower = searchText.toLowerCase()
          for (var i = 0; i < wallpaperModel.count; i++) {
            var fileName = wallpaperModel.get(i, "fileName")
            var result = calculateMatchScore(fileName, searchLower)
            if (!result)
                continue
            if (!bestMatch ||
              result.score > bestMatch.score ||
              (result.score === bestMatch.score && result.span < bestMatch.span) ||
              (result.score === bestMatch.score &&
              result.span === bestMatch.span &&
              result.length < bestMatch.length))
            {
              bestMatch = result
              bestMatchIndex = i
            }
          }
          if (bestMatchIndex >= 0)
            wallpaperView.currentIndex = bestMatchIndex
        }
        function calculateMatchScore(candidate, query) {
          candidate = candidate.toLowerCase()
          query = query.toLowerCase()
          var qi = 0
          var start = -1
          var end = -1
          // simple forward fuzzy match
          for (var i = 0; i < candidate.length && qi < query.length; i++) {
              if (candidate[i] === query[qi]) {
                  if (start === -1)
                      start = i
                  qi++
                  if (qi === query.length)
                      end = i
              }
          }
          if (qi !== query.length)
              return null // no match
          var span = end - start + 1
          var score = 100
          // Prefer tighter matches
          score -= span * 5
          // Prefer shorter filenames
          score -= candidate.length
          // Prefer matches earlier in string
          score -= start * 2
          return {
            score: score,
            span: span,
            length: candidate.length,
            start: start
          }
        }
      }
    }

    MouseArea {
      id: panelHoverArea
      anchors.fill: parent
      hoverEnabled: true
      propagateComposedEvents: true
      acceptedButtons: Qt.NoButton

      onExited: {
        wallpaperView.focus = true
        backgroundShape.hide()
      }
    }
  }
}
