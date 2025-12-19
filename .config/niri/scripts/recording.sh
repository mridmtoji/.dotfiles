#!/bin/bash

# GPU Screen Recorder Wrapper
# Records fullscreen or window/area with system audio only

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default settings
FPS=60
QUALITY="very_high"
CODEC="h264"
CONTAINER="mp4"
OUTPUT_DIR="$HOME/Videos"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if gpu-screen-recorder is installed
check_dependencies() {
    if ! command -v gpu-screen-recorder &> /dev/null; then
        print_error "gpu-screen-recorder is not installed or not in PATH"
        exit 1
    fi
}

# Function to generate output filename
generate_filename() {
    local prefix=$1
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    echo "${OUTPUT_DIR}/${prefix}_${timestamp}.${CONTAINER}"
}

# Function to record fullscreen
record_fullscreen() {
    local output_file=$(generate_filename "fullscreen")
    
    print_info "Starting fullscreen recording..."
    print_info "Output: $output_file"
    print_info "Press Ctrl+C to stop recording"
    echo ""
    
    gpu-screen-recorder \
        -w screen \
        -f "$FPS" \
        -a default_output \
        -q "$QUALITY" \
        -k "$CODEC" \
        -o "$output_file"
    
    print_success "Recording saved to: $output_file"
}

# Function to record window
record_window() {
    print_info "Click on the window you want to record..."
    
    # Check if xdotool is available
    if ! command -v xdotool &> /dev/null; then
        print_error "xdotool is not installed. Install it with: sudo pacman -S xdotool"
        exit 1
    fi
    
    local window_id=$(xdotool selectwindow)
    
    if [ -z "$window_id" ]; then
        print_error "No window selected"
        exit 1
    fi
    
    local output_file=$(generate_filename "window")
    
    print_info "Starting window recording..."
    print_info "Output: $output_file"
    print_info "Press Ctrl+C to stop recording"
    echo ""
    
    gpu-screen-recorder \
        -w "$window_id" \
        -f "$FPS" \
        -a default_output \
        -q "$QUALITY" \
        -k "$CODEC" \
        -o "$output_file"
    
    print_success "Recording saved to: $output_file"
}

# Function to record area/region
record_area() {
    print_info "Select the area you want to record..."
    
    # Check if slop is available (for X11)
    if command -v slop &> /dev/null; then
        local region=$(slop -f "%wx%h+%x+%y")
        
        if [ -z "$region" ]; then
            print_error "No region selected"
            exit 1
        fi
        
        local output_file=$(generate_filename "region")
        
        print_info "Starting region recording..."
        print_info "Output: $output_file"
        print_info "Press Ctrl+C to stop recording"
        echo ""
        
        gpu-screen-recorder \
            -w region \
            -region "$region" \
            -f "$FPS" \
            -a default_output \
            -q "$QUALITY" \
            -k "$CODEC" \
            -o "$output_file"
        
        print_success "Recording saved to: $output_file"
    elif command -v slurp &> /dev/null; then
        # For Wayland
        local region=$(slurp -f "%wx%h+%x+%y")
        
        if [ -z "$region" ]; then
            print_error "No region selected"
            exit 1
        fi
        
        local output_file=$(generate_filename "region")
        
        print_info "Starting region recording..."
        print_info "Output: $output_file"
        print_info "Press Ctrl+C to stop recording"
        echo ""
        
        gpu-screen-recorder \
            -w region \
            -region "$region" \
            -f "$FPS" \
            -a default_output \
            -q "$QUALITY" \
            -k "$CODEC" \
            -o "$output_file"
        
        print_success "Recording saved to: $output_file"
    else
        print_error "Neither slop (X11) nor slurp (Wayland) is installed"
        print_info "Install with: sudo pacman -S slop (for X11) or sudo pacman -S slurp (for Wayland)"
        exit 1
    fi
}

# Function to show menu
show_menu() {
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║   GPU Screen Recorder Wrapper              ║"
    echo "║   (System Audio Only - No Microphone)      ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""
    echo "Select recording mode:"
    echo "  1) Fullscreen"
    echo "  2) Window"
    echo "  3) Area/Region"
    echo "  4) Settings"
    echo "  5) Exit"
    echo ""
    read -p "Enter your choice [1-5]: " choice
}

# Function to show and modify settings
show_settings() {
    while true; do
        echo ""
        echo "═══════════════════════════════════════"
        echo "Current Settings:"
        echo "═══════════════════════════════════════"
        echo "  FPS:        $FPS"
        echo "  Quality:    $QUALITY"
        echo "  Codec:      $CODEC"
        echo "  Container:  $CONTAINER"
        echo "  Output Dir: $OUTPUT_DIR"
        echo "═══════════════════════════════════════"
        echo ""
        echo "1) Change FPS (current: $FPS)"
        echo "2) Change Quality (current: $QUALITY)"
        echo "3) Change Codec (current: $CODEC)"
        echo "4) Change Container (current: $CONTAINER)"
        echo "5) Change Output Directory (current: $OUTPUT_DIR)"
        echo "6) Back to main menu"
        echo ""
        read -p "Enter your choice [1-6]: " settings_choice
        
        case $settings_choice in
            1)
                read -p "Enter FPS (e.g., 30, 60, 120): " new_fps
                if [[ "$new_fps" =~ ^[0-9]+$ ]]; then
                    FPS=$new_fps
                    print_success "FPS set to $FPS"
                else
                    print_error "Invalid FPS value"
                fi
                ;;
            2)
                echo "Quality options: medium, high, very_high, ultra"
                read -p "Enter quality: " new_quality
                QUALITY=$new_quality
                print_success "Quality set to $QUALITY"
                ;;
            3)
                echo "Codec options: h264, hevc, av1, vp8, vp9"
                read -p "Enter codec: " new_codec
                CODEC=$new_codec
                print_success "Codec set to $CODEC"
                ;;
            4)
                echo "Container options: mp4, mkv, webm, flv"
                read -p "Enter container: " new_container
                CONTAINER=$new_container
                print_success "Container set to $CONTAINER"
                ;;
            5)
                read -p "Enter output directory: " new_dir
                # Expand ~ to home directory
                new_dir="${new_dir/#\~/$HOME}"
                # Create directory if it doesn't exist
                mkdir -p "$new_dir" 2>/dev/null || {
                    print_error "Cannot create directory: $new_dir"
                    continue
                }
                OUTPUT_DIR=$new_dir
                print_success "Output directory set to $OUTPUT_DIR"
                ;;
            6)
                break
                ;;
            *)
                print_error "Invalid choice"
                ;;
        esac
    done
}

# Main function
main() {
    check_dependencies
    
    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"
    
    # If arguments are provided, use them directly
    if [ $# -gt 0 ]; then
        case "$1" in
            fullscreen|full|f)
                record_fullscreen
                ;;
            window|win|w)
                record_window
                ;;
            area|region|a|r)
                record_area
                ;;
            *)
                print_error "Invalid argument. Use: fullscreen, window, or area"
                exit 1
                ;;
        esac
        exit 0
    fi
    
    # Interactive menu mode
    while true; do
        show_menu
        
        case $choice in
            1)
                record_fullscreen
                ;;
            2)
                record_window
                ;;
            3)
                record_area
                ;;
            4)
                show_settings
                ;;
            5)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1-5."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"
