import QtQuick 2.10
import QtQuick.Controls 2.3

Rectangle {
    id: control
    property color fillColor: "#2979ff"
    width: 10
    height: 10
    radius: 5
    border.width: 1
    border.color: fillColor
    color: "white"

    Rectangle {
        width: 6
        height: 6
        x: 2
        y: 2
        radius: 3
        color: control.fillColor
        visible: true
    }
}
