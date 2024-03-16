#!/bin/bash

SERVICE_NAME="mopidy"

# Check if the service is active
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Service $SERVICE_NAME is running. Restarting..."
    systemctl restart "$SERVICE_NAME"
else
    echo "Service $SERVICE_NAME is not running."
fi

exit 0
