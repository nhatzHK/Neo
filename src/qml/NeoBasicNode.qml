import QtQuick 2.2
import QtQuick.Controls 1.4

Rectangle {
    id: node
    x: 210
    y: 34
    width: 130
    height: 58
    color: "lightblue"

    property string name: "Name"
    property bool hasIn: false
    property Item inSlot: Item {
    }
    property bool hasOut: false
    property Item outSlot: Item {
    }
    property NeoCanvas canvas: NeoCanvas {
    }
    property var connections: []
    property var elements: []
    property Component radioButton: null
    property Component dynamicMenuItem: null

    Component.onCompleted: {
        radioButton = Qt.createComponent("NeoRadioButton.qml")
        dynamicMenuItem = Qt.createComponent("NeoMenuItem.qml")
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
        anchors.fill: parent
        drag.target: parent

        signal rightClick
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            if (Qt.RightButton & pressedButtons) {
                contextMenu.popup()
            }
        }
    }

    GroupBox {
        id: group
        anchors.fill: parent
    }

    Menu {
        id: contextMenu
        title: qsTr("Node menu")

        Menu {
            title: qsTr("Connect")

            Menu {
                id: menuConnectIn
                title: "Receive"

                onAboutToShow: updateConnectableList("in")
            }
            Menu {
                id: menuConnectOut
                title: "Send"

                onAboutToShow: updateConnectableList("out")
            }
        }
    }

    Label {
        anchors.fill: parent
        text: name
        x: parent.width / 2
        y: parent.width / 2
        font.bold: true
        font.pointSize: 20
    }

    function clearMenu(menu) {

        for (var i = 0; i < menu.items.length; ) {
            menu.removeItem(menu.items[i])
        }
    }

    function updateConnectableList(type) {
        var menu
        switch (type) {
        case "in":
            clearMenu(menuConnectIn)
            menu = menuConnectIn
            break
        case "out":
            clearMenu(menuConnectOut)
            menu = menuConnectOut
            break
        default:
            console.error(
                        "[NeoBasicNode] Bad 'type' parameter. Should be 'in' or 'out'")
        }

        var el = []
        for (var i = 0; i < elements.length; ++i) {
            var inConnections = false // is the element in the connection array

            if (elements[i] === node) {
                continue
            }

            for (var j = 0; j < connections.length && !inConnections; ++i) {
                console.log("I will not print this")
                if (elements[i] === connections[j] || elements[i]) {
                    console.log("Already in")
                } else {
                    console.log(elements[i] + "<|>" + connections[j] + "<|>" + node)
                }

                break
            }

            if (!inConnections) {
                el.push(elements[i])
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(contextMenu, {
                                                                   text: elements[i].name,
                                                                   onToggled: addIO(
                                                                                  type, elements[i])
                                                               })
                    menu.insertItem(0, mnuItem)
                } else {
                    console.log("whoops")
                }
            }
        }
    }

    function addSlot(type) {
        if (!(type === "in" || type === "out"))
            return

        if ((hasIn && type === "in") || (hasOut && type === "out"))
            return

        if (radioButton.status === Component.Ready) {
            var button = radioButton.createObject(group.contentItem)
            button.y = node.height / 4

            switch (type) {
            case "in":
                button.x = -10
                node.hasIn = true
                inSlot = button
                break
            case "out":
                button.x = node.width - 13
                node.hasOut = true
                outSlot = button
            }
        }
    }

    function addIO(type, item) {
        if (type === "in") {
            item.addSlot("in")
            node.addSlot("out")
            item.connections.push(node)
        } else if (type === "out") {
            item.addSlot("out")
            node.addSlot("in")
            node.connections.push(item)
        } else {
            console.error(
                        "[NeoBasicNode] Bad 'type' parameter. Should be 'in' or 'out")
        }

        canvas.baseCanvas.requestPaint()
    }
}
