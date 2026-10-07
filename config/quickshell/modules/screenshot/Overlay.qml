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
		screen: modelData
		anchors { top: true; right: true; bottom: true; left: true; }

		exclusionMode: ExclusionMode.Ignore
		
		color: Colors.transparent
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		//WlrLayershell.namespace: "shell:screenshot"

		visible: screencopy.hasContent

		property var modelData
		property var top: 0
		property var right: 0
		property var bottom: 0
		property var left: 0
		property var initialX: 0
		property var initialY: 0

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
				cmd.command = ["sh", "-c", `grim -g "${x},${y} ${w}x${h}" "$HOME/Pictures/Screenshots/Screenshot-$(date '+%Y-%m-%d_%H_%M_%S').png" | wl-copy`]
				cmd.running = true
			}
		}

		Canvas {
			id: canvas
			anchors.fill: parent

			readonly property int borderExtendX: 2
			readonly property int borderExtendY: 2
			readonly property int borderWidthH: 3
			readonly property int borderWidthV: 3

			onPaint: {
				var ctx = getContext("2d")
				ctx.reset()

				// Background
				ctx.fillStyle = "#66000000"
				ctx.fillRect(0, 0, monitor.width, monitor.height)

				if (monitor.right - monitor.left > 0 || monitor.bottom - monitor.top < 0)
				{
					// Border
					ctx.fillStyle = Colors.blue
					ctx.fillRect(monitor.left - borderExtendX, monitor.top - borderWidthH, monitor.right - monitor.left + borderExtendX * 2, borderWidthH);
					ctx.fillRect(monitor.left - borderExtendX, monitor.bottom, monitor.right - monitor.left + borderExtendX * 2, borderWidthH);
					ctx.fillRect(monitor.left - borderWidthV, monitor.top - borderExtendY, borderWidthV, monitor.bottom - monitor.top + borderExtendY * 2);
					ctx.fillRect(monitor.right, monitor.top - borderExtendY, borderWidthV, monitor.bottom - monitor.top + borderExtendY * 2);

					// Rect
					ctx.clearRect(monitor.left, monitor.top, monitor.right - monitor.left, monitor.bottom - monitor.top)
				}

			}

			MouseArea {
				anchors.fill: parent

				onPressed: e => {
					monitor.top = e.y;
					monitor.right = e.x;
					monitor.bottom = e.y;
					monitor.left = e.x;
					monitor.initialX = e.x;
					monitor.initialY = e.y;
				}
				onPositionChanged: e => {
					if (e.x > monitor.initialX) {
						monitor.left = monitor.initialX
						monitor.right = e.x
					}
					if (e.x < monitor.initialX) {
						monitor.right = monitor.initialX
						monitor.left = e.x
					}
					if (e.y > monitor.initialY) {
						monitor.top = monitor.initialY
						monitor.bottom = e.y;
					}
					if (e.y < monitor.initialY) {
						monitor.bottom = monitor.initialY
						monitor.top = e.y;
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
