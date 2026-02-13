import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtCore
import QtQuick.Controls
import "../wal" as Wal
import "./barLayouts"

PanelWindow {
  id: panel
  // Color scheme and font properties
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
  property string fontFamily: "Jetbrains Mono Nerd Font"
  property int fontSize: 12

  // reference to model data
  required property var modelData

  // Properties for data sharing
  property int cpuUsage: 0
  property var lastCpuTotal: 0
  property var lastCpuIdle: 0
  property int memUsage: 0
  property int temperatureValue: 0
  property string windowTitle: ""
  property string appid: ""
  property var tags: []
  property string dateStr: Qt.formatDateTime(new Date(), "MM-dd")
  property string fullDate: Qt.formatDateTime(new Date(), "dd MMMM, yyyy").toUpperCase()
  property string timeStr: Qt.formatDateTime(new Date(), "HH:mm")
  property string songTitle: ""
  property bool isPlaying: false
  property string pickedColor: ""
  property string currentLayout: ""
  property string currentHeadline: ""
  property string currentWebsite: ""
  property int updatesAvailable: 0
  property int windowCount: 0

  // basic panel setup
  anchors {
      top: true
      left: true
      right: true
  }
  implicitHeight: 25
  margins {
      top: 0
      left: 0
      right: 0
  }
  Rectangle {
      id: bar
      anchors.fill: parent
      color: panel.color0
      radius: 0
  }
  // ------------------- Time Update Timer -----------------
  Timer {
    interval: 10000
    running: true
    repeat: true
    onTriggered: {
      dateStr = Qt.formatDateTime(new Date(), "MM-dd")
      fullDate = Qt.formatDateTime(new Date(), "dd MMMM, yyyy").toUpperCase()
      timeStr = Qt.formatDateTime(new Date(), "HH:mm")
    }
  }

  // ----------------- Song Monitor and toggle -----------------
  Process {
    id: musicTitleProc
    command: ["sh", "-c", "rmpc song"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var json = JSON.parse(data)
        songTitle = json.metadata?.title ?? json.file
      }
    }
    Component.onCompleted: running = true
  }
  Process {
    id: musicStatusProc
    command: ["sh", "-c", "rmpc status"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var json = JSON.parse(data)
        isPlaying = (json.state === "Play")
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      musicTitleProc.running = true
      musicStatusProc.running = true
    }
  }
  Process {
    id: musicToggleProc
    command: ["sh", "-c", "rmpc togglepause"]
  }
  Process {
    id: musicClientOpenProc
    command: ["kitty", "-e", "rmpc"]
  }

  //------------------- Color Picker -----------------
  Process {
    id: colorPickProc
    command: ["sh", "-c", "~/.config/quickshell/scripts/waypick.sh"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        pickedColor = data.trim()
      }
    }
  }

  // ----------------- Notification Trigger -----------------
  Process {
    id: notifProc
    command: ["sh", "-c", "swaync-client -t"]
  }

  // ----------------- Power Menu Trigger -----------------
  Process {
    id: powerProc
    command: ["sh", "-c", "~/.config/wlogout/wlogoutmango.sh"]
  }

  // ----------------- CPU Monitor -----------------
  Process {
    id: cpuProc
    command: ["sh", "-c", "head -1 /proc/stat"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var p = data.trim().split(/\s+/)
        var idle = parseInt(p[4]) + parseInt(p[5])
        var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
        if (lastCpuTotal > 0) {
          cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
        }
        lastCpuTotal = total
        lastCpuIdle = idle
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: cpuProc.running = true
  }

  // ----------------- Memory Monitor -----------------
  Process {
    id: memProc
    command: ["sh", "-c", "free -m | grep Mem"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var parts = data.trim().split(/\s+/)
        var total = parseInt(parts[1]) || 1
        var used = parseInt(parts[2]) || 0
        memUsage = Math.round((used / total) * 100)
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: memProc.running = true
  }

  // ----------------- Temperature Monitor -----------------
  Process {
    id: tempProc
    command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone*/temp | tail -1"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        temperatureValue = Math.round(parseInt(data.trim()) / 1000)
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: tempProc.running = true
  }

  // ----------------- Window Title -----------------
  Process {
    id: windowProc
    command: ["sh", "-c", "mmsg -wc"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var parts = data.trim().split(/\s+/)
        if (parts[1] === "title") {
          if (parts[2]) {
            windowTitle = parts[2]
          } else {
            windowTitle = "mango"
          }
        } else {
          if (parts[2]) {
            appid = parts[2]
          } else {
            appid = ""
          }
        }
      }
    }
    Component.onCompleted: running = true
  }

  // ----------------- Tags Listener -----------------
  Process {
    id: tagProc
    command: ["mmsg", "-w", "-t"]
    stdout: SplitParser {
      onRead: function(line) {
        var newTags = panel.tags.slice()
        var parts = line.trim().split(/\s+/)
        if (parts.length >= 6 && parts[1] === "tag") {
          var index = parseInt(parts[2]) - 1
          var focused = parts[3] === "1"
          if (focused) {
            panel.windowCount = parseInt(parts[4])
          }
          var windows = parseInt(parts[4])
          var urgent = parts[5] === "1"
          newTags[index] = {
            focused: focused,
            hasWindows: windows > 0,
            urgent: urgent
          }
          panel.tags = newTags
        }
      }
    }
    Component.onCompleted: running = true
  }

  //------------------- Layout Monitor ------------------
  Process {
    id: layoutProc
    command: ["sh", "-c", "mmsg -w -l"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var parts = data.trim().split(/\s+/)
        var shortCode = parts[2] || ""
        switch(shortCode) {
          case "T":
            currentLayout = "tile"
            break
          case "S":
            currentLayout = "scroller"
            break
          case "M":
            currentLayout = "monocle"
            break
          case "G":
            currentLayout = "grid"
            break
          case "K":
            currentLayout = "deck"
            break
          case "CT":
            currentLayout = "center_tile"
            break
          case "RT":
            currentLayout = "right_tile"
            break
          case "VS":
            currentLayout = "vertical_scroller"
            break
          case "VT":
            currentLayout = "vertical_tile"
            break
          case "VG":
            currentLayout = "vertical_grid"
            break
          case "VK":
            currentLayout = "vertical_deck"
            break
          case "TG":
            currentLayout = "tgmix"
            break
          default:
            currentLayout = shortCode  // fallback, just in case
        }
      }
    }
    Component.onCompleted: running = true
  }

  //------------------- News Monitor -----------------
  Process {
    id: newsProc
    command: ["sh", "-c", "~/.config/quickshell/scripts/news.sh"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var parts = data.trim().split(" ||||| ")
        currentHeadline = (parts[0] || "").trim() + " "
        currentWebsite = (parts[1] || "").trim()
      }
    }
    Component.onCompleted: running = true
  }

  //------------------- Update Monitor -----------------
  Process {
    id: updateProc
    command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        panel.updatesAvailable = parseInt(data.trim())
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 3600000
    running: true
    repeat: true
    onTriggered: updateProc.running = true
  }

  //------------------- Update Trigger -----------------
  Process {
    id: updateTriggerProc
    command: ["kitty", "-e", "sudo", "pacman", "-Syu"]
  }

  //------------------- Helper Functions -----------------
  // Function to toggle music
  function toggleMusic() {
    musicToggleProc.running = true
  }
  // Function to open music client
  function openMusicClient() {
    if (musicClientOpenProc.running) return
    musicClientOpenProc.running = true
  }

  // Function to pick color
  function pickColor() {
    colorPickProc.running = true
  }

  // Function to show notifications
  function showNotifications() {
    notifProc.running = true
  }

  // Function to show power menu
  function showPowerMenu() {
    powerProc.running = true
  }
  // Function to trigger update
  function triggerUpdate() {
    updateTriggerProc.running = true
    updatesAvailable = 0
  }

  //------------------- Layouts -----------------
  LeftLayout {
    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
    }
    panel: panel
  }

  CenterLayout {
    anchors {
      horizontalCenter: parent.horizontalCenter
      verticalCenter: parent.verticalCenter
    }
    panel: panel
  }

  RightLayout {
    anchors {
      right: parent.right
      verticalCenter: parent.verticalCenter
    }
    panel: panel
  }
}
