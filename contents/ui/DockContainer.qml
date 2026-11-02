import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    property int themeStyle: 0 // 0: Adaptive, 1: Light, 2: Dark
    property real contentWidth: 400
    property real contentHeight: 68
    property real cornerRadius: 20

    implicitWidth: contentWidth + 24
    implicitHeight: contentHeight

    // macOS Frosted Glass Background
    Rectangle {
        id: glassBackground
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        radius: root.cornerRadius

        color: {
            if (root.themeStyle === 1) {
                // Frosted Silver Light
                return Qt.rgba(0.92, 0.93, 0.96, 0.55);
            } else if (root.themeStyle === 2) {
                // Deep Graphite Dark
                return Qt.rgba(0.12, 0.13, 0.16, 0.62);
            } else {
                // Adaptive to Plasma theme
                var isDark = Kirigami.Theme.textColor.hslLightness > 0.5;
                return isDark ? Qt.rgba(0.14, 0.15, 0.18, 0.64) : Qt.rgba(0.94, 0.95, 0.97, 0.58);
            }
        }

        // macOS Specular Glass Inner Border Bevel
        border.color: {
            var isDark = (root.themeStyle === 2) || (root.themeStyle === 0 && Kirigami.Theme.textColor.hslLightness > 0.5);
            return isDark ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : Qt.rgba(1.0, 1.0, 1.0, 0.45);
        }
        border.width: 1

        // Top subtle highlight reflection line
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1.2
            radius: root.cornerRadius - 1
            color: Qt.rgba(1.0, 1.0, 1.0, 0.28)
        }

        // Ambient contact shadow below dock
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -1
            anchors.topMargin: 2
            radius: root.cornerRadius + 1
            color: Qt.rgba(0.0, 0.0, 0.0, 0.22)
        }
    }
}
