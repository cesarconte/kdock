import QtQuick

QtObject {
    id: engine

    property bool enabled: true
    property real maxScale: 1.55
    property real radiusFactor: 2.5
    property real mouseX: -1
    property bool isHovered: false

    /**
     * Calculates the parabolic smooth zoom scale factor for an item at itemCenterX
     * using macOS cosine-squared bell curve formula:
     * S(d) = 1 + (maxScale - 1) * cos^2( (pi / 2) * (d / R) ) for d < R
     */
    function calculateScale(itemCenterX, baseWidth) {
        if (!enabled || !isHovered || mouseX < 0) {
            return 1.0;
        }

        var radius = baseWidth * radiusFactor;
        var dist = Math.abs(itemCenterX - mouseX);

        if (dist >= radius) {
            return 1.0;
        }

        var normalized = dist / radius; // 0.0 at center, 1.0 at edge
        var cosVal = Math.cos((Math.PI / 2.0) * normalized);
        var factor = cosVal * cosVal;

        return 1.0 + (maxScale - 1.0) * factor;
    }
}
