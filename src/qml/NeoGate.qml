import QtQuick 2.10
import QtQuick.Controls 2.3
import Neo.Node 1.0

Canvas {
    id: node

    width: 50
    height: 50

    signal forget(Node g)
    signal showCard(Node g)
    signal forgetAll

    property Component dynamicMenuItem: null
    property NeoRoom room: NeoRoom {
    }
    property alias name: backend.name
    property alias backend: backend

    property Item inSlot: NeoSlot {
        y: node.height / 2 - height / 2
        x: backend.type === Node.OrGate ? 4 : -2
        fillColor: backend.output ? "green" : "red"
        visible: false
        parent: node
    }

    property Item outSlot: NeoSlot {
        y: node.height / 2 - 4
        x: node.width - 6
        fillColor: backend.output ? "green" : "red"
        visible: false
        parent: node
    }

    Component.onCompleted: {
        dynamicMenuItem = Qt.createComponent("NeoMenuItem.qml")
        room.backend.evaluate(backend)
    }

    onForgetAll: {
        node.forget(backend)
        node.destroy()
    }

    Node {
        id: backend
        type: Node.AndGate
        onConnectionsHaveChanged: {
            outSlot.visible = room.backend.hasOutConnection(backend)
            inSlot.visible = room.backend.hasInConnection(backend)
            room.backend.evaluate(backend)
            node.requestPaint()
        }
        inPos: Qt.point(node.x + inSlot.x, node.y + inSlot.y + 4)
        outPos: Qt.point(node.x + outSlot.x + 7, node.y + outSlot.y + 4)
        pos: Qt.point(node.x, node.y)
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

        ctx.lineWidth = 2
        ctx.strokeStyle = backend.output ? "green" : "red"
        ctx.fillStyle = "blue"

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
        ctx.stroke()
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
        ctx.stroke()
    }

    MouseArea {
        id: drag_area
        anchors.fill: parent
        drag.target: node
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property int mouseButtonClicked: Qt.NoButton

        onPressed: {
            if (pressedButtons & Qt.LeftButton) {
                mouseButtonClicked = Qt.LeftButton
            } else if (pressedButtons & Qt.RightButton) {
                mouseButtonClicked = Qt.RightButton
            }
        }

        onClicked: {
            if (mouseButtonClicked === Qt.LeftButton) {
                showCard(backend)
            } else if (mouseButtonClicked === Qt.RightButton) {
                contextMenu.popup()
            }
        }
    }

    // ! Context menu
    NeoMenu {
        id: contextMenu
        title: qsTr("Gate menu")

        NeoMenu {
            title: qsTr("Send To")

            NeoMenu {
                id: menuSendGate
                title: qsTr("Gates")

                Repeater {
                    id: sendGateRepeater

                    NeoMenuItem {
                        text: modelData.name
                        checkable: true
                        checked: room.backend.connected(backend, modelData)
                        onToggled: {
                            if (checked) {
                                room.backend.createConnection(backend,
                                                              modelData)
                            } else {
                                room.backend.removeConnections(backend,
                                                               modelData)
                            }

                            backend.connectionsHaveChanged()
                            modelData.connectionsHaveChanged()
                            room.paint()
                            checked = room.backend.connected(backend, modelData)
                        }
                    }
                }

                onAboutToShow: {
                    sendGateRepeater.model = makeGateList()
                }
            }

            NeoMenu {
                id: menuSendNode
                title: qsTr("Nodes")

                Repeater {
                    id: sendNodeRepeater

                    NeoMenuItem {
                        text: modelData.name
                        checkable: true
                        checked: room.backend.connected(backend, modelData)
                        onToggled: {
                            if (checked) {
                                room.backend.createConnection(backend,
                                                              modelData)
                            } else {
                                room.backend.removeConnections(backend,
                                                               modelData)
                            }

                            backend.connectionsHaveChanged()
                            modelData.connectionsHaveChanged()
                            room.paint()
                            checked = room.backend.connected(backend, modelData)
                        }
                    }
                }

                onAboutToShow: {
                    sendNodeRepeater.model = makeNodeList()
                }
            }
        }

        NeoMenu {
            title: qsTr("Read from")

            NeoMenu {
                id: menuReadGate
                title: qsTr("Gates")

                Repeater {
                    id: readGateRepeater
                    NeoMenuItem {
                        text: modelData.name
                        checkable: true
                        checked: room.backend.connected(backend, modelData,
                                                        Node.Output)
                        onToggled: {
                            if (checked) {
                                room.backend.createConnection(backend,
                                                              modelData,
                                                              Node.Output)
                            } else {
                                room.backend.removeConnections(backend,
                                                               modelData,
                                                               Node.Output)
                            }

                            backend.connectionsHaveChanged()
                            modelData.connectionsHaveChanged()
                            room.paint()
                            checked = room.backend.connected(backend,
                                                             modelData,
                                                             Node.Output)
                        }
                    }
                }
                onAboutToShow: {
                    readGateRepeater.model = makeGateList(Node.Output)
                }
            }

            NeoMenu {
                id: menuReadNode
                title: qsTr("Nodes")

                Repeater {
                    id: readNodeRepeater
                    NeoMenuItem {
                        text: modelData.name
                        checkable: true
                        checked: room.backend.connected(backend, modelData,
                                                        Node.Output)
                        onToggled: {
                            if (checked) {
                                room.backend.createConnection(backend,
                                                              modelData,
                                                              Node.Output)
                            } else {
                                room.backend.removeConnections(backend,
                                                               modelData,
                                                               Node.Output)
                            }

                            backend.connectionsHaveChanged()
                            modelData.connectionsHaveChanged()
                            room.paint()
                            checked = room.backend.connected(backend,
                                                             modelData,
                                                             Node.Output)
                        }
                    }
                }

                onAboutToShow: {
                    readNodeRepeater.model = makeNodeList(Node.Output)
                }
            }
        }
        NeoMenuItem {
            text: qsTr("Delete")
            onTriggered: {
                node.forget(backend)
                node.destroy()
            }
        }
    }

    function makeGateList(way) {
        if (way === undefined) {
            way = Node.Input
        }

        var l = []
        for (var i = 0; i < room.backend.nodes.length; ++i) {
            if (room.backend.canConnect(backend, room.backend.nodes[i], way)
                    && (room.backend.nodes[i].type === Node.OrGate
                        || room.backend.nodes[i].type === Node.AndGate)) {
                l.push(room.backend.nodes[i])
            }
        }
        return l
    }

    function makeNodeList(way) {
        if (way === undefined) {
            way = Node.Input
        }

        var type = way === Node.Input ? Node.Output : Node.Input

        var l = []
        for (var i = 0; i < room.backend.nodes.length; ++i) {
            if (room.backend.canConnect(backend, room.backend.nodes[i], way)
                    && room.backend.nodes[i].type === type) {
                l.push(room.backend.nodes[i])
            }
        }
        return l
    }

    function setPosition(x, y) {
        node.x = x
        node.y = y
    }
}
