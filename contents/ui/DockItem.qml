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
    property bool isMinimized: false
    property bool isStartup: false
    property bool demandsAttention: false
    property int badgeNumber: 0

    signal activated()
    signal contextRequested(real globalX, real globalY)
    signal launchTriggered()
    signal geometryChangedCallback()

    width: baseSize
    height: baseSize

    onXChanged: geometryChangedCallback()
    onYChanged: geometryChangedCallback()
    onWidthChanged: geometryChangedCallback()
    onHeightChanged: geometryChangedCallback()
    Component.onCompleted: geometryChangedCallback()

    BounceAnimator {
        id: bounceAnimator
        maxBounceHeight: root.baseSize * 0.45
        continuous: root.demandsAttention || root.isStartup
    }

    onDemandsAttentionChanged: {
        if (demandsAttention) {
            bounceAnimator.startBounce(true);
        } else if (bounceAnimator.active && !root.isStartup) {
            bounceAnimator.stopBounce();
        }
    }

    onIsStartupChanged: {
        if (isStartup) {
            bounceAnimator.startBounce(true);
        } else if (bounceAnimator.active && !root.demandsAttention) {
            bounceAnimator.stopBounce();
        }
    }

    // Absorption pulse animation when window is minimized into the dock
    SequentialAnimation {
        id: absorbAnim
        running: false

        NumberAnimation {
            target: scalingWrapper
            property: "absorbScale"
            from: 1.0
            to: 1.12
            duration: 150
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: scalingWrapper
            property: "absorbScale"
            from: 1.12
            to: 1.0
            duration: 220
            easing.type: Easing.OutBack
        }
    }

    onIsMinimizedChanged: {
        if (isMinimized) {
            absorbAnim.restart();
        }
    }

    // Shadow projected below during bounce
    Rectangle {
        id: bounceShadow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        width: parent.width * 0.65 * bounceAnimator.shadowScale
        height: 3.5
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.45 * bounceAnimator.shadowOpacity)
        visible: bounceAnimator.active
    }

    // Only the icon and badge scale up on magnification, originating from the bottom
    Item {
        id: scalingWrapper
        anchors.fill: parent
        property real absorbScale: 1.0

        transform: Scale {
            origin.x: scalingWrapper.width / 2
            origin.y: scalingWrapper.height - 4
            xScale: root.currentScale * scalingWrapper.absorbScale
            yScale: root.currentScale * scalingWrapper.absorbScale
        }

        Item {
            id: iconWrapper
            anchors.fill: parent
            y: bounceAnimator.currentYOffset

            Kirigami.Icon {
                id: mainIcon
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 2
                width: root.baseSize * 0.82
                height: root.baseSize * 0.82
                source: root.iconSource
                smooth: true
                opacity: root.isMinimized ? 0.78 : 1.0

                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
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
    }

    // macOS Running Indicator dot (unscaled, anchored stably at dock baseline)
    RunningIndicator {
        id: runningIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
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
            drop.acceptProposedAction();
        }
    }
}
