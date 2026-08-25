import QtQuick.Layouts
import QtQuick

RowLayout {
	id: root
	property int size: 150
	property real value: 0
	property color color: "cyan"
	property color background: "grey"
	property int maxValue: 90
	width: size
	height: size
    
	onValueChanged: requestPaint()
	
	Canvas {
        id: c

        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");

            var x = root.width / 2;
            var y = root.height / 2;
			var r = root.size * 2 / 5

			var startAngle = (Math.PI / 180) * 150;
            var progressAngle = (Math.PI / 180) * (value / 100 * 240 + 150);
			var fullAngle = (Math.PI / 180) * 30;

            ctx.reset();
			ctx.lineWidth = size / 8;
			ctx.lineCap = "round";

			ctx.beginPath();
			ctx.arc(x, y, r, startAngle, fullAngle, false);
			ctx.strokeStyle = root.background;
			ctx.stroke();

            ctx.beginPath();
			ctx.arc(x, y, r, startAngle, progressAngle, false);
            ctx.strokeStyle = root.color;
			ctx.stroke();
        }
	}
}
