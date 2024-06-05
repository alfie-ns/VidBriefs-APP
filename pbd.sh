#!/bin/bash
current_dir=$(basename "$PWD") # Get current directory name
./push.sh && cd .. && rm -rf "$current_dir" # Run the push script 1st , then back out, 
# Streamline the process of deleting the repo only after push is finished
