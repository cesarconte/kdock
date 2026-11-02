import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: root

    property real baseSize: 56
    property real currentScale: 1.0
    property string folderPath: "Downloads"
    property string folderName: i18n("Downloads")
    property string folderIcon: "folder-download"
    property var filesList: []

    signal stackOpened()

    width: baseSize
    height: baseSize

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height
        xScale: root.currentScale
        yScale: root.currentScale
    }

    Plasma5Support.DataSource {
        id: fileLister
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            if (data["exit code"] === 0) {
                var lines = (data["stdout"] || "").split("\n");
                var items = [];
                for (var i = 0; i < lines.length; i++) {
                    var l = lines[i].trim();
                    if (l.length > 0) {
                        items.push({
                            name: l,
                            path: "~/" + root.folderPath + "/" + l
                        });
                    }
                }
                root.filesList = items;
            }
            disconnectSource(sourceName);
        }
    }

    function refreshFiles() {
        fileLister.connectSource("ls -1t ~/" + root.folderPath + " 2>/dev/null | head -n 12");
    }

    Component.onCompleted: {
        refreshFiles();
    }

    Plasma5Support.DataSource {
        id: launcherSource
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
        }
    }

    function openFolder() {
        launcherSource.connectSource("dolphin ~/" + root.folderPath + " &");
    }

    function openFile(path) {
        launcherSource.connectSource("xdg-open '" + path.replace(/'/g, "'\\''") + "' &");
    }

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
                    launcherSource.connectSource("cp -r '" + filePath.replace(/'/g, "'\\''") + "' ~/" + root.folderPath + "/ 2>/dev/null");
                }
                refreshFiles();
                drop.acceptProposedAction();
            }
        }
    }

    Kirigami.Icon {
        id: iconDisplay
        anchors.centerIn: parent
        width: parent.width * 0.85
        height: parent.height * 0.85
        source: root.folderIcon
        smooth: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                refreshFiles();
                stackPopup.open();
                root.stackOpened();
            } else if (mouse.button === Qt.RightButton) {
                contextMenu.popup();
            }
        }
    }

    QQC2.Menu {
        id: contextMenu

        QQC2.MenuItem {
            text: i18n("Open in Dolphin")
            icon.name: "system-file-manager"
            onTriggered: root.openFolder()
        }

        QQC2.MenuItem {
            text: i18n("Refresh Stack")
            icon.name: "view-refresh"
            onTriggered: root.refreshFiles()
        }
    }

    // macOS Style Grid Stack Pop-up
    QQC2.Popup {
        id: stackPopup
        y: -implicitHeight - 16
        x: (root.width - implicitWidth) / 2
        padding: 14

        background: Rectangle {
            radius: 16
            color: Qt.rgba(0.12, 0.13, 0.16, 0.88)
            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.2)
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.folderName
                    color: "#FFFFFF"
                    font.weight: Font.DemiBold
                    font.pixelSize: 13
                }
                Item { Layout.fillWidth: true }
                Kirigami.Icon {
                    source: "system-file-manager"
                    width: 16
                    height: 16
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.openFolder();
                            stackPopup.close();
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
            }

            GridLayout {
                columns: 3
                rowSpacing: 10
                columnSpacing: 12

                Repeater {
                    model: root.filesList

                    delegate: Item {
                        width: 72
                        height: 76

                        Rectangle {
                            id: itemHoverBg
                            anchors.fill: parent
                            radius: 8
                            color: itemMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.12) : "transparent"
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 2

                            Kirigami.Icon {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                source: "unknown"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: "#EEEEEE"
                                font.pixelSize: 10
                                elide: Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.openFile(modelData.path);
                                stackPopup.close();
                            }
                        }
                    }
                }
            }
        }
    }
}
