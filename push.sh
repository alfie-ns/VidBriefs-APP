#!/bin/bash

# Path to the xcscheme file
SCHEME_FILE="/Users/oladeanio/Library/CloudStorage/GoogleDrive-alfienurse@gmail.com/My Drive/Dev/VidBriefs/APP/vidbriefs-app/VidBriefs-Final.xcodeproj/xcshareddata/xcschemes/VidBriefs-Final.xcscheme"

# Backup the original scheme file
cp "$SCHEME_FILE" "${SCHEME_FILE}.bak"

# Use xmlstarlet to modify the environment variable value
xmlstarlet ed -L -u '//EnvironmentVariable[@key="openai-apikey"]/@value' -v '???' "$SCHEME_FILE"

# if key's value is safe, commit and push
if grep -q 'value="???' "$SCHEME_FILE"; then
    # Print a message to indicate the variable has been set
    echo "openai-apikey has been set to ??? in the Xcode scheme"

    # Add all changes to git
    git add .

    # Commit the changes
    git commit -m "Set openai-apikey to ??? before push"

    # Push the changes to the repository
    git push
else
    echo "Failed to set openai-apikey in the Xcode scheme"
    exit 1
fi