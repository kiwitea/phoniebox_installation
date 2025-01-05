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
  - As a workround: wrote a service script that keeps polling for internet connection and once established, restarts mopidy service, then exits. Must be running in background without blocking anything else. Also added a card that restarts mopidy service and plays a confirmation sound if login was succesful.
    - `settings/rfid_trigger_play.conf`: add trigger variable with card id
      ```
      ### Restart mopidy service and thus retry spotify login
      RESTARTMOPIDY="0003529101"
      ``` 
    - `scripts/rfid_trigger_play.sh`: add action called when card is scanned:
    ```
            $RESTARTMOPIDY)
            sudo service mopidy-retry-login restart
            ;;
    ```

### workaround for spotidy
#### relax autohotstop
autohotstop service was to agressive and impatient, when scanning for SSIDs, we mostly received 'device busy'. After 5 retries it started the hotspot which disabled the already running wifi connection. I increased the retry it waits until wifi device is available from 5 to 10.
#### restart mopidy once internet is available
1. checkout the 3 files in this repository and create a systemd service.
2. service definition goes in `/etc/systemd/system/mopidy-retry-login.service`
  ```bash
  sudo chmod a+x /usr/bin/wait-for-internet.sh
  sudo chmod a+x /usr/bin/mopidy-restart-to-login.sh
  sudo systemctl enable mopidy-retry-login
  ```

## Improvements
### faster startup
- by disabling refreshing spotify playlists: https://github.com/MiczFlor/RPi-Jukebox-RFID/wiki/Troubleshooting-FAQ#spotify-wont-play-but-after-scan-of-library-it-works
  - set `allow_playlists = false` in `/etc/mopidy/mopidy.conf`
- disabling bluetooth: https://raspberrypi.stackexchange.com/questions/53149/disable-power-on-wifi-and-bluetooth-interfaces-during-boot
  - add `dtoverlay=disable-bt` to `/boot/config.txt`
  - disable bluetooth service `sudo systemctl disable bluetooth`
- static ip
  - edit `/etc/dhcpcd.conf`, set X, Y, Z accordingly. Also configure router to assign static ip adres to RPi.
    ```
    interface wlan0
    static ip_address=192.168.X.X/24
    # static ip6_address=fd51:42f8:caae:d92e::ff/64
    static routers=192.168.X.Y
    static domain_name_servers=192.168.Z.Y 192.168.X.Y 8.8.8.8
    noarp
    ipv4only
    noipv6
    ```
- disable IPv6
  - ```bash
    sudo sh -c "echo 'options ipv6 disable=1' >> /etc/modprobe.d/ipv6.conf"
    sudo sh -c "echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf"
    sudo sh -c "echo 'noipv6' >> /etc/dhcpcd.conf"
    sudo sysctl -p
    ```
