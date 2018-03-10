import QtQuick 2.0

Rectangle {
    id: node_edit
    x: 0
    y: 0
    anchors.fill: parent
    property ListModel nodes: ListModel{}

    Canvas {
        id: canvas
        anchors.fill: parent
        function do_spline(node1, node2, context) {
            x1 += 9
            x2 += 9
            y1 += 15
            y2 += 15
            context.moveTo(x1, y1)
            if (x1 > x2) {
                context.bezierCurveTo((x1 - x2) + x1, y1, x2 - (x1 - x2),
                                      y2, x2, y2)
            } else {
                context.bezierCurveTo((x1 + x2) / 2, y1, (x1 + x2) / 2,
                                      y2, x2, y2)
            }
        }
        onPaint: {
            var ctx = canvas.getContext("2d")
            ctx.clearRect(0, 0, canvas.width, canvas.height)
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1)
            ctx.lineWidth = 1
            ctx.beginPath()
            ctx.stroke()
        }
    }

    property Canvas baseCanvas: canvas
}
