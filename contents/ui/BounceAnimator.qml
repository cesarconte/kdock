import QtQuick

Item {
    id: root

    property bool active: false
    property bool continuous: false // Loops endlessly (demanding attention or startup)
    property int maxBounces: 3
    property real maxBounceHeight: 20
    property real currentYOffset: 0
    property real shadowOpacity: Math.max(0.2, 1.0 - (-currentYOffset / Math.max(1, maxBounceHeight)))
    property real shadowScale: Math.max(0.5, 1.0 - (-currentYOffset / Math.max(1, maxBounceHeight * 1.5)))

    signal finished()

    function startBounce(isContinuous) {
        continuous = isContinuous;
        active = true;
        bounceAnim.restart();
    }

    function stopBounce() {
        bounceAnim.stop();
        currentYOffset = 0;
        active = false;
        finished();
    }

    SequentialAnimation {
        id: bounceAnim
        running: false
        loops: root.continuous ? Animation.Infinite : root.maxBounces

        NumberAnimation {
            target: root
            property: "currentYOffset"
            from: 0
            to: -root.maxBounceHeight
            duration: 220
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: root
            property: "currentYOffset"
            from: -root.maxBounceHeight
            to: 0
            duration: 200
            easing.type: Easing.InQuad
        }

        onFinished: {
            root.currentYOffset = 0;
            root.active = false;
            root.finished();
        }
    }
}
