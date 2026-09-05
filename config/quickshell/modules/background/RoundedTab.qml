import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Rectangle {
	id: root

	property int tabRadius: 15

	topLeftRadius: tabRadius
	topRightRadius: tabRadius
}

/*
Control {
    id: root

	property int tabWidth: 300
	property int tabHeight: 100
	property int tabRadius: 15
	property color tabColor: "white"

    width: tabWidth
    height: tabHeight

    Canvas {
        anchors.fill: parent
        
        // Enhances rendering quality to ensure the rounded edges remain smooth
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            
            var w = root.width;
            var h = root.height;
            var r = root.tabRadius;
            var flangeWidth = root.tabRadius;

            ctx.fillStyle = root.tabColor;
            ctx.beginPath();

            ctx.moveTo(0, h);
            ctx.arcTo(flangeWidth, h, flangeWidth, h - r, r);
            ctx.lineTo(flangeWidth, r);
            ctx.arcTo(flangeWidth, 0, flangeWidth + r, 0, r);
            ctx.lineTo(w - flangeWidth - r, 0);
            ctx.arcTo(w - flangeWidth, 0, w - flangeWidth, r, r);
            ctx.lineTo(w - flangeWidth, h - r);
            ctx.arcTo(w - flangeWidth, h, w, h, r);
            ctx.lineTo(0, h);

            ctx.closePath();
            ctx.fill();
        }
    }
}
*/
