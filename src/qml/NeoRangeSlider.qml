import QtQuick 2.0
import QtQuick.Controls 2.3
import Neo.Node 1.0

Column {
    id: range

    height: parent.height / 2
    width: parent.width / 2

    property Node currentNode: Node {

    }

    onCurrentNodeChanged: {
        control.from = currentNode.min
        control.to = currentNode.max

        control.setValues(currentNode.first, currentNode.second)
    }

    property alias first: control.fv
    property alias second: control.sv

    onFirstChanged: {
        var cf = Number(String(control.first.value).substring(0, 5))

        if(currentNode.first !== cf)
            currentNode.first = cf
    }

    onSecondChanged: {
        var cs = Number(String(control.second.value).substring(0, 5))

        if(currentNode.second !== cs)
            currentNode.second = cs
    }

    RangeSlider {
        id: control
        height: parent.height / 2
        width: parent.width
        from: 0
        to: 100
        first.value: from
        second.value: to

        property real fv: first.value
        property real sv: second.value

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
