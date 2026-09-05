pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
	id: root

	property string wallpaperPath: ""

	property FileView fileView: FileView {
		path: Quickshell.shellPath("config/config.json")
		watchChanges: true
		blockLoading: true
		onFileChanged: reload()
		onAdapterUpdated: writeAdapter()
		//autoWrite: true

		adapter: JsonAdapter {
			property alias wallpaperPath: root.wallpaperPath
		}
	}
}
