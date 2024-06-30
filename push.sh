#!/bin/bash

# Function to print bold text
print_bold() {
  BOLD=$(tput bold)
  NORMAL=$(tput sgr0)
  echo -e "${BOLD}$1${NORMAL}"
}

# Path to the xcscheme file
SCHEME_FILE="/Users/oladeanio/Library/CloudStorage/GoogleDrive-alfienurse@gmail.com/My Drive/Dev/VidBriefs/APP/vidbriefs-app/VidBriefs-Final.xcodeproj/xcshareddata/xcschemes/VidBriefs-Final.xcscheme"

# Use xmlstarlet to modify the environment variable value
xmlstarlet ed -L -u '//EnvironmentVariable[@key="openai-apikey"]/@value' -v '???' "$SCHEME_FILE"

sleep 3 # wait for file to be written

# Find and delete any backup files that might contain the old secret
find /Users/oladeanio/Library/CloudStorage/GoogleDrive-alfienurse@gmail.com/My\ Drive/Dev/VidBriefs/APP/vidbriefs-app/ -name '*.bak' -type f -delete

# if key's value is safe, commit and push
if grep -q 'value="???' "$SCHEME_FILE"; then
    # Print a message to indicate the variable has been set

    echo ""
    print_bold "openai-apikey has been set to ??? in the Xcode scheme"
    echo ""

    # Add all changes to git, excluding unwanted files
    git add .

    # Commit the changes
    git commit -m "Set openai-apikey to ??? before push"

    # Push the changes to the repository
    git push
else
    echo "Failed to set openai-apikey in the Xcode scheme"
    exit 1
fi