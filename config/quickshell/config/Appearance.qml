pragma Singleton

import Quickshell

Singleton {
	id: root

	// Font
	readonly property string fontFamily: "JetBrainsMono Nerd Font"
	readonly property int fontSize: 16

	// Size
	readonly property int barHeight: 30
	readonly property int radius: (barHeight / 2)
	readonly property int topMargin: 6
	readonly property int sideMargin: 15

	// Settings
	readonly property int workspaceAmount: 5
}
