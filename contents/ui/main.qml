import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // Plasma configuration bindings
    readonly property bool enableMagnification: Plasmoid.configuration.enableMagnification !== undefined ? Plasmoid.configuration.enableMagnification : true
    readonly property real magnificationMaxScale: Plasmoid.configuration.magnificationMaxScale || 1.45
    readonly property real magnificationRadiusFactor: Plasmoid.configuration.magnificationRadiusFactor || 2.5
    readonly property bool enableBounce: Plasmoid.configuration.enableBounce !== undefined ? Plasmoid.configuration.enableBounce : true
    readonly property bool showRunningIndicator: Plasmoid.configuration.showRunningIndicator !== undefined ? Plasmoid.configuration.showRunningIndicator : true
    readonly property bool enableMagicLamp: Plasmoid.configuration.enableMagicLamp !== undefined ? Plasmoid.configuration.enableMagicLamp : true

    // Layout configuration in panel
    readonly property bool inPanel: [
        PlasmaCore.Types.TopEdge,
        PlasmaCore.Types.RightEdge,
        PlasmaCore.Types.BottomEdge,
        PlasmaCore.Types.LeftEdge,
    ].includes(Plasmoid.location)

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property real cellHeight: inPanel ? (parent ? parent.height : 54) : 54
    readonly property real cellWidth: cellHeight

    Layout.fillHeight: !vertical
    Layout.fillWidth: vertical
    Layout.preferredWidth: vertical ? (parent ? parent.width : contentRow.implicitWidth) : contentRow.implicitWidth
    Layout.minimumWidth: vertical ? 0 : contentRow.implicitWidth
    Layout.preferredHeight: vertical ? contentRow.implicitHeight : (parent ? parent.height : 54)
    Layout.minimumHeight: vertical ? contentRow.implicitHeight : 0

    implicitWidth: vertical ? (parent ? parent.width : contentRow.implicitWidth) : contentRow.implicitWidth
    implicitHeight: vertical ? contentRow.implicitHeight : (parent ? parent.height : 54)

    clip: false

    // KWin Magic Lamp (macOS Genie effect) synchronization
    Plasma5Support.DataSource {
        id: kwinEffectRunner
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
        }
    }

    function syncMagicLampEffect() {
        if (root.enableMagicLamp) {
            kwinEffectRunner.connectSource(
                "kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled true && " +
                "kwriteconfig6 --file kwinrc --group Plugins --key scaleEnabled false && " +
                "kwriteconfig6 --file kwinrc --group Plugins --key squashEnabled false && " +
                "qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.loadEffect magiclamp 2>/dev/null &"
            );
        }
    }

    Component.onCompleted: {
        syncMagicLampEffect();
    }

    onEnableMagicLampChanged: {
        syncMagicLampEffect();
    }

    function getLaunchersList() {
        var l = Plasmoid.configuration.launchers;
        if (!l) return [];
        if (Array.isArray(l)) return l;
        if (typeof l === "string") return l.split(",").filter(function(s) { return s.length > 0; });
        return [];
    }

    TaskManager.TasksModel {
        id: tasksModel

        filterByVirtualDesktop: Plasmoid.configuration.showOnlyCurrentDesktop || false
        filterByCurrentVirtualDesktop: Plasmoid.configuration.showOnlyCurrentDesktop || false
        filterByActivity: Plasmoid.configuration.showOnlyCurrentActivity || true
        filterByScreen: Plasmoid.configuration.showOnlyCurrentScreen || false

        groupMode: TaskManager.TasksModel.GroupApplications
        sortMode: TaskManager.TasksModel.SortManual

        launcherList: root.getLaunchersList()

        onLauncherListChanged: {
            Plasmoid.configuration.launchers = launcherList;
        }
    }

    // macOS Magnification Engine
    property real mouseTrackX: -1
    property bool isDockHovered: false

    MagnificationEngine {
        id: magEngine
        enabled: root.enableMagnification
        maxScale: root.magnificationMaxScale
        radiusFactor: root.magnificationRadiusFactor
        mouseX: root.mouseTrackX
        isHovered: root.isDockHovered
    }

    HoverHandler {
        id: dockHoverHandler
        cursorShape: Qt.ArrowCursor
        onPointChanged: {
            root.isDockHovered = hovered;
            root.mouseTrackX = point.position.x;
        }
        onHoveredChanged: {
            root.isDockHovered = hovered;
            if (!hovered) {
                root.mouseTrackX = -1;
                tooltip.visible = false;
            }
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 2
        clip: false

        Repeater {
            id: tasksRepeater
            model: tasksModel

            delegate: DockItem {
                id: taskDelegate

                tasksModelRef: tasksModel
                modelIndexVal: index

                baseSize: root.cellHeight
                appName: model.AppName || model.display || ""
                iconSource: model.decoration
                launcherUrl: model.LauncherUrl || ""
                isRunning: model.IsWindow === true
                isFocused: model.IsActive === true
                isMinimized: model.IsMinimized === true
                isStartup: model.IsStartup === true
                demandsAttention: model.IsDemandingAttention === true
                badgeNumber: 0

                currentScale: {
                    if (!root.enableMagnification || !root.isDockHovered || root.mouseTrackX < 0) {
                        return 1.0;
                    }
                    var centerInRoot = contentRow.x + taskDelegate.x + taskDelegate.width / 2.0;
                    return magEngine.calculateScale(centerInRoot, root.cellHeight);
                }

                onActivated: {
                    var idx = tasksModel.makeModelIndex(index);
                    if (taskDelegate.isFocused) {
                        tasksModel.requestToggleMinimized(idx);
                    } else {
                        tasksModel.requestActivate(idx);
                    }
                }

                onLaunchTriggered: {
                    var idx = tasksModel.makeModelIndex(index);
                    tasksModel.requestActivate(idx);
                }

                onContextRequested: function(gx, gy) {
                    contextMenu.targetIndex = index;
                    contextMenu.appName = taskDelegate.appName;
                    contextMenu.launcherUrl = taskDelegate.launcherUrl;
                    contextMenu.isPinned = model.IsLauncher === true;
                    contextMenu.isRunning = model.IsWindow === true;
                    contextMenu.popup();
                }

                HoverHandler {
                    id: itemHover
                    onPointChanged: {
                        if (hovered) {
                            var p = taskDelegate.mapToItem(root, point.position.x, point.position.y);
                            root.isDockHovered = true;
                            root.mouseTrackX = p.x;

                            var pos = taskDelegate.mapToItem(root, taskDelegate.width / 2, 0);
                            tooltip.x = pos.x - tooltip.width / 2;
                            tooltip.y = -root.cellHeight * (taskDelegate.currentScale - 1.0) - tooltip.height - 8;
                            tooltip.text = taskDelegate.appName;
                            tooltip.visible = true;
                        }
                    }
                    onHoveredChanged: {
                        if (!hovered) {
                            tooltip.visible = false;
                        }
                    }
                }
            }
        }
    }

    // macOS Style Floating Capsule Tooltip
    Rectangle {
        id: tooltip
        visible: false
        z: 999
        property alias text: tooltipLabel.text

        implicitWidth: tooltipLabel.implicitWidth + 20
        implicitHeight: tooltipLabel.implicitHeight + 8
        radius: height / 2
        color: Qt.rgba(0.08, 0.09, 0.11, 0.88)
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.2)
        border.width: 1

        Text {
            id: tooltipLabel
            anchors.centerIn: parent
            color: "#FFFFFF"
            font.pixelSize: 11
            font.weight: Font.Medium
            renderType: Text.NativeRendering
        }
    }

    // Context Menu for tasks
    QQC2.Menu {
        id: contextMenu
        property int targetIndex: -1
        property string appName: ""
        property string launcherUrl: ""
        property bool isPinned: false
        property bool isRunning: false

        QQC2.MenuItem {
            text: contextMenu.appName
            font.weight: Font.DemiBold
            enabled: false
        }

        QQC2.MenuSeparator {}

        QQC2.Menu {
            title: i18n("Options")

            QQC2.MenuItem {
                text: i18n("Keep in Dock")
                checkable: true
                checked: contextMenu.isPinned
                onTriggered: {
                    var idx = tasksModel.makeModelIndex(contextMenu.targetIndex);
                    if (contextMenu.isPinned) {
                        tasksModel.requestRemoveLauncher(contextMenu.launcherUrl);
                    } else {
                        tasksModel.requestAddLauncher(contextMenu.launcherUrl);
                    }
                }
            }

            QQC2.MenuItem {
                text: i18n("Open New Window")
                icon.name: "window-new"
                onTriggered: {
                    var idx = tasksModel.makeModelIndex(contextMenu.targetIndex);
                    tasksModel.requestNewInstance(idx);
                }
            }
        }

        QQC2.MenuSeparator {
            visible: contextMenu.isRunning
        }

        QQC2.MenuItem {
            text: i18n("Close")
            icon.name: "window-close"
            visible: contextMenu.isRunning
            onTriggered: {
                var idx = tasksModel.makeModelIndex(contextMenu.targetIndex);
                tasksModel.requestClose(idx);
            }
        }
    }
}
