import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.config

PopupWindow {
	id: root

	implicitWidth: menu.width + Appearance.fontSize
	implicitHeight: menu.height
	color: Colors.transparent
	visible: false
	
	default property alias content: background.data
	//property bool focusGrab: true

	function toggle():void {
		if (!root.visible) {
			openAnim.start()
			grab.active = true
		} else {
			closeAnim.start()
			grab.active = false
		}
	}

	HyprlandFocusGrab {
		id: grab
		windows: [ root ]
		onCleared: {
			root.toggle()
		}
	}

	Rectangle {
		id: background
		implicitWidth: root.implicitWidth
		implicitHeight: menu.height
		bottomLeftRadius: Appearance.radius
		bottomRightRadius: Appearance.radius
		color: Colors.bg

		NumberAnimation on y {
			id: openAnim
			running: false
			from: -background.implicitHeight
			to: 0
			duration: 200
			onStarted: root.visible = true
		}
		NumberAnimation on y {
			id: closeAnim
			running: false
			from: 0
			to: -background.implicitHeight
			duration: 200
			onFinished: root.visible = true
		}
	}
}
