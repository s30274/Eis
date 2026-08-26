import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire 
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components.misc
import qs.modules.wifimenu

PanelWindow {
	id: root

	// System data
	property int cpuTemp: 0
	property int gpuTemp: 0
	property int cpuUsage: 0
	property real memUsed: 0
	property real memTotal: 0
	property bool audioMuted: Pipewire.defaultAudioSink.audio.muted
	property real audioVolume: Math.floor(Pipewire.defaultAudioSink.audio.volume * 100)
	property bool batteryPlugged: !UPower.onBattery
	property int batteryPercent: Math.floor(UPower.displayDevice.percentage * 100)
	property int brightness: 0
	property int brightnessStep: 5
	property var lastCpuIdle: 0
	property var lastCpuTotal: 0

	// Pipewire (audio) stuff
	PwObjectTracker {
		objects: [Pipewire.defaultAudioSink]
	}

	// Brightness stuff
	
	CustomShortcut {
		name: "brightnessUp"
		description: "increase brightness"
		onPressed: increaseBrightnessProc.running = true
	}

	CustomShortcut {
		name: "brightnessDown"
		description: "decrease brightness"
		onPressed: { if (brightness > 0) decreaseBrightnessProc.running = true }
	}

	Process {
		id: increaseBrightnessProc
		command: ["brightnessctl", "-e3", "-n2", "set", `${brightnessStep}%+`]
		stdout: StdioCollector {
			onStreamFinished: brightnessProc.running = true
		}
	}

	Process {
		id: decreaseBrightnessProc
		command: ["brightnessctl", "-e3", "-n2", "set", `${brightnessStep}%-`]
		stdout: StdioCollector {
			onStreamFinished: brightnessProc.running = true
		}
	}

	Process {
		id: brightnessProc
		running: true
		command: ["sh", "-c", "brightnessctl", "i"]
		stdout: StdioCollector {
			onStreamFinished: {
				brightness = parseInt(text.match(/[0-9][0-9]+%/))
			}
		}
	}

	// Processes

	Process {
		id: tempProc
		command: ["sh", "-c", "sensors"]
		stdout: StdioCollector {
            onStreamFinished: {
                let cpuTemp = text.match(/(?:Package id [0-9]+|Tdie):\s+((\+|-)[0-9.]+)(°| )C/);
                if (!cpuTemp)
                    // If AMD Tdie pattern failed, try fallback on Tctl
                    cpuTemp = text.match(/Tctl:\s+((\+|-)[0-9.]+)(°| )C/);

                if (cpuTemp)
                    root.cpuTemp = parseFloat(cpuTemp[1]);

                if (root.gpuType !== "GENERIC")
                    return;

                let eligible = false;
                let sum = 0;
                let count = 0;

                for (const line of text.trim().split("\n")) {
                    if (line === "Adapter: PCI adapter")
                        eligible = true;
                    else if (line === "")
                        eligible = false;
                    else if (eligible) {
                        let match = line.match(/^(temp[0-9]+|GPU core|edge)+:\s+\+([0-9]+\.[0-9]+)(°| )C/);
                        if (!match)
                            // Fall back to junction/mem if GPU doesn't have edge temp (for AMD GPUs)
                            match = line.match(/^(junction|mem)+:\s+\+([0-9]+\.[0-9]+)(°| )C/);

                        if (match) {
                            sum += parseFloat(match[2]);
                            count++;
                        }
                    }
                }

                root.gpuTemp = count > 0 ? sum / count : 0;
            }
        }
	}

	Process {
		id: cpuProc
		command: ["sh", "-c", "head -1 /proc/stat"]

		stdout: SplitParser {
			onRead: data => {
				var p = data.trim().split(/\s+/)
				var idle = parseInt(p[4]) + parseInt(p[5])
				var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
				if(lastCpuTotal > 0) {
					cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
				}
				lastCpuTotal = total
				lastCpuIdle = idle
			}
		}
		Component.onCompleted: running = true
	}

	Process {
		id: memProc
		command: ["sh", "-c", "free | grep Mem"]
		stdout: SplitParser {
			onRead: data => {
				var parts = data.trim().split(/\s+/)
				memTotal = (parseInt(parts[1]) || 1) / 1000000
				memUsed = (parseInt(parts[2]) || 0) / 1000000
				//memUsage = Math.round(100 * used / total)
			}
		}
		Component.onCompleted: running = true
	}

	Process {
		id: logout
		command: ["sh", "-c", "wlogout"]
	}

	// Timer
	Timer {
		interval: 2000
		running: true
		repeat: true
		onTriggered: {
			tempProc.running = true
			cpuProc.running = true
			memProc.running = true
		}
	}

	// ---=== MAIN ===---
	
  	anchors {
    	top: true
    	left: true
    	right: true
  	}
	color: Colors.transparent
  	implicitHeight: Appearance.barHeight + Appearance.topMargin

	mask: Region { Region { item: leftIsland } Region { item: tasks } }

	RowLayout {
		anchors.fill: parent
		anchors.topMargin: Appearance.topMargin
		anchors.leftMargin: Appearance.sideMargin
		anchors.rightMargin: Appearance.sideMargin

		Rectangle {
			id: leftIsland
			color: Colors.bg
			antialiasing: true
			radius: Appearance.barHeight
			Layout.preferredWidth: leftIslandContent.width
			Layout.preferredHeight: Appearance.barHeight
			Layout.alignment: Qt.AlignLeft

			RowLayout {
				id: leftIslandContent
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				spacing: (Appearance.fontSize / 2)

				Rectangle {
					color: Colors.black
					antialiasing: true
					radius: Appearance.barHeight
					Layout.preferredWidth: workspaces.width + Appearance.fontSize
					Layout.preferredHeight: Appearance.barHeight

					RowLayout {
						id: workspaces
						anchors.verticalCenter: parent.verticalCenter
						anchors.horizontalCenter: parent.horizontalCenter
						uniformCellSizes: true
						spacing: Appearance.fontSize / 2

						Repeater {
							model: Appearance.workspaceAmount
							Text {
								property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
								property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

								text: isActive ? "" : (ws ? "" : "")
								color: ws ? Colors.cyan : Colors.muted
								font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }

								// Click to switch workspaces
								MouseArea {
									anchors.fill: parent
									onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${(index + 1)}})`)
								}
							}
						}
					}
				}

				Rectangle {
					id: profileIndicator
					width: Appearance.fontSize
					Layout.alignment: Qt.AlignVCenter
					readonly property int profile: PowerProfiles.profile
					readonly property int highestProfile: PowerProfiles.hasPerformanceProfile ? 3 : 2

					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: profileIndicator.profile == 0 ? "󱙷" : (profileIndicator.profile == 1 ? "󰤇" : "")
						color: profileIndicator.profile == 0 ? Colors.green : (profileIndicator.profile == 1 ? Colors.cyan : Colors.red)
						font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
						MouseArea {
							anchors.fill: parent
							onClicked: {
								PowerProfiles.profile = (profileIndicator.profile + 1) % profileIndicator.highestProfile
							}
						}
					}
				}

				Text {
					text: "  " + cpuUsage + "%"
					color: Colors.cyan
					font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
					Layout.leftMargin: (Appearance.fontSize / 6)
					Layout.rightMargin: (Appearance.fontSize / 2)
				}

				Text {
					text: "  " + memUsed.toFixed(1) + "G/" + memTotal.toFixed(1) + "G"
					color: Colors.green
					font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
					Layout.rightMargin: Appearance.fontSize
				}
			}
		}

		// This is dumb part 1
		Item {
			property int difference: rightIsland.width - leftIsland.width
			Layout.preferredWidth: difference > 0 ? difference : 0
		}

		Rectangle {
			id: centerIsland
			color: Colors.bg
			antialiasing: true
			radius: Appearance.barHeight
			Layout.preferredWidth: clock.width + (2 * Appearance.fontSize)
			Layout.preferredHeight: Appearance.barHeight
			Layout.alignment: Qt.AlignHCenter

			Text {
				id: clock
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
				color: Colors.blue
				font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
				Timer {
					interval: 1000
					running: true
					repeat: true
					onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
				}
			}
		}

		// This is dumb part 2
		Item {
			property int difference: leftIsland.width - rightIsland.width
			Layout.preferredWidth: difference > 0 ? difference : 0
		}

		Rectangle {
			id: rightIsland
			color: Colors.bg
			antialiasing: true
			radius: Appearance.barHeight
			Layout.preferredWidth: tasks.width + (2 * Appearance.fontSize)
			Layout.preferredHeight: Appearance.barHeight
			Layout.alignment: Qt.AlignRight

			RowLayout {
				id: tasks
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				spacing: Appearance.fontSize

				Text {
					text: (audioMuted ? " " : " ") + (audioVolume < 10 ? " " : "") + audioVolume + "%"
					color: audioMuted ? Colors.blue : Colors.yellow
					font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
				}

				Text {
					function getTemperatureIcon(temp: int): string {
						return (temp < 50 ? " " : (temp > 90 ? " " : " "))
					}

					text: getTemperatureIcon(0) + cpuTemp + "°"
					color: cpuTemp < 90 ? Colors.green : Colors.red
					font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
				}

				Text {
					function getBatteryIcon(percent: int, isPlugged: bool): string {
						if(isPlugged)
							return "󰂄 "
						if(percent > 97)
							return "󰁹 "
						switch(Math.floor(percent/10)) {
							case 0:
								return "󰂃 "
							case 1:
								return "󰂃 "
							case 2:
								return "󰁻 "
							case 3:
								return "󰁼 "
							case 4:
								return "󰁽 "
							case 5:
								return "󰁾 "
							case 6:
								return "󰁿 "
							case 7:
								return "󰂀 "
							case 8:
								return "󰂁 "
							case 9:
								return "󰂂 "
						}
					}

					text: getBatteryIcon(batteryPercent, batteryPlugged) + batteryPercent + "%"
					color: batteryPlugged ? Colors.green : (batteryPercent < 20 ? Colors.red : Colors.cyan)
					font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
				}

				Text {
					text: (brightness <= 25 ? "󰃞 " : (brightness <= 70 ? "󰃟 " : "󰃠 ")) + brightness + "%"
					color: Colors.green
					font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
				}

				Rectangle {
					id: wifiIcon
					width: Appearance.fontSize
					height: Appearance.fontSize
					color: Colors.white
					WifiMenu {
						id: wifiMenu
						anchor.window: root
						anchor.rect.y: root.height
					}
					MouseArea {
						anchors.fill: parent
						onClicked: {
							if (!wifiMenu.visible) {
								wifiMenu.anchor.rect.x = wifiIcon.mapToGlobal((wifiIcon.width / 2) - (wifiMenu.width / 2), 0).x
								wifiMenu.toggle()
							} else {
								wifiMenu.toggle()
							}
						}
					}
				}
				
				RowLayout {
					spacing: Appearance.fontSize / 2
					Repeater { 
						id: tray
						model: SystemTray.items
						IconImage {
							implicitSize: Appearance.barHeight * 0.7
							property SystemTrayItem item: SystemTray.items.values[index]
							source: item.icon
							MouseArea {
								acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
								anchors.fill: parent
								onClicked: event => {
									if (item.hasMenu && event.button === Qt.RightButton)
										item.display(root, root.width - event.x, Appearance.barHeight + Appearance.topMargin)
									else {
										event.button === Qt.LeftButton ? item.activate() : item.secondaryActivate();
									}
								}
							}
						}
					}
				}

				Text {
					text: ""
					color: Colors.blue
					font { family: Appearance.fontFamily; pixelSize: Appearance.fontSize; bold: true }
					MouseArea {
						anchors.fill: parent
						onClicked: logout.running = true
					}
				}
			}
		}
	}
}
