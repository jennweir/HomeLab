# Tailscale

## To connect to cluster on non-home network

1. start client on mac
2. ssh into each node
3. `sudo tailscale up` on each node
4. change cluster server in kubeconfig to tailscale ip

## To disconnect from tailscale and reconnect to cluster on home network

1. ssh into each node
2. `sudo tailscale down` on each node to disconnect from the Tailscale network while keeping the service running
3. change cluster server in kubeconfig to home network main ip
4. stop client on mac

## Check status of tailscale on each node

`tailscale status`

## Reset KUBECONFIG if necessary

`export KUBECONFIG=$(pwd)/.kube/config`
