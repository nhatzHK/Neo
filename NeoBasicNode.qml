import QtQuick 2.0
import QtQuick.Controls 1.4

Rectangle {
    id: node
    x: 210
    y: 34
    width: 130
    height: 58
    color: "lightblue"
    property NeoCanvas canvas: NeoCanvas {
    }
    property ListModel ioList: ListModel {
    }

    Drag.active: drag_area.drag.active
    Drag.hotSpot.x: 130 / 2
    Drag.hotSpot.y: 58 / 2

    onXChanged: {
        canvas.baseCanvas.requestPaint()
    }

    onYChanged: {
        canvas.baseCanvas.requestPaint()
    }

    MouseArea {
        id: drag_area
        x: 0
        y: 0
        anchors.fill: parent
        drag.target: parent
    }

    function addIO(type) {
        var component = Qt.createComponent("NeoRadioButton.qml")
        if (component.status == Component.Ready) {
            var button = component.createObject(group.contentItem)
            button.x = type === "in" ? -10 : node.width - 13
            button.y = node.height / 4
        }
    }

    GroupBox {
        id: group
        anchors.fill: parent
    }
}
