# SELinux

Probably shouldn't be allowing access to this but... for now:

## libvirtd

```bash
# generate a local policy module to allow libvirtd entrypoint access on the nbdkit file
# allows vm to be created
ausearch -c 'rpc-libvirtd' --raw | audit2allow -M my-rpclibvirtd
semodule -X 300 -i my-rpclibvirtd.pp
```

## haproxy

```bash
# as root, set haproxy_connect_any to true and make it persistent across reboots
setsebool -P haproxy_connect_any=1
```

## allow rpc-virtqemud access on blk_file

```bash
ausearch -c 'rpc-virtqemud' --raw | audit2allow -M my-rpcvirtqemud
semodule -X 300 -i my-rpcvirtqemud.pp
```
