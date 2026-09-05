import QtQuick
import QtQuick.Effects

import qs.config

Item {
	id: preview
	implicitWidth: sourceImage.width
	implicitHeight: sourceImage.height

	property string fileName

	Rectangle {
		id: test
		visible: false
		color: Colors.white
		width: 320
		height: 180
	}

	Image {
		id: sourceImage
		visible: false
		sourceSize.width: 320
		sourceSize.height: 180
		source: preview.fileName
		fillMode: Image.PreserveAspectCrop
		sourceClipRect: Qt.rect(0, 0, 320, 180)
	}

	MultiEffect {
		source: sourceImage
		anchors.fill: sourceImage
		maskEnabled: true
		maskSource: maskShape
		maskThresholdMin: 0.5
		maskSpreadAtMin: 1.0
	}

	Rectangle {
		id: maskShape
		width: sourceImage.width
		height: sourceImage.height
		radius: 15
		visible: false
		layer.enabled: true
		layer.smooth: true
	}
}
