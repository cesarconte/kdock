import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    property real baseHeight: 40

    width: 14
    height: baseHeight

    Rectangle {
        id: line
        anchors.centerIn: parent
        width: 1.2
        height: parent.height * 0.72
        radius: 0.6

        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop {
                position: 0.2
                color: Kirigami.Theme.textColor.hslLightness < 0.5
                       ? Qt.rgba(0.0, 0.0, 0.0, 0.15)
                       : Qt.rgba(1.0, 1.0, 1.0, 0.22)
            }
            GradientStop {
                position: 0.8
                color: Kirigami.Theme.textColor.hslLightness < 0.5
                       ? Qt.rgba(0.0, 0.0, 0.0, 0.15)
                       : Qt.rgba(1.0, 1.0, 1.0, 0.22)
            }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // Specular highlight line right next to it (macOS glass bevel)
    Rectangle {
        anchors.left: line.right
        anchors.verticalCenter: line.verticalCenter
        width: 0.8
        height: line.height
        radius: 0.4

        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop {
                position: 0.3
                color: Qt.rgba(1.0, 1.0, 1.0, 0.18)
            }
            GradientStop {
                position: 0.7
                color: Qt.rgba(1.0, 1.0, 1.0, 0.18)
            }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
}
