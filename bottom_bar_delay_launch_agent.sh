#!/bin/bash

# Script to reduce the Dock autohide delay on macOS
# This makes the Dock appear faster when you move your cursor to the bottom of the screen

LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCHAGENT_PLIST="$LAUNCHAGENT_DIR/com.user.reduce-dock-delay.plist"

# Function to apply Dock settings and enable automatic startup
apply_and_enable() {
    echo "Applying Dock settings..."
    defaults write com.apple.dock autohide-delay -float 0.19
    defaults write com.apple.dock autohide-time-modifier -float 0.1
    killall Dock
    
    echo "Creating LaunchAgent for automatic startup..."
    mkdir -p "$LAUNCHAGENT_DIR"
    
    cat > "$LAUNCHAGENT_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.reduce-dock-delay</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>defaults write com.apple.dock autohide-delay -float 0 &amp;&amp; defaults write com.apple.dock autohide-time-modifier -float 0.2 &amp;&amp; killall Dock</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
    
    launchctl load "$LAUNCHAGENT_PLIST" 2>/dev/null
    echo "✓ Done! Settings applied and automatic startup enabled."
}

# Function to disable automatic startup
disable_startup() {
    if [ -f "$LAUNCHAGENT_PLIST" ]; then
        launchctl unload "$LAUNCHAGENT_PLIST" 2>/dev/null
        rm "$LAUNCHAGENT_PLIST"
        echo "✓ Automatic startup disabled."
    else
        echo "Automatic startup is not enabled."
    fi
}

# Function to revert to default
revert_default() {
    echo "Reverting to default settings..."
    defaults delete com.apple.dock autohide-delay 2>/dev/null
    defaults delete com.apple.dock autohide-time-modifier 2>/dev/null
    
    if [ -f "$LAUNCHAGENT_PLIST" ]; then
        launchctl unload "$LAUNCHAGENT_PLIST" 2>/dev/null
        rm "$LAUNCHAGENT_PLIST"
    fi
    
    killall Dock
    echo "✓ Done! Reverted to default settings."
}

# Main menu
echo "Dock Autohide Delay Manager"
echo ""
echo "1) Apply now + Enable automatic startup at login"
echo "2) Disable automatic startup"
echo "3) Back to default"
echo ""
read -p "Enter your choice [1-3]: " choice

case $choice in
    1)
        apply_and_enable
        ;;
    2)
        disable_startup
        ;;
    3)
        revert_default
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac
