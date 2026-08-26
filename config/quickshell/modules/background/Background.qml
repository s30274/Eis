import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.config

PanelWindow {
	id: root
	anchors { top: true; right: true; bottom: true; left: true }

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusiveZone: -1 

	Image {
		anchors.fill: parent
		source: "/home/piotr/Pictures/Wallpapers/cloudfa18c.jpg"
		fillMode: Image.PreserveAspectCrop
	}
}
