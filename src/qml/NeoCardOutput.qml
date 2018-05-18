import QtQuick 2.0
import QtQuick.Controls 2.3
import Neo.Room 1.0
import Neo.Node 1.0

Item {
    id: popup
    focus: true
    visible: false

    property Node currentNode: dummyNode
    Node {
        id: dummyNode
    }

    property Room currentRoom: dummyRoom
    Room {
        id: dummyRoom
    }

    onCurrentNodeChanged: {
        openedSwitch.checked = currentNode.opened
        invertedSwitch.checked = currentNode.inverted

        openedSwitch.updateHandlePosition()
        invertedSwitch.updateHandlePosition()
    }


    Column {
        anchors.fill: parent
        Rectangle {
            width: popup.width
            height: popup.height / 10
            color: currentNode.output ? "green" : "red"
            Text {
                id: nameTag
                anchors.fill: parent
                color: "white"
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
        }

        Rectangle {
            id: mainArea
            width: popup.width
            height: popup.height / 10 * 7

            Row {
                anchors.fill: parent
                Column {
                    height: parent.height
                    width: parent.width / 2
                    Label {
                        width: parent.width
                        height: parent.height / 4
                        text: qsTr("Method")
                        font.pointSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        background: Rectangle {
                            color: "orange"
                        }
                    }

                    TextField {
                        id: methodInput
                        width: parent.width
                        height: parent.height / 4
                        placeholderText: qsTr("Enter message to send here")
                        text: currentNode.method
                        onEditingFinished: currentNode.method = text
                    }

                    Label {
                        id: argsLabel
                        width: parent.width
                        height: parent.height / 4
                        text: qsTr("Args")
                        font.pointSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        background: Rectangle {
                            color: "orange"
                        }
                    }

                    TextField {
                        id: argsInput
                        width: parent.width
                        height: parent.height / 4
                        placeholderText: qsTr("Enter arguments here here")
                        text: currentNode.args
                        onEditingFinished: currentNode.args = text
                    }
                }

                Column {
                    height: parent.height
                    width: parent.width / 2
                    Rectangle {
                        width: parent.width
                        height: parent.height / 4 * 2
                        NeoOverrideButton {
                            id: overrideButton
                            height: parent.height > parent.width ? parent.width : parent.height
                            anchors.centerIn: parent

                            onClicked: {
                                override()
                            }
                        }
                    }

                    NeoSwitch {
                        id: invertedSwitch
                        width: parent.width
                        height: parent.height / 4
                        enabledText: "Inverted"
                        disabledText: "Normal"
                        enabledColor: "#26a69a"
                        onClicked: {
                            currentNode.inverted = checked
                            currentNode.connectionsHaveChanged()
                        }
                    }

                    NeoSwitch {
                        id: openedSwitch
                        width: parent.width
                        height: parent.height / 4
                        enabledText: "On"
                        disabledText: "Off"
                        enabledColor: "#26a69a"
                        onClicked: {
                            currentNode.opened = checked
                            currentNode.connectionsHaveChanged()
                        }
                    }
                }
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
                    name: "Connections"
                    delegate: CheckBox {
                        checkState: {
                            if (currentNode === modelData
                                    || modelData.type === Node.Output) {
                                enabled = false
                            }

                            if (currentRoom.connected(currentNode, modelData,
                                                      Node.Output)) {
                                return Qt.Checked
                            } else {
                                return Qt.Unchecked
                            }
                        }

                        onClicked: {
                            if (checked) {
                                currentRoom.createConnection(currentNode,
                                                             modelData,
                                                             Node.Output)
                            } else {
                                currentRoom.removeConnections(currentNode,
                                                              modelData,
                                                              Node.Output)
                            }

                            currentNode.connectionsHaveChanged()
                            modelData.connectionsHaveChanged()
                            currentRoom.paint()
                        }

                        text: modelData.name
                        font.bold: true
                        font.pointSize: 14
                    }
                }

                NeoComboBox {
                    id: componentList
                    width: parent.width
                    height: popup.height / 10
                    model: currentRoom.ids
                    name: "Components"
                    ButtonGroup {
                        buttons: componentList.delegate
                        exclusive: true
                    }

                    delegate: RadioButton {
                        checked: currentNode.rowId === modelData
                        onCheckedChanged: {
                            if (checked) {
                                currentNode.rowId = modelData
                                componentList.name = modelData
                            }
                        }

                        text: modelData
                    }
                }
            }
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

    function override() {
        currentNode.conditionOverriden()
    }
}
