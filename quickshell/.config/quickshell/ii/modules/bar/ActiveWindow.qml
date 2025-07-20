import "root:/services"
import "root:/modules/common"
import "root:/modules/common/widgets"
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root
    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    property string activeWindowAddress: `0x${activeWindow.HyprlandToplevel.address}`
    property bool focusingThisMonitor: HyprlandData.activeWorkspace.monitor == monitor.name
    property var biggestWindow: HyprlandData.biggestWindowForWorkspace(HyprlandData.monitors[root.monitor.id].activeWorkspace.id)

    implicitWidth: colLayout.implicitWidth

    ColumnLayout {
        id: colLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: -4

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
            elide: Text.ElideRight
            text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? 
                root.activeWindow?.appId :
                (root.biggestWindow?.class) ?? qsTr("Desktop")

        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer0
            elide: Text.ElideRight
            text: {
                if (root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow) {
                    var title = root.activeWindow?.title || "";
                    // Remove application name from the end (like " - Visual Studio Code")
                    var parts = title.split(" - ");
                    if (parts.length > 1) {
                        // Keep all parts except the last one (which is usually the app name)
                        return parts.slice(0, -1).join(" - ");
                    }
                    return title;
                } else {
                    var fallbackTitle = root.biggestWindow?.title || `${qsTr("Workspace")} ${monitor.activeWorkspace?.id}`;
                    var parts = fallbackTitle.split(" - ");
                    if (parts.length > 1) {
                        return parts.slice(0, -1).join(" - ");
                    }
                    return fallbackTitle;
                }
            }
        }

    }

}
