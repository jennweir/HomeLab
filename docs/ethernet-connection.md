# Prioritize ethernet connection over wifi

This doc assumes a device is prioritizing a wifi connection instead of the ethernet connection.

`nmcli device status` to see connectivity status

`sudo nmcli connection up <device-name>` to activate ethernet connection

## Ensure connection can be established before disconnecting from wifi-connected ssh session

Check connected device is accessible from router

`ping -I <device-name> <router-ip>`

Confirm connection to machine at ethernet ip is successful

`ssh user@<ethernet-ip>`

Disconnect wifi connection

`sudo nmcli radio wifi off`

## Ensure ethernet connection comes up after machine is restarted

`nmcli connection show <device-name>`

Set connection.autoconnect to yes

`nmcli connection modify <device-name> connection.autoconnect yes`

## Renew a DHCP lease

`sudo dhclient -r <device-name>`
