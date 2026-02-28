#!/bin/bash

# Quickshell config installer for Arch Linux
# This script copies all files (except itself) to ~/.config/quickshell
# and installs required dependencies using pacman and yay

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        print_error "This script is designed for Arch Linux only!"
        exit 1
    fi
}

# Check for yay AUR helper
check_yay() {
    if ! command -v yay &> /dev/null; then
        print_warning "yay (AUR helper) not found. Installing yay..."
        
        # Install yay
        sudo pacman -S --needed  git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si 
        cd - > /dev/null
        rm -rf /tmp/yay
        
        print_success "yay installed successfully"
    else
        print_success "yay is already installed"
    fi
}

# Update system and install dependencies
install_dependencies() {
    print_status "Updating package database..."
    sudo pacman -Syu
    
    print_status "Installing dependencies from official repositories..."
    
    # Packages available in official repos
    print_status "Installing python..."
    sudo pacman -S --needed  python || print_warning "Failed to install python"
    
    print_status "Installing python-watchdog..."
    sudo pacman -S --needed  python-watchdog || print_warning "Failed to install python-watchdog"
    
    print_status "Installing swaync..."
    sudo pacman -S --needed  swaync || print_warning "Failed to install swaync"
    
    print_status "Installing ddcutil..."
    sudo pacman -S --needed  ddcutil || print_warning "Failed to install ddcutil"
    
    print_status "Installing wlogout..."
    sudo pacman -S --needed  wlogout || print_warning "Failed to install wlogout"
    
    print_status "Installing hyprpicker..."
    sudo pacman -S --needed  hyprpicker || print_warning "Failed to install hyprpicker"
    
    print_status "Installing ttf-fira-code..."
    sudo pacman -S --needed  ttf-fira-code || print_warning "Failed to install ttf-fira-code"
    
    print_status "Installing AUR packages..."
    
    # Packages available in AUR
    print_status "Installing quickshell from AUR..."
    yay -S --needed  quickshell || print_warning "Failed to install quickshell"
    
    print_status "Installing rmpc from AUR..."
    yay -S --needed  rmpc || print_warning "Failed to install rmpc"
    
    print_status "Installing ttf-fira-code-nerd from AUR..."
    yay -S --needed  ttf-firacode-nerd || print_warning "Failed to install ttf-fira-code-nerd"

    print_status "Installing qt6 from AUR..."
    yay -S --needed qt6 || print_warning "Failed to install qt6"
    
    print_success "All dependencies installed"
}

# Create backup of existing config if it exists
backup_existing() {
    local config_dir="$HOME/.config/quickshell"
    
    if [ -d "$config_dir" ]; then
        local backup_dir="$HOME/.config/quickshell.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Existing quickshell config found. Creating backup at $backup_dir"
        mv "$config_dir" "$backup_dir"
        print_success "Backup created"
    fi
}

# Copy files to config directory
copy_config_files() {
    local source_dir="$(pwd)"
    local target_dir="$HOME/.config/quickshell"
    
    print_status "Creating target directory: $target_dir"
    mkdir -p "$target_dir"
    
    print_status "Copying files to $target_dir..."
    
    # Find all files and copy them, excluding install.sh and hidden directories
    find . -type f \
        -not -path "*/\.*" \
        -not -name "install.sh" \
        -not -name "*.swp" \
        -not -name "*.swo" \
        -print0 | while IFS= read -r -d '' file; do
            # Remove leading "./" from file path
            relpath="${file#./}"
            target="$target_dir/$relpath"
            
            # Create target directory if it doesn't exist
            mkdir -p "$(dirname "$target")"
            
            # Copy the file
            cp "$file" "$target"
            echo "  Copied: $relpath"
        done
    
    print_success "Files copied successfully"
}

# Set proper permissions
set_permissions() {
    local target_dir="$HOME/.config/quickshell"
    
    print_status "Setting permissions..."
    
    # Make scripts executable
    if [ -d "$target_dir/scripts" ]; then
        chmod +x "$target_dir/scripts/"* 2>/dev/null || true
        print_status "Made scripts executable"
    fi
    
    print_success "Permissions set"
}

# Verify installation
verify_installation() {
    local target_dir="$HOME/.config/quickshell"
    
    print_status "Verifying installation..."
    
    if [ -f "$target_dir/shell.qml" ]; then
        print_success "Verified: shell.qml is present"
    else
        print_warning "shell.qml not found in target directory. Something may have gone wrong."
    fi
    
    # Count files copied
    local file_count=$(find "$target_dir" -type f -not -path "*/\.*" | wc -l)
    print_status "Total files installed: $file_count"
}

# Main installation function
main() {
    print_status "Starting Quickshell config installation..."
    
    # Check if running as root (should not)
    if [ "$EUID" -eq 0 ]; then 
        print_error "Please do not run this script as root"
        exit 1
    fi
    
    # Run installation steps
    check_arch
    check_yay
    install_dependencies
    backup_existing
    copy_config_files
    set_permissions
    verify_installation
    
    print_success "Installation complete!"
    print_status "Quickshell config has been installed to: $HOME/.config/quickshell"
    print_status "You may need to restart quickshell or your session for changes to take effect"
}

# Run main function
main "$@"
