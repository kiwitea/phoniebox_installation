#!/bin/bash

# Wait for network to be up (using ping)
while ! ping -c 1 1.1.1.1 &> /dev/null; do
    sleep 1
done

# Your custom actions after internet connection (replace with your actual commands)
echo "Internet connection is available!"

# Exit the script
exit 0
