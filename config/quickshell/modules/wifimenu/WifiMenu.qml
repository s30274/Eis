import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

SlideMenu {
	id: root
	property WifiDevice wifiDevice: getWifiDevice()
	property bool scanNetwork: root.visible
	property int menuWidth: 250

	function getWifiDevice():WifiDevice {
		return Networking.devices.values.filter((device) => device.type == 1).shift()
	}

	onScanNetworkChanged: {
		if(scanNetwork){
			scannerEnabled: true
		} else {
			scannerEnabled: false
		}
	}

	ColumnLayout {
		id: menu
		anchors.horizontalCenter: parent.horizontalCenter
		Text {
			Layout.leftMargin: Appearance.fontSize / 2
			Layout.topMargin: Appearance.topMargin
			text: "Wi-fi networks:"
			color: Colors.white
			font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
		}

		Repeater {
			model: wifiDevice.networks.values
			required property Network modelData

			Rectangle {
				id: wifiEntryHighlight
				width: root.menuWidth
				height: wifiEntry.height
				radius: Appearance.radius
				color: Colors.transparent

				MouseArea {
					anchors.fill: parent
					hoverEnabled: true
					onEntered: wifiEntryHighlight.color = Colors.muted
					onExited: wifiEntryHighlight.color = Colors.transparent
					onClicked: {
						if (!modelData.connected)
							modelData.connect()
					}
				}

				RowLayout {
					id: wifiEntry
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: Appearance.fontSize
					Text {
						id: wifiEntryName
						Layout.alignment: Qt.AlignLeft
						Layout.leftMargin: Appearance.fontSize
						function getWifiIcon(signalStrength: real): string {
							if (signalStrength <= 0.25)
								return "󰤟"
							else if (signalStrength <= 0.5)
								return "󰤢"
							else if (signalStrength <= 0.75)
									return "󰤥"
							return "󰤨"
						}

						text: getWifiIcon(modelData.signalStrength) + " " + (modelData.name.length <= 18 ? modelData.name : (modelData.name.substring(0, 15) + "..."))
						color: Colors.white
						font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: false }
					}

					Text {
						Layout.alignment: Qt.AlignRight
						Layout.rightMargin: Appearance.fontSize
						text: modelData.connected ? "" : (NetworkState.toString(modelData.state) === "Connecting" ? "o" : " ")
						color: Colors.white
						font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: false }
					}
				}
			}
		}
	
		Rectangle {
			id: disconnectButtonHighlight
			Layout.bottomMargin: Appearance.topMargin
			width: root.menuWidth
			height: disconnectButton.height
			radius: Appearance.radius
			color: Colors.transparent

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered: disconnectButtonHighlight.color = Colors.muted
				onExited: disconnectButtonHighlight.color = Colors.transparent
				onClicked: {
					if(wifiDevice.connected)
						wifiDevice.disconnect()
				}
			}

			Text {
				anchors.left: parent.left
				anchors.leftMargin: Appearance.fontSize / 2
				id: disconnectButton
				text: "Disconnect"
				color: Colors.white
				font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: false }
			}
		}
	}
}
