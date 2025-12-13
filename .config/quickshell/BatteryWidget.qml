import QtQuick
import Quickshell
import Quickshell.Services.UPower

Rectangle {
    id: root
    
    implicitWidth: batteryRow.width + 16
    implicitHeight: 36
    radius: 8
    color: "#3D3D50"
    
    // Battery state
    readonly property bool hasBattery: UPower.displayDevice && UPower.displayDevice.percentage > 0
    readonly property real batPercentage: UPower.displayDevice ? UPower.displayDevice.percentage : 0
    readonly property bool batCharging: UPower.displayDevice ? 
        UPower.displayDevice.state === UPowerDeviceState.Charging : false
    
    // Battery icons (Nerd Font)
    readonly property var batIcons: [
        "󰁹", // 100%
        "󰂂", // 90%
        "󰂁", // 80%
        "󰂀", // 70%
        "󰁿", // 60%
        "󰁾", // 50%
        "󰁽", // 40%
        "󰁼", // 30%
        "󰁻", // 20%
        "󰁺", // 10%
        "󰂃"  // 0%
    ]
    
    // Get icon based on percentage
    readonly property string batIcon: {
        const index = 10 - Math.round(batPercentage * 10)
        return batIcons[Math.min(index, 10)]
    }
    
    // Charging animation
    property int chargeIconIndex: 0
    readonly property string chargeIcon: batIcons[10 - chargeIconIndex]
    
    // Battery color based on level
    readonly property color batteryColor: {
        if (batCharging) return "#a3be8c" // Green when charging
        if (batPercentage < 0.15) return "#E66D75" // Red when low
        if (batPercentage < 0.30) return "#D9B469" // Yellow when medium-low
        return "#93C591" // White when normal
    }
    
    visible: hasBattery
    
    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 8
        
        // Battery icon
        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: root.batteryColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            text: batCharging ? chargeIcon : batIcon
            
            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
        
        // Battery percentage
        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: root.batteryColor
            font.family: "Maple Mono NF"
            font.pixelSize: 16
            font.weight: Font.Medium
            text: Math.round(batPercentage * 100) + "%"
            
            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
    
    // Charging animation timer
    Timer {
        interval: 600
        repeat: true
        running: batCharging
        
        onTriggered: {
            chargeIconIndex = (chargeIconIndex + 1) % 10
        }
    }
    
    // Hover effect
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            root.color = "#3b4252"
        }
        
        onExited: {
            root.color = "#2e3440"
        }
        
        onClicked: {
            console.log("Battery clicked!")
            console.log("Percentage:", Math.round(batPercentage * 100) + "%")
            console.log("State:", batCharging ? "Charging" : "Discharging")
        }
    }
    
    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }
    
    Component.onCompleted: {
        console.log("BatteryWidget loaded")
        console.log("Has battery:", hasBattery)
        if (hasBattery) {
            console.log("Battery percentage:", Math.round(batPercentage * 100) + "%")
        }
    }
}
