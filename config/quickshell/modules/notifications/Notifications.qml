import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

import qs.config

Scope {
	id: root

	property bool centerOpen: false
	ListModel { id: history }

	// Notification center IPC
	IpcHandler {
		target: "notifications"
		function toggle() : void { root.centerOpen = !root.centerOpen }
		function show() : void { root.centerOpen = true }
		function hide() : void { root.cetnerOpen = false }
	}

	// Notification server
	NotificationServer {
		id: server

		actionsSupported: true
		bodySupported: true
		imageSupported: true

		onNotification: n => {
			history.insert(0, {
				summary: n.summary,
				body: n.body,
				appName: n.appName,
				urgency: n.urgency,
				time: Qt.formatDateTime(new Date(), "HH:mm"),
			})
			n.tracked = true
		}
	}

	// Notification card
	PanelWindow {
		anchors { top: true; right: true }
		margins { top: 12 + Appearance.barHeight; right: 14 }
		screen: Quickshell.screens[0]
		implicitWidth: 380
		implicitHeight: Math.max(1, column.implicitHeight)
		color: Colors.transparent
		exclusionMode: ExclusionMode.Ignore

		ColumnLayout {
			id: column

			width: parent.width
			spacing: 10
			
			Repeater {
				model: server.trackedNotifications
				delegate: Rectangle {
					id: card

					required property var modelData

					Timer {
						running: card.modelData.urgency !== NotificationUrgency.Critical
						interval: Notifications.timeout
						onTriggered: card.modelData.dismiss()
					}

					Layout.fillWidth: true
					Layout.preferredHeight: layout.implicitHeight + 20
					radius: 8
					color: Colors.bg
					border.width: 2
					border.color: modelData.urgency === NotificationUrgency.Critical ? Colors.red : Colors.muted

					RowLayout {
						id: layout
						anchors.fill: parent
						anchors.margins: 10
						spacing: 10

						Image {
							Layout.preferredWidth: 36
							Layout.preferredHeight: 36
							Layout.alignment: Qt.AlignTop
							fillMode: Image.PreserveAspectFit
							visible: source.toString() !== ""
							source: card.modelData.image || card.modelData.appIcon || ""
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 2

							Text {
								Layout.fillWidth: true
								text: card.modelData.summary
								color: Colors.cyan
								font.family: Appearance.fontFamily
								font.pixelSize: Appearance.fontSize
								font.bold: true
								elide: Text.ElideRight
							}

							Text {
								Layout.fillWidth: true
								visible: text !== ""
								text: card.modelData.body
								color: Colors.blue
								font.family: Appearance.fontFamily
								font.pixelSize: Appearance.fontSize - 1
								font.bold: true
								wrapMode: Text.WordWrap
							}
						}
					}

					MouseArea {
						anchors.fill: parent
						onClicked: card.modelData.dismiss()
					}

					Connections {
						target: root

						function onCenterOpenChanged() {
							card.modelData.dismiss()
						}
					}
				}
			}
		}
	}

	// Notification center
	PanelWindow {
		visible: root.centerOpen
		anchors { top: true; right: true }
		margins { top: 12 + Appearance.barHeight; right: 14 }
		screen: Quickshell.screens[0]
		implicitWidth: 380
		implicitHeight: centerCol.implicitHeight + 24
		color: Colors.transparent
		exclusionMode: ExclusionMode.Ignore

		Rectangle {
			anchors.fill: parent
			radius: 10
			color: Colors.bg

			ColumnLayout {
				id: centerCol

				anchors.fill: parent
				anchors.margins: 12
				spacing: 10

				RowLayout {
					Layout.fillWidth: true

					Text {
						Layout.fillWidth: true						
						text: "Notifications"
						color: Colors.blue
						font.family: Appearance.fontFamily
						font.pixelSize: Appearance.fontSize + 2
						font.bold: true
					}

					Text {
						text: "Clear all"
						visible: history.count > 0
						color: Colors.red
						font.family: Appearance.fontFamily
						font.pixelSize: Appearance.fontSize - 1
						MouseArea {
							anchors.fill: parent
							onClicked: history.clear()
						}
					}
				}

				Text {
					visible: history.count === 0
					text: "No notifications"
					color: Colors.muted
					font.family: Appearance.fontFamily
					font.pixelSize: Appearance.fontSize
					Layout.alignment: Qt.AlignHCenter
					Layout.topMargin: 20
				}

				ListView {
					Layout.fillWidth: true
					Layout.preferredHeight: Math.min(contentHeight, 500)
					clip: true
					spacing: 8
					model: history

					delegate: Rectangle {
						required property int index
						required property var model

						width: ListView.view.width
						implicitHeight: cardCol.implicitHeight + 16
						radius: 8
						color: Colors.bg
						border.width: 1
						border.color: model.urgency === NotificationUrgency.Critical ? Colors.red : Colors.muted

						ColumnLayout {
							id: cardCol

							anchors.fill: parent
							anchors.margins: 8
							spacing: 2

							RowLayout {
								Layout.fillWidth: true
								spacing: 6

								Text {
									Layout.fillWidth: true
									text: model.summary
									color: Colors.blue
									font.family: Appearance.fontFamily
									font.pixelSize: Appearance.fontSize
									font.bold: true
									elide: Text.ElideRight
								}

								Text {
									text: model.time
									color: Colors.muted
									font.family: Appearance.fontFamily
									font.pixelSize: Appearance.fontSize - 3
								}

								Text {
									text: ""
									color: Colors.blue
									font.family: Appearance.fontFamily
									font.pixelSize: Appearance.fontSize - 1
									MouseArea {
										anchors.fill: parent
										onClicked: history.remove(index)
									}
								}
							}

							Text {
								Layout.fillWidth: true
								visible: model.body !== ""
								text: model.body
								color: Colors.blue
								font.family: Appearance.fontFamily
								font.pixelSize: Appearance.fontSize - 1
							}

							Text {
								visible: model.appName !== ""
								text: model.appName
								color: Colors.muted
								font.family: Appearance.fontFamily
								font.pixelSize: Appearance.fontSize - 3
							}
						}
					}
				}
			}
		}
	}
}
