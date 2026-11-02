import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-system-windows"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Appearance & Glass")
        icon: "preferences-desktop-theme"
        source: "configAppearance.qml"
    }
}
