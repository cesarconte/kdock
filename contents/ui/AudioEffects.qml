import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

QtObject {
    id: root

    property bool soundEnabled: true

    property var _execSource: Plasma5Support.DataSource {
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
        }
    }

    function playTrashSound() {
        if (!soundEnabled) return;
        _execSource.connectSource("canberra-gtk-play -i trash-empty --description='Trash Emptied' 2>/dev/null || pw-play /usr/share/sounds/freedesktop/stereo/trash-empty.oga 2>/dev/null &");
    }

    function playLaunchSound() {
        if (!soundEnabled) return;
        _execSource.connectSource("canberra-gtk-play -i button-pressed --description='Dock Launch' 2>/dev/null &");
    }

    function playStackOpenSound() {
        if (!soundEnabled) return;
        _execSource.connectSource("canberra-gtk-play -i dialog-information --description='Stack Opened' 2>/dev/null &");
    }
}
