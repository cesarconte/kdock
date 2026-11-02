import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: root

    property real baseSize: 56
    property real currentScale: 1.0
    property bool isHovered: false
    property int trashCount: 0
    property bool isTrashFull: trashCount > 0

    signal trashClicked()
    signal trashEmptied()

    width: baseSize
    height: baseSize

    Item {
        id: scalingWrapper
        anchors.fill: parent

        transform: Scale {
            origin.x: scalingWrapper.width / 2
            origin.y: scalingWrapper.height - 4
            xScale: root.currentScale
            yScale: root.currentScale
        }

        Kirigami.Icon {
            id: trashIcon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 2
            width: root.baseSize * 0.82
            height: root.baseSize * 0.82
            source: root.isTrashFull ? "user-trash-full" : "user-trash"
            smooth: true
        }
    }

    Plasma5Support.DataSource {
        id: trashWatcher
        engine: "executable"
        connectedSources: []

        interval: 3000

        onNewData: function(sourceName, data) {
            if (data["exit code"] === 0) {
                var out = (data["stdout"] || "").trim();
                var count = parseInt(out, 10);
                root.trashCount = isNaN(count) ? 0 : count;
            }
            disconnectSource(sourceName);
        }
    }

    Timer {
        id: pollTimer
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            trashWatcher.connectSource("ls -1 ~/.local/share/Trash/files 2>/dev/null | wc -l");
        }
    }

    Plasma5Support.DataSource {
        id: trashCommand
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
            pollTimer.restart();
        }
    }

    function emptyTrash() {
        trashCommand.connectSource("rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/*");
        root.trashCount = 0;
        root.trashEmptied();
    }

    function openTrash() {
        trashCommand.connectSource("dolphin trash:/ &");
    }

    // Drop area to drag files into trash
    DropArea {
        id: dropArea
        anchors.fill: parent

        onEntered: function(drag) {
            if (drag.hasUrls) {
                drag.acceptProposedAction();
            }
        }

        onDropped: function(drop) {
            if (drop.hasUrls) {
                var urls = drop.urls;
                for (var i = 0; i < urls.length; i++) {
                    var filePath = decodeURIComponent(urls[i].toString().replace("file://", ""));
                    trashCommand.connectSource("mv -t ~/.local/share/Trash/files/ '" + filePath.replace(/'/g, "'\\''") + "' 2>/dev/null");
                }
                pollTimer.restart();
                drop.acceptProposedAction();
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.openTrash();
                root.trashClicked();
            } else if (mouse.button === Qt.RightButton) {
                contextMenu.popup();
            }
        }
    }

    QQC2.Menu {
        id: contextMenu

        QQC2.MenuItem {
            text: i18n("Open Trash")
            icon.name: "document-open"
            onTriggered: root.openTrash()
        }

        QQC2.MenuSeparator {}

        QQC2.MenuItem {
            text: i18n("Empty Trash")
            icon.name: "trash-empty"
            enabled: root.isTrashFull
            onTriggered: root.emptyTrash()
        }
    }
}
