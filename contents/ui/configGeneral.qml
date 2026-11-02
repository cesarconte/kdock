import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Kirigami.FormLayout {
    id: page

    property alias cfg_iconSize: iconSizeSpinBox.value
    property alias cfg_enableMagnification: magnificationCheckBox.checked
    property alias cfg_magnificationMaxScale: maxScaleSlider.value
    property alias cfg_enableBounce: bounceCheckBox.checked
    property alias cfg_showRunningIndicator: runningIndicatorCheckBox.checked
    property alias cfg_showSeparator: separatorCheckBox.checked
    property alias cfg_showStacks: stacksCheckBox.checked
    property alias cfg_showTrash: trashCheckBox.checked
    property alias cfg_soundFeedback: soundCheckBox.checked

    QQC2.SpinBox {
        id: iconSizeSpinBox
        Kirigami.FormData.label: i18n("Dock Icon Size:")
        from: 32
        to: 128
        stepSize: 4
    }

    QQC2.CheckBox {
        id: magnificationCheckBox
        Kirigami.FormData.label: i18n("Magnification:")
        text: i18n("Enable macOS smooth parabolic magnification")
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
        text: i18n("Show indicator dot under running applications")
    }

    QQC2.CheckBox {
        id: separatorCheckBox
        Kirigami.FormData.label: i18n("Sections:")
        text: i18n("Show translucent glass divider")
    }

    QQC2.CheckBox {
        id: stacksCheckBox
        Kirigami.FormData.label: i18n("Folder Stacks:")
        text: i18n("Show Downloads stack folder")
    }

    QQC2.CheckBox {
        id: trashCheckBox
        Kirigami.FormData.label: i18n("Trash:")
        text: i18n("Show Trash can in dock")
    }

    QQC2.CheckBox {
        id: soundCheckBox
        Kirigami.FormData.label: i18n("PipeWire Audio:")
        text: i18n("Play subtle feedback sound effects")
    }
}
