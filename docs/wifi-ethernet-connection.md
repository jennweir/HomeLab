# Prioritize ethernet connection over wifi

This doc assumes a device is prioritizing a wifi connection instead of the ethernet connection.

`nmcli device status` to see connectivity status

`sudo nmcli connection up <device-name>` to activate ethernet connection

## Ensure connection can be established before disconnecting from wifi-connected ssh session

Check connected device is accessible from router

`ping -I <device-name> <router-ip>`

Confirm connection to machine at ethernet ip is successul

`ssh user@<ethernet-ip>`

Disconnect wifi connection

`sudo nmcli radio wifi off`

## Ensure ethernet connection comes up after machine is restarted

`nmcli connection show <device-name>`

Set connection.autoconnect to yes

`nmcli connection modify <device-name> connection.autoconnect yes`

## Renew a DHCP lease

`sudo dhclient -r <device-name>`

## Swap wifi connections

Closes original connection to host and allows you to start new ssh connection

```bash
sudo nmcli connection add type wifi ifname wlan0 con-name <new-wifi-ssid-connection-name> ssid <new-wifi-ssid>
sudo nmcli connection modify <new-wifi-ssid> wifi-sec.key-mgmt wpa-psk wifi-sec.psk "<new-wifi-ssid-password>"
sudo nmcli connection modify <new-wifi-ssid> connection.autoconnect yes
sudo nmcli connection up <new-wifi-ssid>
```

## Setting DNS server to router

```bash
sudo nmcli con mod "Wired connection 1" ipv4.ignore-auto-dns yes
sudo nmcli con mod "Wired connection 1" ipv4.dns "192.168.0.1 8.8.8.8"
sudo nmcli con up "Wired connection 1"
```
