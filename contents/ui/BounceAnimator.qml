import QtQuick

Item {
    id: root

    property bool active: false
    property bool continuous: false // Loops endlessly (demanding attention or startup)
    property int maxBounces: 3
    property real maxBounceHeight: 20
    property real currentYOffset: 0
    property real shadowOpacity: Math.max(0.2, 1.0 - (-currentYOffset / maxBounceHeight))
    property real shadowScale: Math.max(0.5, 1.0 - (-currentYOffset / (maxBounceHeight * 1.5)))

    signal finished()

    property int bounceIndex: 0

    function startBounce(isContinuous) {
        continuous = isContinuous;
        bounceIndex = 0;
        active = true;
        bounceUp.from = 0;
        bounceUp.to = -maxBounceHeight;
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
        loops: root.continuous ? Animation.Infinite : 1

        SequentialAnimation {
            id: singleCycle

            NumberAnimation {
                id: bounceUp
                target: root
                property: "currentYOffset"
                duration: 220
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                id: bounceDown
                target: root
                property: "currentYOffset"
                from: bounceUp.to
                to: 0
                duration: 200
                easing.type: Easing.InQuad
            }

            ScriptAction {
                script: {
                    if (!root.continuous) {
                        root.bounceIndex++;
                        if (root.bounceIndex >= root.maxBounces) {
                            root.active = false;
                            root.finished();
                        } else {
                            var dampFactor = Math.pow(0.65, root.bounceIndex);
                            bounceUp.to = -root.maxBounceHeight * dampFactor;
                            bounceDown.from = bounceUp.to;
                            bounceAnim.restart();
                        }
                    }
                }
            }
        }
    }
}
