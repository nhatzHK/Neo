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
    }

    property NeoRoom room: NeoRoom {
    }

    property color color: "lightblue"
    property real indicatorHPart: 1 / 10
    property alias name: backend.name
    property alias backend: backend
    property Item inSlot: NeoRadioButton {
        y: node.height / 2
        x: -4
        visible: false
        parent: node
    }

    property Item outSlot: NeoRadioButton {
        y: node.height / 2
        x: node.width - 5
        visible: false
        parent: node
    }

    Node {
        id: backend
        way: Node.Out
        onConnectionsMightHaveChanged: {
            outSlot.visible = room.backend.hasOutConnection(backend)
            inSlot.visible = room.backend.hasInConnection(backend)
        }
        inPos: Qt.point(node.x + inSlot.x, node.y + inSlot.y + 4)
        outPos: Qt.point(node.x + outSlot.x + 7, node.y + outSlot.y + 4)
    }

    Column {
        anchors.fill: parent
        Rectangle {
            width: node.width
            height: node.height / 5
            color: textField.focus ? "green" : "blue"
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
            title: qsTr("Connect")
            Menu {
                id: menuConnectOut
                title: qsTr("Send")
                onAboutToShow: {
                    menuConnectOut.clear()
                    updateConnectionList(Node.Out, menuConnectOut)
                }
            }

            Menu {
                id: menuConnectIn
                title: qsTr("Receive")
                onAboutToShow: {
                    menuConnectIn.clear()
                    updateConnectionList(Node.In, menuConnectIn)
                }
            }
        }

        Menu {
            title: qsTr("Functions")
            Menu {
                id: menuFilterIn
                title: qsTr("Filer in")
            }

            Menu {
                id: menuFilterOut
                title: qsTr("Filter out")
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

    function updateConnectionList(type, menu) {
        if (type !== Node.In && type !== Node.Out) {
            return
        }

        function rec_for(nodes, i) {
            if (i >= nodes.length) {
                return
            }

            if (nodes[i] !== node.backend) {
                if (dynamicMenuItem.status === Component.Ready) {
                    var mnuItem = dynamicMenuItem.createObject(menu)
                    mnuItem.text = nodes[i].name
                    mnuItem.checkable = true
                    mnuItem.checked = room.backend.connected(backend,
                                                             nodes[i], type)

                    menu.insertItem(0, mnuItem)

                    mnuItem.toggled.connect(function (checked) {
                        if (checked) {
                            room.backend.createConnection(backend,
                                                          nodes[i], type)
                        } else {
                            room.backend.removeAllConnections(backend,
                                                              nodes[i], type)
                        }
                        backend.connectionsMightHaveChanged()
                        nodes[i].connectionsMightHaveChanged()
                        room.paint()
                    })
                }
            }
            rec_for(nodes, i + 1)
        }
        rec_for(room.backend.nodes, 0)
    }
}
