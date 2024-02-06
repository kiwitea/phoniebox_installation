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
  - https://github.com/MiczFlor/RPi-Jukebox-RFID/wiki/Troubleshooting-FAQ#spotify-wont-play-but-after-scan-of-library-it-works
  - https://raspberrypi.stackexchange.com/questions/45769/how-to-wait-for-networking-on-login-after-reboot

## Improvements
- faster startup by disabling refreshing spotify playlists: https://github.com/MiczFlor/RPi-Jukebox-RFID/wiki/Troubleshooting-FAQ#spotify-wont-play-but-after-scan-of-library-it-works
  - set `allow_playlists = false` in `/etc/mopidy/mopidy.conf`
