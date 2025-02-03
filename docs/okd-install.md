# OKD installation notes

<https://docs.okd.io/4.17/installing/installing_bare_metal/installing-bare-metal.html#installation-obtaining-installer_installing-bare-metal>

<https://docs.okd.io/4.17/installing/installing_platform_agnostic/installing-platform-agnostic.html>

## VM base image creation

```bash
./openshift-install coreos print-stream-json | grep '\.iso[^.]'
                                "location": "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20231101.3.0/x86_64/fedora-coreos-39.20231101.3.0-live.x86_64.iso",
```

Create all virtual machines for the cluster nodes using image with ssh key injected

## Create fedora image with ssh-config ignition injected

```bash
# can be done on apache server with podman as non-root user
podman machine init coreos-image-creation
podman machine start coreos-image-creation
# once fedora-coreos-39.iso and master, worker, bootstrap files are transferred to /var/www/html
podman pull quay.io/coreos/coreos-installer:release
# inject respective ignition into iso
# :z option tells SELinux to allow the container to access the file with a shared label
podman run --rm -v /var/www/html:/data:z quay.io/coreos/coreos-installer:release iso ignition embed -i /data/ssh-config.ign /data/fedora-stable-iso.iso
# specific ignition is injected by bootstrap
```

Then ssh into each virtual machine and inject the respective ign using the coreos installer

```bash
sudo coreos-installer install --ignition-url=http://<HTTP_server>/<node_type>.ign <device> --ignition-hash=sha512-<digest>  

# get device by checking the available disks in the vm
lsblk

# using virtio emulation, so device is likely
/dev/vda
```

## See status of api and be notified when bootstrap resources can be removed

```bash
./openshift-install --dir <openshift-install-path> wait-for bootstrap-complete --log-level=info
```

## Approve csrs

```bash
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve
```
