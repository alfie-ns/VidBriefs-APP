#!/bin/bash
open -a "Google Chrome" "https://platform.openai.com/api-keys"

# Define the bold text escape code
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Multi-line echo with bold text(-e flag to interpret backslashes(\n))
echo -e "\n${BOLD}Enter API key into: vidbriefs-app/vidbriefs-final.xcodeproj/xcshareddate/xcschemes/vidbriefs-final.xcscheme${NORMAL}\n"