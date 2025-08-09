import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= Config.options.battery.low / 100
    readonly property bool isFull: percentage >= 1.0 // 100%
    readonly property color batteryLowBackground: Appearance.m3colors.darkmode ? Appearance.m3colors.m3error : Appearance.m3colors.m3errorContainer
    readonly property color batteryLowOnBackground: Appearance.m3colors.darkmode ? Appearance.m3colors.m3errorContainer : Appearance.m3colors.m3error

    readonly property color batteryColor: {
        if (isFull) return "#2196F3" // Blue at 100%
        if (isCharging) return "#4CAF50" // Green when charging
        if (isLow) return "#F44336" // Red below 20%
        return Appearance.colors.colOnLayer1 // Default color
    }
    readonly property color batteryBackgroundColor: {
        if (isFull) return "#BBDEFB" // Light blue background at 100%
        if (isCharging) return "#C8E6C9" // Light green background when charging
        if (isLow) return batteryLowBackground // Red background below 20%
        return Appearance.colors.colSecondaryContainer // Default background
    }

    implicitWidth: rowLayout.implicitWidth + rowLayout.spacing * 2
    implicitHeight: 32

    RowLayout {
        id: rowLayout

        spacing: 4
        anchors.centerIn: parent

        Rectangle {
            implicitWidth: (isCharging ? (boltIconLoader?.item?.width ?? 0) : 0)

            Behavior on implicitWidth {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            color: batteryColor
            text: `${Math.round(percentage * 100)}`
        }

        CircularProgress {
            enableAnimation: false
            Layout.alignment: Qt.AlignVCenter
            lineWidth: 2
            value: percentage
            implicitSize: 26
            colSecondary: batteryBackgroundColor
            colPrimary: batteryColor
            fill: (isLow && !isCharging) || isCharging || isFull

            MaterialSymbol {
                anchors.centerIn: parent
                fill: 1
                text: "battery_full"
                iconSize: Appearance.font.pixelSize.normal
                color: batteryColor
            }

        }

    }

    Loader {
        id: boltIconLoader
        active: true
        anchors.left: rowLayout.left
        anchors.verticalCenter: rowLayout.verticalCenter

        Connections {
            target: root
            function onIsChargingChanged() {
                if (isCharging) boltIconLoader.active = true
            }
        }

        sourceComponent: MaterialSymbol {
            id: boltIcon

            text: "bolt"
            iconSize: Appearance.font.pixelSize.large
            color: "#4CAF50" // Green color for charging bolt
            visible: opacity > 0 // Only show when charging
            opacity: isCharging ? 1 : 0 // Keep opacity for visibility
            onVisibleChanged: {
                if (!visible) boltIconLoader.active = false
            }

            Behavior on opacity {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }

        }
    }

}
