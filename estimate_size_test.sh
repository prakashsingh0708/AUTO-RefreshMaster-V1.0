#!/bin/bash

# Get the size from df command
df_output=$(df -h /oradump)
size=$(echo "$df_output" | awk 'NR==2{gsub(/[a-zA-Z]/, "", $3); print $3}')

# Get the estimation size from expdp logfile
expdp_estimate="temp_estimate_output.log"
if [ -f "$expdp_estimate" ]; then
    estimation=$(awk -F ': ' '/Total estimation using BLOCKS method:/ {gsub(/[a-zA-Z]/, "", $2); print $2}' "$expdp_estimate" | awk '{print $1}')
else
    echo "Error: Expdp logfile not found."
    exit 1
fi

# Compare the sizes
if (( $(echo "$size > $estimation" | bc -l) )); then
    echo "Size from df ($size G) is greater than Estimation from expdp ($estimation G). Initiating import job..."
    
    # Add the command to initiate the import job here
    # For example, you can call a script or command to start the import
    # Replace the following line with the actual import command
 #   /path/to/import_script.sh
    
else
    echo "Sizes match! Size from df: $size G, Estimation from expdp: $estimation G"
fi
