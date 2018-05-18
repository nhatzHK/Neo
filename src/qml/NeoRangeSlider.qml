import QtQuick 2.0
import QtQuick.Controls 2.3
import Neo.Node 1.0

Column {
    id: range

    height: 50
    width: 50

    property Node currentNode: Node {
    }

    onCurrentNodeChanged: {
        fromLabel.displayText = currentNode.min
        toLabel.displayText = currentNode.max

        control.setFrom(currentNode.min)
        control.setTo(currentNode.max)

        control.setValues(currentNode.first, currentNode.second)
    }

    RangeSlider {
        id: control
        height: parent.height / 2
        width: parent.width

        first.onValueChanged: {
            currentNode.first = first.value
            second.value = currentNode.second
        }

        second.onValueChanged: {
            currentNode.second = second.value
            first.value = currentNode.first
        }

        onFromChanged: {
            currentNode.min = from
        }

        onToChanged: {
            currentNode.max = to
        }

        first.handle: Rectangle {
            x: control.leftPadding + control.first.visualPosition * (control.availableWidth - width)
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
                text: String(control.first.value).substring(0, 5)
            }
        }

        second.handle: Rectangle {
            x: control.leftPadding + control.second.visualPosition
               * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: control.height
            height: control.height
            radius: height / 2
            color: control.second.pressed ? "#f0f0f0" : "#f6f6f6"
            border.color: "#bdbebf"
            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: String(control.second.value).substring(0, 5)
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
            color: {
                if (currentNode.opened) {
                    return currentNode.inverted ? "green" : "red"
                } else {
                    return "red"
                }
            }

            Rectangle {
                x: control.first.visualPosition * parent.width
                width: control.second.visualPosition * parent.width - x
                height: parent.height
                color: {
                    if (currentNode.opened) {
                        currentNode.inverted ? "red" : "green"
                    } else {
                        return "red"
                    }
                }
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

    Row {
        width: parent.width
        height: parent.height / 2

        NeoLabelField {
            id: fromLabel
            height: parent.height
            width: parent.width / 5
            displayText: currentNode.min
            displayColor: "grey"
            editColor: "lightgrey"
            onTextChanged: {
                control.setFrom(displayText)
            }
        }

        NeoBinderButton {
            height: parent.height
            width: parent.width / 5 * 3
            color: "green"

            Component.onCompleted: {
                checked = currentNode.bound
            }

            onClicked: {
                currentNode.bound = checked

                if (currentNode.bound) {
                    var delta = control.second.value - control.first.value
                    control.first.value += delta / 2
                    control.second.value = control.first.value
                }
            }
        }

        NeoLabelField {
            id: toLabel
            width: parent.width / 5
            height: parent.height
            displayText: currentNode.max
            displayColor: "grey"
            editColor: "lightgrey"
            onTextChanged: {
                control.setTo(displayText)
            }
        }
    }
}
