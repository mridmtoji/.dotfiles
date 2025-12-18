import QtQuick
import Quickshell

Rectangle {
    id: root
    
    implicitWidth: clock.width + 20
    implicitHeight: 36
    radius: 10
    color: "#3D3D50"

    Text {
        id: clock

        anchors.centerIn: parent
        
        color: "#D1D2E8"
        font.family: "SpaceMono Nerd Font Mono"
        font.pixelSize: 16
        font.weight: Font.Medium
        
        text: {
            const date = systemClock.date
            Qt.formatDateTime(date, "MMM dd × hh:mm")
        }
        
        SystemClock {
            id: systemClock
            precision: SystemClock.Minutes
        }
    }
}
