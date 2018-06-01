import QtQuick 2.10
import QtQuick.Controls 2.3
import Neo.Node 1.0

Rectangle {
    id: node

    width: 100
    height: 100
    radius: height
    color: "#566c73"
    border.width: 5
    border.color: backend.output ? "green" : "red"

    signal forget(Node g)
    signal showCard(Node g)
    signal forgetAll

    property Component dynamicMenuItem: null
    property NeoRoom room: NeoRoom {
    }
    property alias name: backend.name
    property alias backend: backend

    property Item inSlot: NeoSlot {
        y: node.height / 2
        x: -4
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
        type: Node.Output
        onConnectionsHaveChanged: {
            inSlot.visible = room.backend.hasInConnection(backend)
            room.backend.evaluate(backend)
        }
        inPos: Qt.point(node.x + inSlot.x, node.y + inSlot.y + 4)
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

    MouseArea {
        id: drag_area
        anchors.fill: parent
        drag.target: node
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property int mouseButtonClicked: Qt.NoButton

        // show context menu on leftclick pressed over the gate
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
            title: qsTr("Connect To")

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
