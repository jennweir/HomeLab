# Retrieve /.kube/config details from pi cluster to use kubectl locally

`scp pi-1@10.0.0.101:~/.kube/config ~/Projects/HomeLab/.kube/config`

## Export kubeconfig path if it exists in a non-default location

`export KUBECONFIG=~/Projects/HomeLab/.kube/config`

## Check connection to the cluster is established

`kubectl cluster-info`

## If necessary, unset the kubeconfig to return env variable to its default location

`unset KUBECONFIG`

## Create token to be able to log into K8s dashboard with the kubeconfig

`kubectl patch serviceaccount default -n default -p '{"automountServiceAccountToken": true}'`

`helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/`

```bash
pi-1@raspberry-pi-1:~ $ kubectl create serviceaccount kube-proxy -n kube-system
error: failed to create serviceaccount: serviceaccounts "kube-proxy" already exists
pi-1@raspberry-pi-1:~ $ kubectl create clusterrolebinding kube-proxy-binding --clusterrole=system:node-proxier --serviceaccount=kube-system:kube-proxy
clusterrolebinding.rbac.authorization.k8s.io/kube-proxy-binding created
pi-1@raspberry-pi-1:~ $ kubectl create secret generic kube-proxy-secret --from-literal=token=$(openssl rand -base64 32) -n kube-system
secret/kube-proxy-secret created
pi-1@raspberry-pi-1:~ $ kubectl get secrets -n kube-system
NAME                TYPE     DATA   AGE
kube-proxy-secret   Opaque   1      5s
```

`http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=_all`

```bash
pi-1@raspberry-pi-1:~ $ TOKEN=$(kubectl describe secret -n kube-system $(kubectl get secret -n kube-system | awk '/^cluster-admin-dashboard-sa-token-/{print $1}') | awk '$1=="token:"{print $2}')
pi-1@raspberry-pi-1:~ $ kubectl create serviceaccount dashboard -n default
serviceaccount/dashboard created
pi-1@raspberry-pi-1:~ $ kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard
clusterrolebinding.rbac.authorization.k8s.io/dashboard-admin created
pi-1@raspberry-pi-1:~ $ kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
```
