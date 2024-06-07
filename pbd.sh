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
  echo "| Process completed successfully|"
  echo "--------------------------------"
  echo "| Push -> Backout -> Delete     |"
  echo "--------------------------------"
  echo ""
else # if push.sh fails
  echo ""
  echo "--------------------------------"
  echo "Error: push.sh failed. Exiting. |"
  echo "--------------------------------"
  echo ""
fi

# 'alfie-ns' ascii
cat <<'EOF'

 ⚙️ Process complete ⚙️ 

         _  __ _                     
   __ _ | |/ _(_) ___       _ __  ___
  / _` || | |_| |/ _ \_____| '_ \/ __|
 | (_| || |  _| |  __/_____| | | \__ \
  \__,_||_|_| |_|\___|     |_| |_|___/
  
EOF