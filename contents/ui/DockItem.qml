import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var tasksModelRef: null
    property int modelIndexVal: -1
    property real baseSize: 48
    property real currentScale: 1.0

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

    // Smooth horizontal expansion: when magnified, item widens to push neighbors aside smoothly
    width: Math.round(baseSize * (1.0 + (currentScale - 1.0) * 0.70))
    height: baseSize
    implicitWidth: width
    implicitHeight: height
    clip: false

    Behavior on currentScale {
        NumberAnimation {
            duration: 80
            easing.type: Easing.OutQuad
        }
    }

    function modelIndex() {
        if (!tasksModelRef || modelIndexVal < 0) {
            return null;
        }
        return tasksModelRef.makeModelIndex(modelIndexVal);
    }

    function publishGeometry() {
        if (!isRunning || !tasksModelRef || !root.window) {
            return;
        }

        var p = root.mapToGlobal(0, 0);
        var rect = Qt.rect(p.x, p.y, root.width, root.height);
        var idx = modelIndex();

        if (idx && idx.valid) {
            tasksModelRef.requestPublishDelegateGeometry(idx, rect, root);
        }
    }

    onXChanged: publishGeometry()
    onYChanged: publishGeometry()
    onWidthChanged: publishGeometry()
    onHeightChanged: publishGeometry()
    onIsRunningChanged: {
        if (isRunning) {
            geometryTimer.restart();
        }
    }

    Timer {
        id: geometryTimer
        interval: 200
        running: root.isRunning
        repeat: false
        onTriggered: root.publishGeometry()
    }

    BounceAnimator {
        id: bounceAnimator
        maxBounceHeight: Math.min(20, root.baseSize * 0.38)
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

    // Shadow projected below during bounce
    Rectangle {
        id: bounceShadow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        width: parent.width * 0.65 * bounceAnimator.shadowScale
        height: 3
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.35 * bounceAnimator.shadowOpacity)
        visible: bounceAnimator.active
    }

    // Magnified scaling wrapper originating from bottom
    Item {
        id: scalingWrapper
        anchors.fill: parent
        clip: false

        transform: Scale {
            origin.x: scalingWrapper.width / 2
            origin.y: scalingWrapper.height - 6
            xScale: root.currentScale
            yScale: root.currentScale
        }

        Item {
            id: iconWrapper
            anchors.fill: parent
            y: bounceAnimator.currentYOffset
            clip: false

            Kirigami.Icon {
                id: mainIcon
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -3
                width: root.baseSize * 0.72
                height: root.baseSize * 0.72
                source: root.iconSource
                smooth: true
                opacity: root.isMinimized ? 0.75 : 1.0

                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
            }

            // Notification Badge (macOS red circle/pill with white text)
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
                color: "#FF3B30"
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

    // macOS glowing dot/pill indicator at dock baseline
    RunningIndicator {
        id: runningIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        isRunning: root.isRunning
        isFocused: root.isFocused
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: false
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (!root.isRunning) {
                    bounceAnimator.startBounce(true);
                    root.launchTriggered();
                } else {
                    root.publishGeometry();
                    root.activated();
                }
            } else if (mouse.button === Qt.RightButton) {
                var pos = mouseArea.mapToGlobal(mouse.x, mouse.y);
                root.contextRequested(pos.x, pos.y);
            }
        }
    }
}
