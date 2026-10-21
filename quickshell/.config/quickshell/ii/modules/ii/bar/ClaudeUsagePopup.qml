import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    Column {
        anchors.centerIn: parent
        spacing: 8

        StyledPopupHeaderRow {
            icon: "hourglass_top"
            label: Translation.tr("Claude usage")
        }
        Column {
            spacing: 4
            StyledPopupValueRow {
                icon: "clock_loader_60"
                label: Translation.tr("5h used:")
                value: `${Math.round(ClaudeUsage.sessionUsage)}%`
            }
            StyledPopupValueRow {
                icon: "restart_alt"
                label: Translation.tr("5h resets:")
                value: ClaudeUsage.formatReset(ClaudeUsage.sessionResetAt)
            }
            StyledPopupValueRow {
                icon: "date_range"
                label: Translation.tr("Weekly used:")
                value: `${Math.round(ClaudeUsage.weeklyUsage)}%`
            }
            StyledPopupValueRow {
                icon: "event_repeat"
                label: Translation.tr("Weekly resets:")
                value: ClaudeUsage.formatReset(ClaudeUsage.weeklyResetAt)
            }
        }
    }
}
