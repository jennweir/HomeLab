# Wipe drive and install new OS

## Prepare Boot Media

tldr; just use Rufus: <https://rufus.ie/> to flash USB (or similar tool)

Otherwise, can try OS-specific media writer like Fedora Media Writer:

Fedora Server 41 for DVD iso downloaded to USB using Download Automatically option in Fedora Media Writer

- <https://fedoraproject.org/server/download/>
- <https://github.com/FedoraQt/MediaWriter/releases>
- <https://docs.fedoraproject.org/en-US/fedora/latest/preparing-boot-media/>

If any problems with Fedora Media Writer, install Microsoft Visual C++ 2015 - 2022 Redistributable (both x86 and x64 were required to avoid missing files):
<https://answers.microsoft.com/en-us/windows/forum/all/vcruntime140dll-and-msvcp140dll-missing-in-windows/caf454d1-49f4-4d2b-b74a-c83fb7c38625>

## Adjust Boot Menu Settings to wipe drive

> Keyboard must be plugged into USB port with keyboard icon so boot menu can be accessed when machine starts up on HP BIOS screen (not all USB ports have full power at startup)

To boot into BIOS menu:

Start computer and immediately F10 to enter the BIOS Setup Utility

<https://support.hp.com/sg-en/document/ish_3912651-2318005-16>

### On first boot (into BIOS)

Advanced > Secure Boot Configuration > Configure Legacy Support and Secure Boot: Legacy Support Enable and Secure Boot Disable

Advanced > Boot Options > Disable Fast Boot, Enable CD-ROM Boot, Enable USB Storage Boot > Main > Save Changes and Exit

### On second boot once previous settings have been applied (into BIOS)

> Prerequisite: USB drive is inserted with new OS .iso installed on it

Advanced > Boot Options > adjust UEFI Boot Order to boot into USB first > Main > Save Changes and Exit

### On third boot (into BIOS)

Security > Hard Drive Utilities > Secure Erase > Enter DriveLock password to allow drive to be erased > Enhanced > Main > Save Changes and Exit

### On fourth boot (into USB media)

Install new OS

> Steps completed here were to install Fedora Linux

- Select "Install Fedora" and complete steps
- Installation Destination > Choose disk to install Fedora on
- Enable Root account and set password
- Set Network & Host Name settings

> If missed host rename for any reason: `sudo -s` or `su -` then `hostnamectl set-hostname <new-name>`

### GRUB command line

- `reboot` to restart
- `halt` to shut down

## Safely eject USB drive once Fedora installed

- View block devices `lsblk`
- Unmount usb with `sudo umount /dev/sd<X>`
- Eject usb with `sudo eject /dev/sd<X>`

## Reboot and shutdown from Fedora Linux command line

- `sudo reboot`
- `sudo shutdown -h now`
