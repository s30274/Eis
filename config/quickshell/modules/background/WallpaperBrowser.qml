import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt.labs.folderlistmodel

import qs.config


PanelWindow {
	id: root
	anchors { bottom: true }
	visible: root.browserOpen
	focusable: true

	property bool browserOpen: false
	
	implicitWidth: 1040
	implicitHeight: 215
	color: Colors.transparent

	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.exclusiveZone: -1 

	IpcHandler {
		id: ipcHandler
		target: "wallpaperBrowser"
		function toggle(): void { root.browserOpen = !root.browserOpen; previewRow.selectCurrent(); previewRow.update() }
	}

	HyprlandFocusGrab {
		id: grab
		active: root.browserOpen
		windows: [ root ]
		onCleared: {
			root.browserOpen = false
		}
	}

	FolderListModel {
		id: wallpapersModel
		folder: Wallpapers.path
		nameFilters: [ "*.png", "*.jpg", "*.jpeg", "*.gif" ]
		showHidden: false
		showDirs: false
	}

	RoundedTab {
		id: wallpaperBrowser
		anchors.fill: parent
		color: Colors.bg
		tabRadius: 30

		focus: true
		Keys.onPressed: (event) => {
			switch (event.key) {
				case Qt.Key_Left:
					previewRow.previous()
					event.accepted = true
					break;
				case Qt.Key_Right:
					previewRow.next()
					event.accepted = true
					break;
				case Qt.Key_Return:
					PersistentConfig.wallpaperPath = previewRow.getPreview(0)
					event.accepted = true
					break;
				case Qt.Key_Escape:
					root.browserOpen = false
					event.accepted
					break
			}
		}
		
		Item {
			id: carousel
			width: parent.width
			height: parent.height

			NumberAnimation on x {
				id: openAnim
				running: false
				from: -320 - 20
				to: 0
				duration: 200
				onStarted: {
					selectionRect.hide()	
					previewRow.selectedPreview = previewRow.ring(previewRow.selectedPreview - 1);
				}
				onFinished: selectionRect.show()
			}
			NumberAnimation on x {
				id: closeAnim
				running: false
				from: 0
				to: -320 - 20
				duration: 200
				onStarted: selectionRect.hide()
				onFinished: {
					previewRow.selectedPreview = previewRow.ring(previewRow.selectedPreview + 1);
					carousel.x = 0
					selectionRect.show()
				}
			}

			RowLayout {
				id: previewRow
				anchors.fill: parent
				uniformCellSizes: true
				anchors.margins: 15
				anchors.leftMargin: 20
				spacing: 15

				property int selectedPreview
				property string preview1: ""
				property string preview2: ""
				property string preview3: ""

				function findIndexByFileName(model, targetName) {
					for (let i = 0; i < model.count; i++) {
						let item = model.get(i, "fileName");
						if (item === targetName) {
							return i;
						}
					}
					return 0;
				}

				function selectCurrent(): void {
					var file = PersistentConfig.wallpaperPath.replace(/^.*(\\|\/|\:)/, '');
					selectedPreview = findIndexByFileName(wallpapersModel, file)
				}
				function ring(number: int): int { return (wallpapersModel.rowCount() + number) % wallpapersModel.rowCount() }
				function getPreview(offset: int): string { return Wallpapers.path + "/" + wallpapersModel.get(ring(selectedPreview + offset), "fileName") }
				function previous(): void { openAnim.start(); }
				function next(): void { closeAnim.start(); }


				Preview {
					id: preiview1
					Layout.alignment: Qt.AlignVCenter
					fileName: previewRow.getPreview(-1)
					MouseArea {
						anchors.fill: parent
						onClicked: previewRow.previous()
					}
				}
				Rectangle {
					id: selectionRect
					Layout.alignment: Qt.AlignVCenter
					width: 320 + 6
					height: 180 + 6
					radius: 17
					color: Colors.blue

					function hide(): void { color = Colors.transparent }
					function show(): void { showAnimation.start(); }

					ColorAnimation on color {
						id: showAnimation
						to: Colors.blue	
						duration: 200
					}

					Preview {
						id: middleSelection
						anchors.centerIn: parent
						fileName: previewRow.getPreview(0)
					}

					MouseArea {
						anchors.fill: parent
						onClicked: PersistentConfig.wallpaperPath = previewRow.getPreview(0)
					}
				}
				Preview {
					Layout.alignment: Qt.AlignVCenter
					fileName: previewRow.getPreview(1)
					MouseArea {
						anchors.fill: parent
						onClicked: previewRow.next()
					}
				}
				Preview {
					Layout.alignment: Qt.AlignVCenter
					fileName: previewRow.getPreview(2)
				}
			}
		}
	}
}
