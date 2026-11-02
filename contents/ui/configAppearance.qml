import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Kirigami.FormLayout {
    id: appearancePage

    property alias cfg_dockThemeStyle: themeComboBox.currentIndex
    property alias cfg_glassBlurRadius: blurSlider.value

    QQC2.ComboBox {
        id: themeComboBox
        Kirigami.FormData.label: i18n("Dock Glass Style:")
        model: [
            i18n("Adaptive (Follows Plasma Theme)"),
            i18n("Frosted Silver Light (macOS Light)"),
            i18n("Deep Graphite Dark (macOS Dark)")
        ]
    }

    QQC2.Slider {
        id: blurSlider
        Kirigami.FormData.label: i18n("Frosted Blur Intensity:")
        from: 12
        to: 64
        stepSize: 4
    }
}
