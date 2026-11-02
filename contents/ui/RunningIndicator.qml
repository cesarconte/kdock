import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    property bool isRunning: false
    property bool isFocused: false

    width: 14
    height: 6

    Rectangle {
        id: dot
        anchors.centerIn: parent
        width: root.isFocused ? 10 : 4.5
        height: 4.5
        radius: height / 2

        color: {
            if (Kirigami.Theme.colorSet === Kirigami.Theme.Window && Kirigami.Theme.textColor.hslLightness < 0.5) {
                // Light mode: dark graphite dot with subtle translucency
                return root.isFocused ? Qt.rgba(0.1, 0.1, 0.1, 0.9) : Qt.rgba(0.2, 0.2, 0.2, 0.65);
            } else {
                // Dark mode / translucent: crisp white glowing dot
                return root.isFocused ? Qt.rgba(1.0, 1.0, 1.0, 0.95) : Qt.rgba(1.0, 1.0, 1.0, 0.75);
            }
        }

        opacity: root.isRunning ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        Behavior on width {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }
}
