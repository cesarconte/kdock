import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_enableMagnification: magnificationCheckBox.checked
    property alias cfg_magnificationMaxScale: maxScaleSlider.value
    property alias cfg_enableBounce: bounceCheckBox.checked
    property alias cfg_showRunningIndicator: runningIndicatorCheckBox.checked
    property alias cfg_enableMagicLamp: magicLampCheckBox.checked

    QQC2.CheckBox {
        id: magnificationCheckBox
        Kirigami.FormData.label: i18n("Magnification:")
        text: i18n("Enable smooth parabolic magnification effect")
    }

    QQC2.Slider {
        id: maxScaleSlider
        Kirigami.FormData.label: i18n("Magnification Factor:")
        enabled: magnificationCheckBox.checked
        from: 1.2
        to: 2.2
        stepSize: 0.05
    }

    QQC2.CheckBox {
        id: bounceCheckBox
        Kirigami.FormData.label: i18n("Bounce Animation:")
        text: i18n("Bounce icons when opening or demanding attention")
    }

    QQC2.CheckBox {
        id: runningIndicatorCheckBox
        Kirigami.FormData.label: i18n("Indicators:")
        text: i18n("Show macOS glowing dot and pill indicators")
    }

    QQC2.CheckBox {
        id: magicLampCheckBox
        Kirigami.FormData.label: i18n("Window Animation:")
        text: i18n("Enable macOS Genie effect (Magic Lamp) in KWin")
    }
}
