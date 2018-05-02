import QtQuick 2.0
import QtQuick.Controls 1.4
import Neo.Node 1.0

Canvas {
    id: node

    width: 100
    height: 100

    signal forget(Node g)
    signal showCard(Node g)

    property Component dynamicMenuItem: null
    property NeoRoom room: NeoRoom {
    }
    property alias name: backend.name
    property alias backend: backend

    property Item inSlot: NeoRadioButton {
        y: node.height / 2
        x: -4
        visible: false
        parent: node
    }

    Component.onCompleted: {
        dynamicMenuItem = Qt.createComponent("NeoMenuItem.qml")
        room.backend.evaluate(backend)
    }

    Node {
        id: backend
        type: Node.Output
        onConnectionsHaveChanged: {
            inSlot.visible = room.backend.hasInConnection(backend)
            room.backend.evaluate(backend)
            status.requestPaint()
        }
        inPos: Qt.point(node.x + inSlot.x, node.y + inSlot.y + 4)
    }

    Canvas {
        width: 10
        height: 10
        x: node.width / 2 - 5
        y: node.height / 3 * 2
        id: status
        onPaint: {
            var ctx = getContext("2d")

            ctx.fillStyle = backend.output ? "green" : "red"
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, width / 2, 0, 2 * Math.PI)
            ctx.fill()
        }
    }

    Text {
        id: nameTag
        color: "white"
        text: backend.name

        font.bold: true
        font.pointSize: 14
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    onXChanged: {
        room.paint()
    }

    onYChanged: {
        room.paint()
    }
    onPaint: {
        var ctx = getContext("2d")

        ctx.lineWidth = 3
        ctx.fillStyle = 'blue'

        ctx.arc(width / 2, height / 2, height / 2, 0, 2 * Math.PI)
        ctx.fill()
    }

    MouseArea {
        id: drag_area
        anchors.fill: parent
        drag.target: node
        propagateComposedEvents: true
        signal rightClick
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        // show context menu on leftclick pressed over the gate
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

    // ! Context menu
    Menu {
        id: contextMenu
        title: qsTr("Gate menu")

        Menu {
            title: qsTr("Connect To")
            Menu {
                id: menuConnectNode
                title: qsTr("Nodes")
                onAboutToShow: {
                    menuConnectNode.clear()
                    var type = backend.type === Node.Output ? Node.Input : Node.Output
                    makeNodeList(menuConnectNode, type)
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

            if (nodes[i].type === type) {
                console.log(nodes[i])
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
                            room.backend.removeAllConnections(backend, nodes[i])
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

    function makeNodeList(menu, type) {

        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (nodes[i] !== node.backend && nodes[i].type === type) {
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
                            room.backend.removeAllConnections(backend, nodes[i])
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
}
