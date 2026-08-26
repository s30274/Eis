import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

import qs.config

Scope {
	id: root

	NotificationServer {
		id: server

		actionsSupported: true
		bodySupported: true
		imageSupported: true

		onNotification: n => n.tracked = true
	}

	PanelWindow {
		anchors { top: true; right: true }
		margins { top: 12 + Appearance.barHeight; right: 12 }
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
					border.color: modelData.urgency === NotificationUrgency.Critical ? Colors.red : Colors.blue

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
								font.pixelSize: Appearance.fontSize - 2
								font.bold: true
								wrapMode: Text.WordWrap
							}
						}
					}

					MouseArea {
						anchors.fill: parent
						onClicked: card.modelData.dismiss()
					}
				}
			}
		}
	}
}
