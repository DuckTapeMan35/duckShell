//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import "components"
import "wal" as Wal

Scope {
  id: root

  property string themeChangerPath: ""

  function expandPath(p) {
    if (!p)
        return p
    // expand ~
    if (p.startsWith("~")) {
      var home = ProcessEnvironment.value("HOME")
      p = home + p.substring(1)
    }
    // expand $XDG_* variables
    p = p.replace(/\$([A-Z0-9_]+)/g, function(_, name) {
      var val = ProcessEnvironment.value(name)
      return val ? val : "$" + name
    })
    return p
  }

  Process {
    id: walProc
    command: ["/home/duck/.config/quickshell/scripts/wal_stream.py"]
    stdout: SplitParser {
      property var lines: []
      property var colorMap: ({})
      onRead: function(line) {
        var trimmed = line.trim()
        if (trimmed === "") return
        // Check if this is a color definition
        if (trimmed.startsWith("color")) {
          var parts = trimmed.split("=")
          if (parts.length === 2) {
            var colorIndex = parts[0]
            var colorValue = parts[1]
            colorMap[colorIndex] = colorValue
          }
        }
        // Check if this is the theme changer path
        else if (trimmed.startsWith("themeChangerPath=")) {
          var pathParts = trimmed.split("=")
          if (pathParts.length === 2) {
            var path = pathParts[1]
            root.themeChangerPath = path
          }
        }
        // Check if this is the wallpaper directory path
        else if (trimmed.startsWith("wallpaperPath=")) {
          var pathParts = trimmed.split("=")
          if (pathParts.length === 2) {
            var path = expandPath(pathParts[1])
            root.wallpaperPath = path
          }
        }
        // Count how many color entries we have (color0 through color15)
        var colorCount = 0
        for (var i = 0; i <= 15; i++) {
          if (colorMap["color" + i] !== undefined) {
            colorCount++
          }
        }
        // When we have all 16 colors, update the Colors singleton
        if (colorCount === 16) {
          // Convert color map to array in order color0..color15
          var colorArray = []
          for (var i = 0; i <= 15; i++) {
              colorArray.push(colorMap["color" + i])
          }
          Wal.Colors.colorList = colorArray
          colorMap = {} // reset for next update
        }
      }
    }
    Component.onCompleted: running = true
  }

  property var defaultAudioSink: Pipewire.defaultAudioSink
  property int volume: defaultAudioSink && defaultAudioSink.audio ? Math.round(defaultAudioSink.audio.volume * 100) : 0
  property bool volumeMuted: defaultAudioSink && defaultAudioSink.audio ? defaultAudioSink.audio.muted : false

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink]
  }

  Variants {
    model: Quickshell.screens
    Overhang {}
  }

  Variants {
    model: Quickshell.screens
    Bar {}
  }

  Variants {
    model: Quickshell.screens
    delegate: RightPopout {
      id: rightPopoutInstance
      volume: root.volume
      volumeMuted: root.volumeMuted
      defaultAudioSink: root.defaultAudioSink
      modelData: modelData
    }
  }

  Variants {
    model: Quickshell.screens
    delegate: BottomPopout {
      id: bottomPopoutInstance
      modelData: modelData
      themeChangerPath: root.themeChangerPath
      wallpaperPath: root.wallpaperPath
    }
  }
}
