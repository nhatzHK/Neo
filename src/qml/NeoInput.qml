import QtQuick 2.2
import QtQuick.Controls 1.4
import Neo.Node 1.0
//import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

Item {
    id: node
    width: 100
    height: 50

    signal forget(Node n)
    signal showCard(Node n)
    signal forgetAll

    property Component dynamicMenuItem: null //! Component used to create menu items on demand

    // finish initialization
    Component.onCompleted: {
        dynamicMenuItem = Qt.createComponent("NeoMenuItem.qml")
        room.backend.evaluate(backend)
        x = backend.pos.x
        y = backend.pos.y
    }

    onForgetAll: {
        node.forget(backend)
        node.destroy()
    }

    property NeoRoom room: NeoRoom {
    }

    property color color: "#566c73"
    property alias name: backend.name
    property alias backend: backend

    property Item outSlot: NeoRadioButton {
        y: node.height / 2
        x: node.width - 5
        visible: false
        parent: node
    }

    Node {
        id: backend
        type: Node.Input
        onConnectionsHaveChanged: {
            outSlot.visible = room.backend.hasOutConnection(backend)
            room.backend.evaluate(backend)
        }

        onFirstChanged: {
            room.backend.evaluate(backend)
        }

        onSecondChanged: {
            room.backend.evaluate(backend)
        }

        onMinChanged: {
            room.backend.evaluate(backend)
        }

        onMaxChanged: {
            room.backend.evaluate(backend)
        }

        onValueChanged: {
            room.backend.evaluate(backend)
        }

        outPos: Qt.point(node.x + outSlot.x + 7, node.y + outSlot.y + 4)
        pos: Qt.point(node.x, node.y)
    }

    Column {
        anchors.fill: parent
        Rectangle {
            width: parent.width
            height: parent.height / 5
            color: backend.output ? "green" : "red"

            Text {
                anchors.fill: parent
                id: nameTag
                color: "white"
                text: backend.name
                font.bold: true
                font.pointSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: dataArea
            width: parent.width
            height: parent.height / 5 * 4
            color: node.color
            Text {
                anchors.fill: parent
                id: dataText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 20
                text: backend.value.toFixed(2)
                color: "black"
                font.bold: true
            }
        }
    }
    MouseArea {
        id: drag_area
        anchors.fill: parent
        drag.target: node
        propagateComposedEvents: true
        signal rightClick
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        // show context menu on leftclick pressed over the node
        onPressed: {
            if (Qt.RightButton & pressedButtons) {
                contextMenu.popup()
            }
        }

        onClicked: {
            if (!mouse.wasHeld) {
                showCard(backend)
            }
        }
    }

    onXChanged: {
        room.paint()
    }

    onYChanged: {
        room.paint()
    }

    // ! Context menu
    Menu {
        id: contextMenu
        title: qsTr("Node menu")

        Menu {
            title: qsTr("Connect To")
            Menu {
                id: menuConnectNode
                title: qsTr("Nodes")
                onAboutToShow: {
                    menuConnectNode.clear()
                    makeNodeList(menuConnectNode, Node.Output)
                }
            }

            Menu {
                id: menuConnectGate
                title: qsTr("Gates")
                onAboutToShow: {
                    menuConnectGate.clear()
                    makeGateList(menuConnectGate, Node.OrGate)
                    makeGateList(menuConnectGate, Node.AndGate)
                }
            }
        }

        MenuItem {
            text: qsTr("Delete")
            onTriggered: {
                node.forget(backend)
                node.destroy()
            }
        }
    }

    function makeGateList(menu, type) {
        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (room.backend.canConnect(backend, nodes[i]) && nodes[i].type === type) {
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(menu)
                    mnuItem.text = nodes[i].name
                    mnuItem.checkable = true
                    mnuItem.checked = room.backend.connected(backend, nodes[i])

                    menu.insertItem(0, mnuItem)

                    mnuItem.toggled.connect(function (checked) {
                        if (checked) {
                            room.backend.createConnection(backend, nodes[i])
                        } else {
                            room.backend.removeConnections(backend, nodes[i])
                        }

                        backend.connectionsHaveChanged()
                        nodes[i].connectionsHaveChanged()
                        room.paint()
                    })
                }
            }
            rec_for(nodes, i + 1)
        }

        rec_for(room.backend.nodes, 0)
    }

    function makeNodeList(menu) {

        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (room.backend.canConnect(backend, nodes[i]) && nodes[i].type === Node.Output) {
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(menu)
                    mnuItem.text = nodes[i].name
                    mnuItem.checkable = true
                    mnuItem.checked = room.backend.connected(backend, nodes[i])

                    menu.insertItem(0, mnuItem)

                    mnuItem.toggled.connect(function (checked) {
                        if (checked) {
                            room.backend.createConnection(backend, nodes[i])
                        } else {
                            room.backend.removeConnections(backend, nodes[i])
                        }

                        backend.connectionsHaveChanged()
                        nodes[i].connectionsHaveChanged()
                        room.paint()
                    })
                }
            }
            rec_for(nodes, i + 1)
        }

        rec_for(room.backend.nodes, 0)
    }

    function updateBackend(backend) {
        node.backend.change(backend)
    }

    function setPosition(x, y) {
        node.x = x
        node.y = y
    }
}
