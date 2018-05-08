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
            height: popup.height / 10 * 4

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

                    MouseArea {
                        anchors.fill: parent
                    }
                }

                Column {
                    height: parent.height / 2
                    width: parent.width / 2
                    RangeSlider {
                        id: control
                        height: parent.height / 2
                        width: parent.width
                        from: 0
                        to: 100

                        first.value: 0
                        second.value: 100

                        first.handle: Rectangle {
                            x: control.leftPadding + control.first.visualPosition
                               * (control.availableWidth - width)
                            y: control.topPadding + control.availableHeight / 2 - height / 2
                            width: control.height
                            height: control.height
                            radius: height / 2
                            color: control.first.pressed ? "#f0f0f0" : "#f6f6f6"
                            border.color: "#bdbebf"

                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: String(control.first.value).substring(0,
                                                                            5)
                            }
                        }

                        second.handle: Rectangle {
                            x: control.leftPadding + control.second.visualPosition
                               * (control.availableWidth - width)
                            y: control.topPadding + control.availableHeight / 2 - height / 2
                            //                            implicitWidth: 26
                            //                            implicitHeight: 26
                            width: control.height
                            height: control.height
                            radius: height / 2
                            color: control.second.pressed ? "#f0f0f0" : "#f6f6f6"
                            border.color: "#bdbebf"
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: String(control.second.value).substring(0,
                                                                             5)
                            }
                        }

                        background: Rectangle {
                            x: control.leftPadding
                            y: control.topPadding + control.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 4
                            width: control.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: "red"

                            Rectangle {
                                x: control.first.visualPosition * parent.width
                                width: control.second.visualPosition * parent.width - x
                                height: parent.height
                                color: "green"
                                radius: 2
                            }
                        }

                        function setTo(t) {
                            to = Number(t) === NaN ? to : Number(t)
                            setValues(first.value, second.value)
                        }

                        function setFrom(t) {
                            from = Number(t) === NaN ? from : Number(t)
                            setValues(first.value, second.value)
                        }
                    }

                    //                    Rectangle {
                    //                        width: parent.width
                    //                        height: parent.height / 2
                    //                        color: "red"
                    //                    }
                    Row {
                        width: parent.width
                        height: parent.height / 2

                        NeoLabelField {
                            id: fromLabel
                            height: parent.height
                            width: parent.width / 5
                            displayText: "0"
                            displayColor: "grey"
                            editColor: "lightgrey"
                            onTextChanged: {
                                control.setFrom(displayText)
                            }
                        }

                        Rectangle {
                            height: parent.height
                            width: parent.width / 5 * 3
                            color: "green"
                        }

                        NeoLabelField {
                            id: toLabel
                            width: parent.width / 5
                            height: parent.height
                            displayText: "100"
                            displayColor: "grey"
                            editColor: "lightgrey"
                            onTextChanged: {
                                control.setTo(displayText)
                            }
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
                    id: outCom
                    width: parent.width
                    height: popup.height / 10
                    model: currentRoom.nodes
                    name: "Outgoing Connections"
                    delegate: CheckBox {
                        checkState: {
                            if (currentNode === modelData) {
                                enabled = false
                            }

                            if (currentRoom.connected(currentNode, modelData,
                                                      Node.Output)) {
                                return Qt.Checked
                            } else {
                                return Qt.Unchecked
                            }
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
                    name: "Component List"
                    ButtonGroup {
                        buttons: componentList.delegate
                        exclusive: true
                    }

                    delegate: RadioButton {
                        checked: currentNode.rowId === modelData

                        onCheckedChanged: {
                            if (checked) {
                                currentNode.rowId = modelData
                            }
                        }

                        text: modelData
                    }
                }
            }
        }

        Rectangle {
            width: popup.width
            height: popup.height / 10 * 3
            color: "green"

            MouseArea {
                anchors.fill: parent
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
}
