//@ pragma UseQApplication

import Quickshell
import QtQuick

import "modules/background"
import "modules/topbar"
import "modules/notifications"
import "modules/screenshot" as Screenshot

ShellRoot {
	Background {}
	Topbar {}
	Notifications {}
	WallpaperBrowser {}

	Component.onCompleted: () => {
		Screenshot.Controller.init();		
	}
}
