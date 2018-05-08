import QtQuick 2.2
import QtQuick.Controls 1.4
import Neo.Node 1.0

Item {
    id: node
    width: 100
    height: 50

    signal forget(Node n)
    signal showCard(Node n)

    property Component dynamicMenuItem: null //! Component used to create menu items on demand

    // finish initialization
    Component.onCompleted: {
        dynamicMenuItem = Qt.createComponent("NeoMenuItem.qml")
        room.backend.evaluate(backend)
        status.requestPaint()
    }
    property NeoRoom room: NeoRoom {
    }

    property color color: "lightblue"
    property real indicatorHPart: 1 / 10
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
        outPos: Qt.point(node.x + outSlot.x + 7, node.y + outSlot.y + 4)
    }

    Column {
        anchors.fill: parent
        Rectangle {
            width: node.width
            height: node.height / 5
            color: {
                if (textField.focus) {
                    return "green"
                } else if (backend.type === Node.Input) {
                    return "blue"
                } else {
                    return "red"
                }
            }

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

            TextField {
                id: textField
                anchors.fill: parent
                opacity: 0
                anchors.centerIn: parent
                text: backend.name
                onTextChanged: backend.name = text
                onEditingFinished: {
                    focus = false
                }
            }
        }

        Rectangle {
            id: dataArea
            width: node.width
            height: node.height / 5 * 4
            color: node.color
            Text {
                anchors.fill: parent
                id: dataText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 20
                text: backend.value
                color: "black"
                font.bold: true
            }

            Canvas {
                width: 10
                height: 10
                x: node.width / 2 - 5
                y: node.height / 2
                id: status
                onPaint: {
                    var ctx = getContext("2d")

                    ctx.fillStyle = backend.output ? "green" : "red"
                    ctx.beginPath()
                    ctx.arc(width / 2, height / 2, width / 2, 0, 2 * Math.PI)
                    ctx.fill()
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

            if (nodes[i].type === type) {
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

    function makeNodeList(menu) {

        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (nodes[i] !== node.backend && nodes[i].type === Node.Output) {
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
