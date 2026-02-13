pragma Singleton
import QtQuick
import QtQml

QtObject {
    id: colors

    signal colorsChanged()  // we’ll manually emit

    property var colorList: []

    // Set colors safely and emit signal
    function setColors(newColors) {
        colorList = newColors.slice()  // new array reference
        colorsChanged()                // manually notify
    }

    // Access function
    function color(index) {
        return (index >= 0 && index < colorList.length && colorList[index])
               ? colorList[index]
               : "#000000"
    }
}

