import Quickshell
import QtQuick 

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 36
            color: "#1D1E27"

            WorkspaceWidget {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
            }

            ClockWidget {
                anchors {
                    centerIn: parent
                    verticalCenter: parent.verticalCenter
                }
            }

            BatteryWidget {
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
