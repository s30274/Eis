import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

import qs.config

Variants {
	id: root
	model: Quickshell.screens

	PanelWindow {
		id: monitor
		screen: root.modelData
		anchors { top: true; right: true; bottom: true; left: true }


		WlrLayershell.layer: WlrLayer.Background
		WlrLayershell.exclusiveZone: -1 

		IpcHandler {
			target: "wallpaper"
			function set(path: string): void { PersistentConfig.wallpaperPath = path; }
		}

		Image {
			id: wallpaper
			anchors.fill: parent
			sourceSize.width: monitor.screen.width
			sourceSize.height: monitor.screen.height
			horizontalAlignment: Image.AlignLeft
    		verticalAlignment: Image.AlignTop
			source: PersistentConfig.wallpaperPath
			fillMode: Image.PreserveAspectCrop
		}
	}
}
