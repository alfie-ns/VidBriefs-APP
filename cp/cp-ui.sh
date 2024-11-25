#!/bin/bash
if find ../VidBriefs-Final/UI -name "*.swift" -type f -exec echo "File: {}" \; -exec cat {} \; -exec echo \; | pbcopy; then
  echo -e "\033[1mCopied all Swift UI files to clipboard\033[0m"
fi