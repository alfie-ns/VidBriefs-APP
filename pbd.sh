#!/bin/bash

# Get the current directory name
current_dir=$(basename "$PWD")

# Run the push script
if ./push.sh; then # if push.sh succeeds then...

  # Change to the parent directory
  cd ..

  # Remove the repository directory
  rm -rf "$current_dir"
  echo ""
  echo "--------------------------------"
  echo "Process completed successfully. |"
  echo "--------------------------------"
  echo ""
else # if push.sh fails
  echo ""
  echo "--------------------------------"
  echo "Error: push.sh failed. Exiting. |"
  echo "--------------------------------"
  echo ""
fi