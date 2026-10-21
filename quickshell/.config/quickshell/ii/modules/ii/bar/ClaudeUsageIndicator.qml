import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    visible: ClaudeUsage.available
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: !Config.options.bar.tooltips.clickToShow
    acceptedButtons: Qt.NoButton // let clicks reach the sidebar toggle underneath

    component UsageRing: RowLayout {
        id: ring
        required property real percent
        required property string label
        property color baseColor: Appearance.colors.colPrimary
        spacing: 3

        CircularProgress {
            Layout.alignment: Qt.AlignVCenter
            implicitSize: 28
            lineWidth: 3
            value: ring.percent / 100
            colPrimary: ring.percent >= 90 ? Appearance.colors.colError : ring.baseColor
            enableAnimation: false

            StyledText {
                anchors.centerIn: parent
                font.pixelSize: 10
                color: Appearance.colors.colOnLayer1
                text: Math.round(ring.percent).toString()
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
            text: ring.label
        }
    }

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        spacing: 8

        UsageRing {
            percent: ClaudeUsage.sessionUsage
            label: "5h"
        }
        UsageRing {
            percent: ClaudeUsage.weeklyUsage
            label: "7d"
            baseColor: Appearance.colors.colTertiary
        }
    }

    ClaudeUsagePopup {
        hoverTarget: root
    }
}
