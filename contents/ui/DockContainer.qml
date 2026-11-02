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
    width: implicitWidth
    height: implicitHeight

    // macOS Frosted Glass Surface
    Rectangle {
        id: glassBackground
        anchors.fill: parent
        radius: root.cornerRadius

        color: {
            if (root.themeStyle === 1) {
                // Frosted Silver Light
                return Qt.rgba(0.95, 0.95, 0.97, 0.65);
            } else if (root.themeStyle === 2) {
                // Deep Graphite Dark
                return Qt.rgba(0.14, 0.15, 0.18, 0.68);
            } else {
                // Adaptive to Plasma theme
                var isDark = Kirigami.Theme.textColor.hslLightness > 0.5;
                return isDark ? Qt.rgba(0.16, 0.17, 0.20, 0.70) : Qt.rgba(0.95, 0.95, 0.97, 0.68);
            }
        }

        // macOS Specular Glass Inner Border Bevel
        border.color: {
            var isDark = (root.themeStyle === 2) || (root.themeStyle === 0 && Kirigami.Theme.textColor.hslLightness > 0.5);
            return isDark ? Qt.rgba(1.0, 1.0, 1.0, 0.20) : Qt.rgba(1.0, 1.0, 1.0, 0.55);
        }
        border.width: 1

        // Top specular highlight reflection line
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1.2
            radius: root.cornerRadius - 1
            color: Qt.rgba(1.0, 1.0, 1.0, 0.35)
        }
    }
}
