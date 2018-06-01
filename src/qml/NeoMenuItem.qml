import QtQuick 2.10
import QtQuick.Controls 2.3

MenuItem {
    id: menuItem
    implicitWidth: 20
    implicitHeight: 20
    property color color: "#2979ff"

    arrow: Canvas {
        x: parent.width - width
        implicitWidth: menuItem.width / 6
        implicitHeight: menuItem.height
        visible: menuItem.subMenu
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = menuItem.color
            ctx.strokeStyle = "#ffffff"
            ctx.moveTo(width / 10 * 2, height / 10)
            ctx.lineTo(width / 10 * 9, height / 2)
            ctx.lineTo(width / 10 * 2, height / 10 * 9)
            ctx.closePath()
            ctx.fill()
            ctx.stroke()
        }
    }

    indicator: Item {
        implicitWidth: menuItem.implicitWidth
        implicitHeight: menuItem.implicitHeight
        Rectangle {
            width: parent.width / 7 * 4
            height: parent.height / 7 * 4
            anchors.centerIn: parent
            visible: menuItem.checkable
            border.color: menuItem.color
            border.width: 1
            radius: 3
            Rectangle {
                anchors.fill: parent
                visible: menuItem.checked
                color: menuItem.color
                border.color: "#ffffff"
                border.width: 1
                radius: 2
            }
        }
    }

    contentItem: Text {
        width: parent.width / 6 * 4
        height: parent.height
        leftPadding: menuItem.indicator.width
        rightPadding: menuItem.arrow.width
        text: menuItem.text
        font: menuItem.font
        opacity: enabled ? 1.0 : 0.3
        color: menuItem.highlighted ? "#ffffff" : menuItem.color
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideMiddle
    }

    background: Rectangle {
        implicitWidth: menuItem.width
        implicitHeight: menuItem.height
        opacity: enabled ? 1 : 0.3
        color: menuItem.highlighted ? menuItem.color : "transparent"
    }
}
