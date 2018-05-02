import QtQuick 2.0
import Neo.Room 1.0


/*! \file Main canvas of the node editor
    Draw lines between connected nodes.
*/
Canvas {
    id: canvas
    anchors.fill: parent
    property Room room: Room{
    }

    /*! \brief Draw bezier curve between two nodes (in -> out)
            \param pos1 Qt.point giving the position of the first slot (out)
            \param pos2 Qt.point giving the position of the second slot (in)
        */
    function do_spline(pos1, pos2, context) {
        if (pos1 === null || pos2 === null)
            return

        context.moveTo(pos1.x, pos1.y)
        if (pos1.x > pos2.x) {
            context.bezierCurveTo((pos1.x - pos2.x) + pos1.x, pos1.y,
                                  pos2.x - (pos1.x - pos2.x), pos2.y,
                                  pos2.x, pos2.y)
        } else {
            context.bezierCurveTo((pos1.x + pos2.x) / 2, pos1.y,
                                  (pos1.x + pos2.x) / 2, pos2.y, pos2.x, pos2.y)
        }
    }

    //! Draw all connections curves between all connected slots
    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        ctx.strokeStyle = Qt.rgba(0, 0, 0, 1)
        ctx.lineWidth = 1
        ctx.beginPath()

        for (var i = 0; i < room.connections.length; ++i) {
//            console.log(room.connections[i].from + ' ' + room.connections[i].to)
//            console.log(room.connections[i].from.outPos + ' ' + room.connections[i].to.inPos)
//            console.log(room.connections[i].from.type + ' ' + room.connections[i].to.type)
            do_spline(room.connections[i].from.outPos, room.connections[i].to.inPos, ctx)
        }

        ctx.stroke()
    }
}
