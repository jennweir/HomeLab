# Retrieve /.kube/config details from pi cluster to use kubectl locally

`scp pi-1@10.0.0.101:~/.kube/config ~/Projects/HomeLab/.kube/config`

## Export kubeconfig path if it exists in a non-default location

`export KUBECONFIG=~/Projects/HomeLab/.kube/config`

## Check connection to the cluster is established

`kubectl cluster-info`

## If necessary, unset the kubeconfig to return env variable to its default location

`unset KUBECONFIG`
