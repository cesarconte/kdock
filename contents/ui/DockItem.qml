import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: root

    property var taskModelData: null
    property real baseSize: 56
    property real currentScale: 1.0
    property bool isHovered: false

    property string appName: ""
    property var iconSource: null
    property var launcherUrl: ""
    property bool isRunning: false
    property bool isFocused: false
    property bool demandsAttention: false
    property int badgeNumber: 0

    signal activated()
    signal contextRequested(real globalX, real globalY)
    signal launchTriggered()

    width: baseSize
    height: baseSize

    // Scale from bottom center so icons grow upward on magnification
    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height - 4
        xScale: root.currentScale
        yScale: root.currentScale
    }

    BounceAnimator {
        id: bounceAnimator
        maxBounceHeight: root.baseSize * 0.45
        continuous: root.demandsAttention
    }

    onDemandsAttentionChanged: {
        if (demandsAttention) {
            bounceAnimator.startBounce(true);
        } else if (bounceAnimator.active && bounceAnimator.continuous) {
            bounceAnimator.stopBounce();
        }
    }

    // Shadow projected below during bounce
    Rectangle {
        id: bounceShadow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        width: parent.width * 0.65 * bounceAnimator.shadowScale
        height: 4
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.45 * bounceAnimator.shadowOpacity)
        visible: bounceAnimator.active
    }

    Item {
        id: iconWrapper
        anchors.fill: parent
        y: bounceAnimator.currentYOffset

        Kirigami.Icon {
            id: mainIcon
            anchors.centerIn: parent
            width: root.baseSize * 0.84
            height: root.baseSize * 0.84
            source: root.iconSource
            smooth: true
        }

        // Notification Badge (macOS red circle/pill with white number)
        Rectangle {
            id: badgeRect
            visible: root.badgeNumber > 0
            anchors.top: mainIcon.top
            anchors.right: mainIcon.right
            anchors.topMargin: -4
            anchors.rightMargin: -4
            width: Math.max(18, badgeText.implicitWidth + 8)
            height: 18
            radius: 9
            color: "#FF3B30" // macOS System Red
            border.color: "#FFFFFF"
            border.width: 1.5

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: root.badgeNumber > 99 ? "99+" : root.badgeNumber.toString()
                color: "#FFFFFF"
                font.pixelSize: 10
                font.weight: Font.Bold
                renderType: Text.NativeRendering
            }
        }
    }

    RunningIndicator {
        id: runningIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        isRunning: root.isRunning
        isFocused: root.isFocused
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (!root.isRunning) {
                    bounceAnimator.startBounce(false);
                    root.launchTriggered();
                } else {
                    root.activated();
                }
            } else if (mouse.button === Qt.RightButton) {
                var pos = mouseArea.mapToGlobal(mouse.x, mouse.y);
                root.contextRequested(pos.x, pos.y);
            }
        }
    }

    DropArea {
        id: dropTarget
        anchors.fill: parent
        onEntered: function(drag) {
            if (drag.hasUrls) {
                drag.acceptProposedAction();
            }
        }
        onDropped: function(drop) {
            // Forward drop to app
            drop.acceptProposedAction();
        }
    }
}
