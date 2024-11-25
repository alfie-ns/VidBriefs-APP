#!/bin/bash
if find ../VidBriefs-Final/Plans -name "*.md" -type f -exec echo "File: {}" \; -exec cat {} \; -exec echo \; | pbcopy; then
  echo -e "\033[1mCopied all Plans markdown files to clipboard\033[0m"
fi