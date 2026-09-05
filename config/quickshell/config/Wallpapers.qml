pragma Singleton

import Quickshell
import QtCore

Singleton {
	readonly property string path: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/Pictures/Wallpapers"
}
