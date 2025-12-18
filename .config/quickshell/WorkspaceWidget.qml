import QtQuick
import Quickshell

Row {
    id: root
    spacing: 6
    
    Component.onCompleted: {
        console.log("Workspace widget loaded")
        console.log("Initial workspace count:", NiriService.workspaces.length)
    }
    
    // Listen for workspace changes - UPDATED SIGNAL NAME
    Connections {
        target: NiriService
        
        function onWorkspacesUpdated() {
            console.log("Workspaces updated, count:", NiriService.workspaces.length)
        }
    }
    
    Repeater {
        model: NiriService.workspaces
        
        delegate: Rectangle {
            id: workspaceButton
            width: 40
            height: 32
            radius: 8
            
            property var workspace: modelData
            property bool isActive: workspace.is_active || false
            property bool isFocused: workspace.is_focused || false
            property bool isUrgent: workspace.is_urgent || false
            property int workspaceId: workspace.id || 0
            property int workspaceIdx: workspace.idx || 0
            property string workspaceName: workspace.name || ""
            property int windowCount: NiriService.getWindowCount(workspaceId)
            
            Component.onCompleted: {
                console.log("Created workspace pill:", workspaceIdx, "ID:", workspaceId, "focused:", isFocused)
            }
            
            color: {
                if (isFocused) return "#D1D2E8"
                if (isUrgent) return "#bf616a"
                if (isActive) return "#81a1c1"
                if (windowCount > 0) return "#4c566a"
                return "#3b4252"
            }
            
            Behavior on color { 
                ColorAnimation { 
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }
            
            scale: isFocused ? 1.05 : 1.0
            
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutBack
                }
            }
            
            Column {
                anchors.centerIn: parent
                spacing: 2
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: workspaceName !== "" ? workspaceName : workspaceIdx
                    color: isFocused ? "#1D1E27" : "#eceff4"
                    font.family: "SpaceMono Nerd Font Mono"
                    font.pixelSize: 14
                    font.weight: isFocused ? Font.Bold : Font.Medium
                    
                    Behavior on font.weight {
                        NumberAnimation { duration: 100 }
                    }
                }
                
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 2
                    visible: windowCount > 0
                    
                    Repeater {
                        model: Math.min(windowCount, 5)
                        
                        Rectangle {
                            width: 4
                            height: 4
                            radius: 2
                            color: isFocused ? "#8483D8" : "#d8dee9"
                            opacity: 0.8
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                    }
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "+"
                    color: "#d8dee9"
                    font.pixelSize: 8
                    visible: windowCount > 5
                }
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                
                onClicked: {
                    console.log("Switching to workspace:", workspaceIdx, "ID:", workspaceId)
                    NiriService.focusWorkspace(workspaceId)
                }
                
                onEntered: {
                    workspaceButton.opacity = 0.8
                }
                
                onExited: {
                    workspaceButton.opacity = 1.0
                }
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
            
            SequentialAnimation {
                running: isUrgent && !isFocused
                loops: Animation.Infinite
                
                NumberAnimation {
                    target: workspaceButton
                    property: "opacity"
                    from: 1.0
                    to: 0.5
                    duration: 600
                    easing.type: Easing.InOutQuad
                }
                
                NumberAnimation {
                    target: workspaceButton
                    property: "opacity"
                    from: 0.5
                    to: 1.0
                    duration: 600
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
    
    Rectangle {
        width: 60
        height: 32
        radius: 8
        color: "#3b4252"
        visible: NiriService.workspaces.length === 0
        
        Text {
            anchors.centerIn: parent
            text: "No WS"
            color: "#4c566a"
            font.pixelSize: 10
        }
    }
}
