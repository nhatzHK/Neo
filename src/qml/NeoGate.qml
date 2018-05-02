import QtQuick 2.0
import QtQuick.Controls 1.4
import Neo.Node 1.0

Canvas {
    id: node

    width: 50
    height: 50

    signal forget(Node g)
    signal showCard(Node g)

    property Component dynamicMenuItem: null
    property NeoRoom room: NeoRoom {
    }
    property alias name: backend.name
    property alias backend: backend

    property Item inSlot: NeoRadioButton {
        y: node.height / 2 - 4
        x: backend.type === Node.OrGate ? 4 : -2
        visible: false
        parent: node
    }

    property Item outSlot: NeoRadioButton {
        y: node.height / 2 - 4
        x: node.width - 6
        visible: false
        parent: node
    }

    Component.onCompleted: {
        dynamicMenuItem = Qt.createComponent("NeoMenuItem.qml")
    }

    Node {
        id: backend
        type: Node.AndGate
        onConnectionsHaveChanged: {
            outSlot.visible = room.backend.hasOutConnection(backend)
            inSlot.visible = room.backend.hasInConnection(backend)
        }
        inPos: Qt.point(node.x + inSlot.x, node.y + inSlot.y + 4)
        outPos: Qt.point(node.x + outSlot.x + 7, node.y + outSlot.y + 4)
    }

    Canvas {
        width: 10
        height: 10
        x: node.width / 2
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
        ctx.fillStyle = backend.type === Node.OrGate ? 'purple' : 'orange'

        switch (backend.type) {
        case Node.AndGate:
            drawAndGate(ctx)
            break
        case Node.OrGate:
            drawOrGate(ctx)
            break
        }
    }

    function drawOrGate(ctx) {
        ctx.beginPath()
        ctx.arc(-width + 14 / 100 * width, height / 2, height,
                -Math.PI, Math.PI)
        ctx.moveTo(0, 1)
        ctx.lineTo(width / 2, 1)
        ctx.lineTo(width - 1, height / 2)
        ctx.lineTo(width / 2, height - 1)
        ctx.lineTo(0, height - 1)
        ctx.fill()
    }

    function drawAndGate(ctx) {
        ctx.beginPath()
        ctx.arc(width / 2, height / 2, height / 2 - 2, -Math.PI / 2,
                Math.PI / 2)
        ctx.moveTo(width / 2, 2)
        ctx.lineTo(2, 2)
        ctx.lineTo(2, height - 2)
        ctx.lineTo(width / 2, height - 2)
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
            title: qsTr("Send To")

            Menu {
                id: menuSendGate
                title: qsTr("Gates")
                onAboutToShow: {
                    menuSendGate.clear()
                    makeGateList(menuSendGate, Node.OrGate, Node.Output)
                    makeGateList(menuSendGate, Node.AndGate, Node.Output)
                }
            }

            Menu {
                id: menuSendNode
                title: qsTr("Nodes")
                onAboutToShow: {
                    menuSendNode.clear()
                    makeNodeList(menuSendNode, Node.Output, Node.Output)
                }
            }
        }

        Menu {
            title: qsTr("Read from")

            Menu {
                id: menuReadGate
                title: qsTr("Gates")
                onAboutToShow: {
                    menuReadGate.clear()
                    makeGateList(menuReadGate, Node.OrGate)
                    makeGateList(menuReadGate, Node.AndGate)
                }
            }

            Menu {
                id: menuReadNode
                title: qsTr("Nodes")
                onAboutToShow: {
                    menuReadNode.clear()
                    makeNodeList(menuReadNode, Node.Input)
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

    function makeGateList(menu, type, way) {
        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (nodes[i] !== backend && nodes[i].type === type) {
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(menu)
                    mnuItem.text = nodes[i].name
                    mnuItem.checkable = true
                    mnuItem.checked = room.backend.connected(backend,
                                                             nodes[i], way)

                    menu.insertItem(0, mnuItem)

                    mnuItem.toggled.connect(function (checked) {
                        if (checked) {
                            room.backend.createConnection(backend,
                                                          nodes[i], way)
                        } else {
                            room.backend.removeAllConnections(backend,
                                                              nodes[i], way)
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

    function makeNodeList(menu, type, way) {

        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (nodes[i].type === type) {
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(menu)
                    mnuItem.text = nodes[i].name
                    mnuItem.checkable = true
                    mnuItem.checked = room.backend.connected(backend, nodes[i], way)

                    menu.insertItem(0, mnuItem)

                    mnuItem.toggled.connect(function (checked) {
                        if (checked) {
                            room.backend.createConnection(backend, nodes[i], way)
                        } else {
                            room.backend.removeAllConnections(backend, nodes[i], way)
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
