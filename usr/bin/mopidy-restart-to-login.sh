#!/bin/bash

SERVICE_NAME="mopidy"

# Check if the service is active
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Service $SERVICE_NAME is running. Restarting..."
    systemctl restart "$SERVICE_NAME"

    # play startup sound, with default volume 20 if not set
    mpgvolume=$((32768*${AUDIOVOLBOOT:-20}/100))
    /usr/bin/mpg123 -f -${mpgvolume} /home/pi/RPi-Jukebox-RFID/shared/short-success-sound-glockenspiel.mp3
else
    echo "Service $SERVICE_NAME is not running."
fi

exit 0
