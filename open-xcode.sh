#!/bin/bash

# Open Xcode with the current directory
xed .

# Wait for Xcode to open (adjust the sleep time if needed)
sleep 8

# Use AppleScript to run the project
osascript <<EOF
tell application "Xcode"
    activate
    tell application "System Events"
        keystroke "r" using {command down}
    end tell
end tell
EOF
