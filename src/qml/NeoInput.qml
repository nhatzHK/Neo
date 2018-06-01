import QtQuick 2.10
import QtQuick.Controls 2.3
import Neo.Node 1.0
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

    property Item outSlot: NeoSlot {
        parent: node
        y: node.height / 2 - height / 2
        x: node.width - width / 2
        fillColor: backend.output ? "green" : "red"
        visible: false
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

    onXChanged: {
        room.paint()
    }

    onYChanged: {
        room.paint()
    }

    // ! Context menu
    NeoMenu {
        id: contextMenu
        title: qsTr("Node menu")

        NeoMenu {
            title: qsTr("Connect To")
            NeoMenu {
                id: menuConnectNode
                title: qsTr("Nodes")

                Repeater {
                    id: nodeRepeater

                    NeoMenuItem {
                        text: modelData.name
                        checkable: true
                        checked: room.backend.connected(backend, modelData)
                        onToggled: {
                            console.log("Toggled")
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
                    nodeRepeater.model = makeNodeList()
                }
            }

            NeoMenu {
                id: menuConnectGate
                title: qsTr("Gates")
                Repeater {
                    id: gateRepeater

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
                    gateRepeater.model = makeGateList()
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

    function makeGateList() {
        function rec_for(nodes, i, l) {
            if (i >= nodes.length) {
                return
            }

            if (room.backend.canConnect(backend, nodes[i])
                    && (nodes[i].type === Node.AndGate
                        || nodes[i].type === Node.OrGate)) {
                l.push(nodes[i])
            }
            rec_for(nodes, i + 1, l)
        }

        var l = []
        rec_for(room.backend.nodes, 0, l)
        return l
    }

    function makeNodeList() {
        var l = []
        for (var i = 0; i < room.backend.nodes.length; ++i) {
            if (room.backend.canConnect(backend, room.backend.nodes[i])
                    && room.backend.nodes[i].type === Node.Output) {
                l.push(room.backend.nodes[i])
            }
        }
        return l
    }

    function updateBackend(backend) {
        node.backend.change(backend)
    }

    function setPosition(x, y) {
        node.x = x
        node.y = y
    }
}
