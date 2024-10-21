# coreos notes

<https://docs.fedoraproject.org/en-US/>

<https://fedoraproject.org/coreos/download?stream=stable&arch=aarch64#download_section>

`VBoxManage showvminfo coreos-vm --details`

## turn yaml into ign using butane

`butane --pretty --strict config.yaml > config.ign`

## on mac to interact with vm

By default, NAT networking does not allow inbound connections to the vm. To allow inbound SSH connections, you can forward connections to e.g. port 2222 on the host to the SSH server in the vm:

`VBoxManage modifyvm coreos-vm --natpf1 "guestssh,tcp,,2222,,22"`

Start and stop vm:

`VBoxManage startvm coreos-vm` --type headless

`VBoxManage controlvm coreos-vm acpipowerbutton`

Connect with:

`ssh core@localhost -p 2222`

## vm first boot

Attach both the Fedora CoreOS live ISO and the Ignition ISO in VirtualBox under Storage settings.
Fedora CoreOS will automatically apply the Ignition config from the secondary CD-ROM on the first boot.

## use container for ignition-validate to check the ignition file is valid

-v $(pwd):/data mounts the current directory (where config.ign file is located) into /data inside the container

`podman run --rm -v $(pwd):/data quay.io/coreos/ignition-validate:release /data/config.ign`

## use container for coreos-installer to inject ignition file into iso

`podman pull quay.io/coreos/coreos-installer:release`

--rm flag tells Podman to remove container after it finishes running

`podman run --rm -v $(pwd):/data quay.io/coreos/coreos-installer:release iso ignition embed -i /data/config.ign /data/fedora-coreos-40.20240920.3.0-live.aarch64.iso`
