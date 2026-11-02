import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string text: ""
    property bool visibleTooltip: false
    property real targetX: 0
    property real targetY: 0

    visible: opacity > 0.01
    opacity: visibleTooltip ? 1.0 : 0.0
    x: targetX - width / 2
    y: targetY - height - 10

    Behavior on opacity {
        NumberAnimation { duration: 140; easing.type: Easing.OutQuad }
    }

    Behavior on x {
        NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
    }

    Behavior on y {
        NumberAnimation { duration: 120; easing.type: Easing.OutBack }
    }

    implicitWidth: label.implicitWidth + 24
    implicitHeight: label.implicitHeight + 10

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(0.08, 0.09, 0.11, 0.85)

        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.18)
        border.width: 1

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            color: "#FFFFFF"
            font.pixelSize: 12
            font.weight: Font.Medium
            renderType: Text.NativeRendering
        }
    }
}
