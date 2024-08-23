#!/bin/bash
if find ../VidBriefs-Final -name "*.swift" -type f -exec echo "File: {}" \; -exec cat {} \; -exec echo \; | pbcopy; then
  echo -e "\033[1mCopied all Swift files to clipboard\033[0m"
fi
