import QtQuick 2.6
import QtQuick.Controls 2.1

CheckBox {
    id: control
    property color color: "red"
    text: qsTr("CheckBox")
    checked: true

    indicator: Rectangle {
        anchors.fill: parent
        color: "#566c73"
        border.width: 1
        border.color: control.down ? color : Qt.lighter(color)

        Canvas {
            anchors.fill: parent
            onPaint: {

                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = control.color
                ctx.strokeStyle = Qt.rgba(0, 0, 0, 1)
                ctx.lineWidth = 2

                ctx.beginPath()
                ctx.moveTo(control.width / 10, control.height / 5)
                ctx.lineTo(control.width / 10, control.height / 5 * 4)
                ctx.lineTo(control.width / 10 * 4, control.height / 5 * 4)
                ctx.lineTo(control.width / 10 * 4, control.height / 5 * 3)
                ctx.lineTo(control.width / 10 * 2, control.height / 5 * 3)
                ctx.lineTo(control.width / 10 * 2, control.height / 5 * 2)
                ctx.lineTo(control.width / 10 * 4, control.height / 5 * 2)
                ctx.lineTo(control.width / 10 * 4, control.height / 5)
                ctx.closePath()

                ctx.moveTo(control.width / 10 * 9, control.height / 5)
                ctx.lineTo(control.width / 10 * 9, control.height / 5 * 4)
                ctx.lineTo(control.width / 10 * 6, control.height / 5 * 4)
                ctx.lineTo(control.width / 10 * 6, control.height / 5 * 3)
                ctx.lineTo(control.width / 10 * 8, control.height / 5 * 3)
                ctx.lineTo(control.width / 10 * 8, control.height / 5 * 2)
                ctx.lineTo(control.width / 10 * 6, control.height / 5 * 2)
                ctx.lineTo(control.width / 10 * 6, control.height / 5)
                ctx.closePath()

                ctx.fill()
                ctx.stroke()
            }
        }

        Rectangle {
            border.width: 2
            radius: 3
            color: control.color
            x: control.width / 10 * 2 - 2
            y: control.height / 5 * 2 - 2
            width: control.width / 10 * 6 + 4
            height: control.height / 5 + 4
            visible: control.checked
        }
    }

    background: Rectangle {
        color: control.color
    }
}
