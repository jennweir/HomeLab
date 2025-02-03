# SELinux

Probably shouldn't be allowing access to this but... for now:

```bash
# generate a local policy module to allow libvirtd entrypoint access on the nbdkit file
# allows vm to be created
ausearch -c 'rpc-libvirtd' --raw | audit2allow -M my-rpclibvirtd
semodule -X 300 -i my-rpclibvirtd.pp
```
