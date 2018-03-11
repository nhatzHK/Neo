import QtQuick 2.0

Rectangle {
    id: node_edit
    x: 0
    y: 0
    anchors.fill: parent
    property var nodes: []

    Canvas {
        id: canvas
        anchors.fill: parent
        function do_spline(node1, node2, context) {
            var x1 = node1.x -10
            var x2 = node2.x - 13
            var y1 = node1.y + node2.height / 4
            var y2 = node2.y + node2.height / 4
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
            console.log("Painting")
            var ctx = canvas.getContext("2d")
            ctx.clearRect(0, 0, canvas.width, canvas.height)
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1)
            ctx.lineWidth = 1
            ctx.beginPath()
            //do_spline(Qt.point(40, 40), Qt.point(80, 80), ctx)
            console.log("Nodes: " + nodes.length)
            for (var i = 0; i < nodes.length; ++i) {
                console.log("Reached")
                console.log("Connections: " + nodes[i].connections.length)
                for (var j = 0; j < nodes[i].connections.length; ++j) {
                    do_spline(nodes[i], nodes[i].connections[j], ctx)
                    console.log("Reached 2")
                }
            }

            ctx.stroke()
        }
    }

    property Canvas baseCanvas: canvas
}
