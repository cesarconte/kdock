import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.Menu {
    id: root

    property string appName: ""
    property string launcherUrl: ""
    property bool isPinned: false
    property bool isRunning: false
    property var windowList: []

    signal togglePinRequested()
    signal activateWindowRequested(int index)
    signal closeWindowRequested(int index)
    signal forceQuitRequested()
    signal launchNewInstanceRequested()

    QQC2.MenuItem {
        text: root.appName.length > 0 ? root.appName : i18n("Application")
        font.weight: Font.DemiBold
        enabled: false
    }

    QQC2.MenuSeparator {}

    // Open windows submenu / items
    Instantiator {
        model: root.windowList
        delegate: QQC2.MenuItem {
            text: modelData.title || i18n("Window %1", index + 1)
            icon.name: "preferences-system-windows"
            onTriggered: root.activateWindowRequested(index)
        }
        onObjectAdded: function(index, object) {
            root.insertItem(index + 2, object);
        }
        onObjectRemoved: function(index, object) {
            root.removeItem(object);
        }
    }

    QQC2.MenuSeparator {
        visible: root.windowList.length > 0
    }

    QQC2.Menu {
        title: i18n("Options")

        QQC2.MenuItem {
            text: i18n("Keep in Dock")
            checkable: true
            checked: root.isPinned
            onTriggered: root.togglePinRequested()
        }

        QQC2.MenuItem {
            text: i18n("Open New Window")
            icon.name: "window-new"
            onTriggered: root.launchNewInstanceRequested()
        }
    }

    QQC2.MenuSeparator {
        visible: root.isRunning
    }

    QQC2.MenuItem {
        text: i18n("Quit")
        icon.name: "application-exit"
        visible: root.isRunning
        onTriggered: root.closeWindowRequested(0)
    }

    QQC2.MenuItem {
        text: i18n("Force Quit")
        icon.name: "process-stop"
        visible: root.isRunning
        onTriggered: root.forceQuitRequested()
    }
}
