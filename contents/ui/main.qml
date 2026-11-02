import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    // Eliminate any native Plasma frame, background rectangle or desktop widget handle
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // Plasma configuration bindings
    readonly property int iconSize: Plasmoid.configuration.iconSize || 56
    readonly property bool enableMagnification: Plasmoid.configuration.enableMagnification !== undefined ? Plasmoid.configuration.enableMagnification : true
    readonly property real magnificationMaxScale: Plasmoid.configuration.magnificationMaxScale || 1.65
    readonly property real magnificationRadiusFactor: Plasmoid.configuration.magnificationRadiusFactor || 2.6
    readonly property bool enableBounce: Plasmoid.configuration.enableBounce !== undefined ? Plasmoid.configuration.enableBounce : true
    readonly property bool showRunningIndicator: Plasmoid.configuration.showRunningIndicator !== undefined ? Plasmoid.configuration.showRunningIndicator : true
    readonly property bool showSeparator: Plasmoid.configuration.showSeparator !== undefined ? Plasmoid.configuration.showSeparator : true
    readonly property bool showStacks: Plasmoid.configuration.showStacks !== undefined ? Plasmoid.configuration.showStacks : true
    readonly property bool showTrash: Plasmoid.configuration.showTrash !== undefined ? Plasmoid.configuration.showTrash : true
    readonly property int dockThemeStyle: Plasmoid.configuration.dockThemeStyle || 0
    readonly property bool soundFeedback: Plasmoid.configuration.soundFeedback !== undefined ? Plasmoid.configuration.soundFeedback : true

    // Layout dimensions: allocate vertical clearance for smooth magnification and tooltip without clipping
    readonly property real dockBarHeight: root.iconSize + 14
    readonly property real totalCalculatedHeight: (root.enableMagnification ? (root.iconSize * root.magnificationMaxScale) : root.iconSize) + 38
    readonly property real totalCalculatedWidth: Math.max(200, itemsRow.implicitWidth + 32)

    implicitWidth: totalCalculatedWidth
    implicitHeight: totalCalculatedHeight
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight

    clip: false

    AudioEffects {
        id: audioEffects
        soundEnabled: root.soundFeedback
    }

    TaskManager.TasksModel {
        id: tasksModel

        filterByVirtualDesktop: Plasmoid.configuration.showOnlyCurrentDesktop || false
        filterByCurrentVirtualDesktop: Plasmoid.configuration.showOnlyCurrentDesktop || false
        filterByActivity: Plasmoid.configuration.showOnlyCurrentActivity || true
        filterByScreen: Plasmoid.configuration.showOnlyCurrentScreen || false

        groupMode: TaskManager.TasksModel.GroupApplications
        sortMode: TaskManager.TasksModel.SortAlpha
    }

    MagnificationEngine {
        id: magEngine
        enabled: root.enableMagnification
        maxScale: root.magnificationMaxScale
        radiusFactor: root.magnificationRadiusFactor
    }

    // Dock outer container (macOS Sequoia Frosted Glass)
    DockContainer {
        id: container
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        themeStyle: root.dockThemeStyle
        contentHeight: root.dockBarHeight
        contentWidth: itemsRow.implicitWidth

        // HoverHandler tracks cursor continuously without blocking mouse clicks or drag-and-drop
        HoverHandler {
            id: dockHoverHandler
            cursorShape: Qt.ArrowCursor
            onPointChanged: {
                if (hovered) {
                    magEngine.isHovered = true;
                    magEngine.mouseX = point.position.x - itemsRow.x;
                }
            }
            onHoveredChanged: {
                magEngine.isHovered = hovered;
                if (!hovered) {
                    magEngine.mouseX = -1;
                    tooltip.visibleTooltip = false;
                }
            }
        }

        Row {
            id: itemsRow
            anchors.centerIn: parent
            spacing: 6
            clip: false

            // App Tasks & Launchers (Pinned + Running)
            Repeater {
                id: tasksRepeater
                model: tasksModel

                delegate: DockItem {
                    id: taskDelegate

                    property int modelIndex: index
                    property var itemModel: model

                    baseSize: root.iconSize
                    appName: model.AppName || model.display || ""
                    iconSource: model.decoration
                    launcherUrl: model.LauncherUrl || ""
                    isRunning: model.IsWindow === true
                    isFocused: model.IsActive === true
                    demandsAttention: model.IsDemandingAttention === true
                    badgeNumber: 0

                    currentScale: {
                        if (!root.enableMagnification) return 1.0;
                        var centerInRow = taskDelegate.x + (taskDelegate.width / 2);
                        return magEngine.calculateScale(centerInRow, root.iconSize);
                    }

                    onActivated: {
                        var idx = tasksModel.index(modelIndex, 0);
                        tasksModel.requestActivate(idx);
                    }

                    onLaunchTriggered: {
                        audioEffects.playLaunchSound();
                        var idx = tasksModel.index(modelIndex, 0);
                        tasksModel.requestActivate(idx);
                    }

                    onContextRequested: function(gx, gy) {
                        contextMenu.targetIndex = modelIndex;
                        contextMenu.appName = taskDelegate.appName;
                        contextMenu.launcherUrl = taskDelegate.launcherUrl;
                        contextMenu.isPinned = model.IsLauncher === true;
                        contextMenu.isRunning = model.IsWindow === true;
                        contextMenu.popup();
                    }

                    // Tooltip & hover magnification fallback support
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        onPositionChanged: function(mouse) {
                            var p = taskDelegate.mapToItem(container, mouse.x, mouse.y);
                            magEngine.isHovered = true;
                            magEngine.mouseX = p.x - itemsRow.x;
                        }
                        onEntered: {
                            var rowPos = taskDelegate.mapToItem(container, taskDelegate.width / 2, 0);
                            tooltip.targetX = rowPos.x;
                            tooltip.targetY = -(root.iconSize * (taskDelegate.currentScale - 1.0)) - 10;
                            tooltip.text = taskDelegate.appName;
                            tooltip.visibleTooltip = true;
                        }
                        onExited: {
                            tooltip.visibleTooltip = false;
                        }
                    }
                }
            }

            // Section Divider
            Separator {
                id: dockSeparator
                visible: root.showSeparator && (root.showStacks || root.showTrash)
                anchors.verticalCenter: parent.verticalCenter
                baseHeight: root.iconSize * 0.72
            }

            // Stacks: Downloads Folder
            StacksItem {
                id: downloadsStack
                visible: root.showStacks
                baseSize: root.iconSize
                folderPath: "Downloads"
                folderName: i18n("Downloads")
                folderIcon: "folder-download"

                currentScale: {
                    if (!root.enableMagnification) return 1.0;
                    var centerInRow = downloadsStack.x + (downloadsStack.width / 2);
                    return magEngine.calculateScale(centerInRow, root.iconSize);
                }

                onStackOpened: {
                    audioEffects.playStackOpenSound();
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    onPositionChanged: function(mouse) {
                        var p = downloadsStack.mapToItem(container, mouse.x, mouse.y);
                        magEngine.isHovered = true;
                        magEngine.mouseX = p.x - itemsRow.x;
                    }
                    onEntered: {
                        var pos = downloadsStack.mapToItem(container, downloadsStack.width / 2, 0);
                        tooltip.targetX = pos.x;
                        tooltip.targetY = -(root.iconSize * (downloadsStack.currentScale - 1.0)) - 10;
                        tooltip.text = i18n("Downloads");
                        tooltip.visibleTooltip = true;
                    }
                    onExited: {
                        tooltip.visibleTooltip = false;
                    }
                }
            }

            // Trash Can
            TrashItem {
                id: dockTrash
                visible: root.showTrash
                baseSize: root.iconSize

                currentScale: {
                    if (!root.enableMagnification) return 1.0;
                    var centerInRow = dockTrash.x + (dockTrash.width / 2);
                    return magEngine.calculateScale(centerInRow, root.iconSize);
                }

                onTrashEmptied: {
                    audioEffects.playTrashSound();
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    onPositionChanged: function(mouse) {
                        var p = dockTrash.mapToItem(container, mouse.x, mouse.y);
                        magEngine.isHovered = true;
                        magEngine.mouseX = p.x - itemsRow.x;
                    }
                    onEntered: {
                        var pos = dockTrash.mapToItem(container, dockTrash.width / 2, 0);
                        tooltip.targetX = pos.x;
                        tooltip.targetY = -(root.iconSize * (dockTrash.currentScale - 1.0)) - 10;
                        tooltip.text = dockTrash.isTrashFull ? i18n("Trash (%1 items)", dockTrash.trashCount) : i18n("Trash");
                        tooltip.visibleTooltip = true;
                    }
                    onExited: {
                        tooltip.visibleTooltip = false;
                    }
                }
            }
        }

        // macOS Floating Pill Tooltip
        TooltipPopup {
            id: tooltip
            z: 100
        }
    }

    // Context Menu for tasks
    ContextMenu {
        id: contextMenu
        property int targetIndex: -1

        onTogglePinRequested: {
            var idx = tasksModel.index(targetIndex, 0);
            if (isPinned) {
                tasksModel.requestRemoveLauncher(launcherUrl);
            } else {
                tasksModel.requestAddLauncher(launcherUrl);
            }
        }

        onLaunchNewInstanceRequested: {
            var idx = tasksModel.index(targetIndex, 0);
            tasksModel.requestNewInstance(idx);
        }

        onCloseWindowRequested: function(winIdx) {
            var idx = tasksModel.index(targetIndex, 0);
            tasksModel.requestClose(idx);
        }
    }
}
