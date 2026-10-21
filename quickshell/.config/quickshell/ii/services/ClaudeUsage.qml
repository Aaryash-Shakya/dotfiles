pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Claude 5h / weekly usage, read from the cache ccstatusline writes.
 * Values are percentages (0-100). Only as fresh as ccstatusline's last API fetch.
 */
Singleton {
    id: root

    property bool available: false
    property real sessionUsage: 0
    property real weeklyUsage: 0
    property var sessionResetAt: null
    property var weeklyResetAt: null
    property date now: new Date()

    function parseDate(s) {
        if (!s) return null;
        const d = new Date(s.replace(/\.\d+/, "")); // drop microseconds, the JS engine is picky
        return isNaN(d.getTime()) ? null : d;
    }

    // "Sat 14:45 (in 3d 2h)"
    function formatReset(d) {
        if (!d) return Translation.tr("No active window");
        const mins = Math.max(0, Math.round((d - root.now) / 60000));
        const days = Math.floor(mins / 1440);
        const hours = Math.floor((mins % 1440) / 60);
        const left = days > 0 ? `${days}d ${hours}h` : hours > 0 ? `${hours}h ${mins % 60}m` : `${mins}m`;
        return `${Qt.formatDateTime(d, "ddd hh:mm")} (${Translation.tr("in")} ${left})`;
    }

    function parse(text) {
        try {
            const j = JSON.parse(text);
            root.sessionUsage = j.sessionUsage ?? 0;
            root.weeklyUsage = j.weeklyUsage ?? 0;
            root.sessionResetAt = root.parseDate(j.sessionResetAt);
            root.weeklyResetAt = root.parseDate(j.weeklyResetAt);
            root.available = true;
        } catch (e) {
            root.available = false;
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = new Date();
            usageFile.reload();
        }
    }

    FileView {
        id: usageFile
        path: Quickshell.env("HOME") + "/.cache/ccstatusline/usage.json"
        onLoaded: root.parse(usageFile.text())
        onLoadFailed: root.available = false
    }
}
