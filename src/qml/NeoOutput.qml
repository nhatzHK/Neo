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
        signal rightClick
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
                id: menuConnectNode
                title: qsTr("Nodes")
                onAboutToShow: {
                    menuConnectNode.clear()
                    makeNodeList(menuConnectNode)
                }
            }

            NeoMenu {
                id: menuConnectGate
                title: qsTr("Gates")
                onAboutToShow: {
                    menuConnectGate.clear()
                    makeGateList(menuConnectGate, Node.OrGate)
                    makeGateList(menuConnectGate, Node.AndGate)
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

    function makeGateList(menu, type) {
        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (room.backend.canConnect(backend,
                                        nodes[i]) && nodes[i].type === type) {
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(menu)
                    mnuItem.text = nodes[i].name
                    mnuItem.checkable = true
                    mnuItem.checked = room.backend.connected(backend, nodes[i],
                                                             Node.Output)

                    menu.insertItem(0, mnuItem)

                    mnuItem.toggled.connect(function (checked) {
                        if (checked) {
                            room.backend.createConnection(backend, nodes[i],
                                                          Node.Output)
                        } else {
                            room.backend.removeConnections(backend, nodes[i],
                                                           Node.Output)
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

            if (room.backend.canConnect(backend, nodes[i], Node.Output)
                    && nodes[i].type === Node.Input) {
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(menu)
                    mnuItem.text = nodes[i].name
                    mnuItem.checkable = true
                    mnuItem.checked = room.backend.connected(backend, nodes[i],
                                                             Node.Output)

                    menu.insertItem(0, mnuItem)

                    mnuItem.toggled.connect(function (checked) {
                        if (checked) {
                            room.backend.createConnection(backend, nodes[i],
                                                          Node.Output)
                        } else {
                            room.backend.removeConnections(backend, nodes[i],
                                                           Node.Output)
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

    function setPosition(x, y) {
        node.x = x
        node.y = y
    }
}
