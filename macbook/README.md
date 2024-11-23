# SSH into each machine of pi cluster with a single shell script

## All terminal panes open in iTerm2 as a single window (split vertically)

`osascript macbook/ssh-pi-cluster.app`

## Access the pi cluster locally via .kube/config

`export KUBECONFIG=/Users/jenn/Projects/HomeLab/.kube/config`

### Check connection

`kubectl config get-contexts`

## Once finished, shut down each machine individually

`sudo shutdown -h 1`

## Operators

```bash
brew install operator-sdk 
operator-sdk olm install
```
