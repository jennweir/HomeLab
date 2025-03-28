# Storage Controller Config Check

If an nvme drive is not being recognized with `lsblk` or `fdisk --list`,

BIOS > Advanced > System Options > Disable "Configure Storge Controller for Intel Optane" for ahci mode

> Intel Optane uses Rapid Storage Technology (RST), which can override the AHCI mode
> AHCI (Advanced Host Controller Interface) is a standard SATA interface protocol
> disabling Intel Optane removes the override and allows Fedora Server OS to see nvme drive
> allows the system to use the standard NVMe controller and driver, rather than a RAID controller, which can sometimes interfere with NVMe drive recognition
