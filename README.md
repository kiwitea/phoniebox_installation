# phoniebox_installation
documenting building my phoniebox


## Installing raspberry pi os
- 32 bit legacy lite
- after installation, force rpi to actually use 32-bit kernels, by add `arm_64bit=0` to `/boot/config.txt`
  - https://github.com/MiczFlor/RPi-Jukebox-RFID/issues/2041
  - https://github.com/raspberrypi/firmware/issues/1795

## Spotify
- mopidy-spotify doesn't play after reboot because it cannot login because internet is not up yet
  - it must wait until internet is up; seems a problem with raspbian actually as it seems to ignore the preqrequisites of the mopidy.service (network-online.target)
  - as a workaround, we can configure the raspberry to wait for internet connection during boot (`raspi-config` --> enable wait for internet on boot)
    - doesn't work for me. booting takes longer, but spotify still doesn't connect
  - https://github.com/MiczFlor/RPi-Jukebox-RFID/wiki/Troubleshooting-FAQ#spotify-wont-play-but-after-scan-of-library-it-works
  - https://raspberrypi.stackexchange.com/questions/45769/how-to-wait-for-networking-on-login-after-reboot
- Checking mopidy logs about spotify logins: `journalctl -u mopidy -b --grep spotify.web` (`-b` since last boot)
- Restarting mopidy service: `sudo systemctl restart mopidy` (this work, after service restart, spotify connects)
  - setting `allow_playlists = false` in `/etc/mopidy/mopidy.conf` makes restarting mopidy service a lot faster (almost instant) because it doesn't sync all spotify playlists which takes 10-30s (obviously depending on the number of playlists in the account)
  - putting `sudo systemctl restart mopidy` into `/etc/rc.local` doesn't work (presumably because internet is not available yet when it runs)
  - Idea (TODO): write a startup script that keep polling for internet connection and once established, restarts mopidy service, then exits. Must be running in background without blocking anything else.

## Improvements
### faster startup
- by disabling refreshing spotify playlists: https://github.com/MiczFlor/RPi-Jukebox-RFID/wiki/Troubleshooting-FAQ#spotify-wont-play-but-after-scan-of-library-it-works
  - set `allow_playlists = false` in `/etc/mopidy/mopidy.conf`
- disabling bluetooth: https://raspberrypi.stackexchange.com/questions/53149/disable-power-on-wifi-and-bluetooth-interfaces-during-boot
  - add `dtoverlay=disable-bt` to `/boot/config.txt`
  - disable bluetooth service `sudo systemctl disable bluetooth`
  - 
