import QtQuick 2.0
import QtQuick.Controls 2.3
//import QtQuick.Controls.Styles 1.4
import Neo.Node 1.0
import Neo.Room 1.0

Item {
    id: popup
    focus: true
    visible: false

    //    width: 100
    //    height: 100
    //    Component.onCompleted: {
    //        visible = false
    //    }
    property Node currentNode: dummyNode
    Node {
        id: dummyNode
    }

    property Room currentRoom: dummyRoom
    Room {
        id: dummyRoom
    }

    Column {
        anchors.fill: parent
        Text {
            id: nameTag
            width: popup.width
            height: popup.height / 10
            color: "blue"
            text: currentNode.name
            font.bold: true
            font.pointSize: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
            }
        }

        Rectangle {
            id: mainArea
            width: popup.width
            height: popup.height / 10 * 4
            color: "lightblue"
            Row {
                anchors.fill: parent
                Text {
                    id: data
                    height: parent.height
                    width: parent.width / 2
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 20
                    text: String(currentNode.value)
                    color: "black"
                    font.bold: true
                }

                NeoOverrideButton {
                    id: overrideButton
                    width: parent.width / 2
                    height: parent.height
                }
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
            }
        }

        Rectangle {
            id: comRect
            width: popup.width
            height: popup.height / 10 * 2

            Column {
                anchors.fill: parent
                NeoComboBox {
                    id: inCom
                    width: parent.width
                    height: popup.height / 10
                    model: currentRoom.nodes
                    name: "Incoming connections"
                    delegate: CheckBox {
                        tristate: true
                        checkState: {
                            if (currentNode === modelData) {
                                return Qt.PartiallyChecked
                            } else if (currentRoom.connected(currentNode,
                                                             modelData,
                                                             Node.In)) {
                                return Qt.Checked
                            } else {
                                return Qt.Unchecked
                            }
                        }
                        text: modelData.value
                        enabled: false
                    }
                }

                NeoComboBox {
                    id: outCom
                    width: parent.width
                    height: popup.height / 10
                    model: currentRoom.nodes
                    name: "Outgoing Connections"
                    delegate: CheckBox {
                        tristate: true
                        checkState: {
                            if (currentNode === modelData) {
                                return Qt.PartiallyChecked
                            } else if (currentRoom.connected(currentNode,
                                                             modelData,
                                                             Node.Out)) {
                                return Qt.Checked
                            } else {
                                return Qt.Unchecked
                            }
                        }
                        text: modelData.value
                        enabled: false
                    }
                }
            }
        }

        Rectangle {
            width: popup.width
            height: popup.height / 10 * 3
            color: "green"
        }
    }

    function showCard(node, room) {
        currentNode = node
        currentRoom = room
        visible = true
    }

    function hideCard() {
        currentNode = dummyNode
        currentRoom = dummyRoom
        visible = false
    }
}
