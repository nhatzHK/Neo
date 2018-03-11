import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

ApplicationWindow {
    id: app

    property Component basicNode: Component.Null
    property var elements: []
    property variant mouseEvent: null
    property int count: 0

    width: 640
    height: 480
    visible: true

    // set unresizable
    maximumHeight: height
    maximumWidth: width
    minimumWidth: width
    minimumHeight: height

    title: qsTr("Neo")

    Component.onCompleted: {

        basicNode = Qt.createComponent("NeoBasicNode.qml")
        menuBar.getMenu("file").insertItem(0, createMenu)
    }

    menuBar: NeoMenuBar {
        id: menuBar
    }

    NeoCanvas {
        id: canvas
        nodes: elements
    }

    MouseArea {
        id: mouseArea
        x: 0
        y: 0
        anchors.fill: parent
        drag.target: parent

        signal rightClick
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            if (Qt.RightButton & pressedButtons) {
                contextMenu.popup()
                mouseEvent = mouse
            }
        }
    }

    Menu {
        id: contextMenu

        title: qsTr("Canvas Menu")

        Menu {
            id: createMenu
            title: qsTr("Create")

            MenuItem {
                text: "NeoBasicNode"
                onTriggered: createBasicNode()
            }
        }
    }

    function createBasicNode() {
        if (basicNode.status === Component.Ready) {
            var node = basicNode.createObject(app, {"x": mouseEvent.x, "y": mouseEvent.y})
            node.elements = elements
            node.name = String(count)
            count += 1
            elements.push(node)
            canvas.baseCanvas.requestPaint()
        } else {
            console.warn("woopidoop")
        }
    }
}
