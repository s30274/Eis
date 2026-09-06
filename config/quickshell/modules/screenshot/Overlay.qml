pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

import qs.config

Variants {
	id: root
	model: Quickshell.screens

	required property var controller

	PanelWindow {
		id: monitor
		screen: root.modelData
		anchors { top: true; right: true; bottom: true; left: true; }

		exclusionMode: ExclusionMode.Ignore
		
		color: Colors.transparent
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		WlrLayershell.namespace: "shell:screenshot"

		visible: screencopy.hasContent

		property var top: 0
		property var right: 0
		property var bottom: 0
		property var left: 0

		ScreencopyView {
			id: screencopy
			captureSource: monitor.screen
			anchors.fill: parent
			paintCursor: true
		}

		Process {
			id: cmd
			running: false
			onExited: notifyCmd.running = true
		}
		Process {
			id: notifyCmd
			command: ["notify-send", "\"Screenshot copied\"", "\"The screenshot was copied to your clipboard\""]
			running: false
			onExited: root.controller.isOpen = false
		}

		contentItem {
			focus: true
			Keys.onEscapePressed: root.controller.isOpen = false

			Keys.onReturnPressed: () => {
				const x = Math.ceil(monitor.left)
				const y = Math.ceil(monitor.top)
				const w = Math.floor(monitor.right - monitor.left)
				const h = Math.floor(monitor.bottom - monitor.top)
				cmd.command = ["sh", "-c", `grim -g "${x},${y} ${w}x${h}" - | wl-copy`]
				cmd.running = true
			}
		}

		Canvas {
			id: canvas
			anchors.fill: parent

			readonly property int borderExtendX: 56
			readonly property int borderExtendY: 48
			readonly property int borderWidthH: 12
			readonly property int borderWidthV: 18

			onPaint: {
				var ctx = getContext("2d")
				ctx.reset()

				// Background
				ctx.fillStyle = "#44000000"
				ctx.fillRect(0, 0, monitor.width, monitor.height)

				// Border
				ctx.fillStyle = "$824524"
				ctx.fillRect(monitor.left - borderExtendX, monitor.top - borderWidthH, monitor.right - monitor.left + borderExtendX * 2, borderWidthH);
	            ctx.fillRect(monitor.left - borderExtendX, monitor.bottom, monitor.right - monitor.left + borderExtendX * 2, borderWidthH);
   	    	    ctx.fillRect(monitor.left - borderWidthV, monitor.top - borderExtendY, borderWidthV, monitor.bottom - monitor.top + borderExtendY * 2);
   		        ctx.fillRect(monitor.right, monitor.top - borderExtendY, borderWidthV, monitor.bottom - monitor.top + borderExtendY * 2);

				// Rect
				ctx.clearRect(monitor.left, monitor.top, monitor.right - monitor.left, monitor.bottom - monitor.top)
			}

			MouseArea {
				anchors.fill: parent

				onPressed: e => {
					monitor.top = e.y;
					monitor.right = e.x;
					monitor.bottom = e.y;
					monitor.left = e.x;
				}
				onPositionChanged: e => {
					if (e.x > monitor.left) {
						monitor.right = e.x;
					}
					if (e.y > monitor.top) {
						monitor.bottom = e.y;
					}
				}
			}
		}

		onTopChanged: canvas.requestPaint()
		onRightChanged: canvas.requestPaint()
		onBottomChanged: canvas.requestPaint()
		onLeftChanged: canvas.requestPaint()

		onWidthChanged: () => {
			left = width / 2
			right = width / 2
		}

		onHeightChanged: () => {
			top = height / 2
			bottom = height / 2
		}
	}
}
