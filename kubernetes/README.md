# Commands to check status

`kubectl get pods -n argocd`

```bash
pi-1@raspberry-pi-1:~ kubectl get pods -n argocd
NAME                                                READY   STATUS    RESTARTS      AGE
argocd-application-controller-0                     1/1     Running   8 (45h ago)   21d
argocd-applicationset-controller-58b5f8b47c-f494f   1/1     Running   8 (45h ago)   21d
argocd-dex-server-96bd797bf-k6f28                   1/1     Running   8 (45h ago)   21d
argocd-notifications-controller-657b5467b9-w74gg    1/1     Running   8 (45h ago)   21d
argocd-redis-58b4567b8d-5jvpq                       1/1     Running   8 (45h ago)   21d
argocd-repo-server-6c46b7867b-2x59w                 1/1     Running   8 (45h ago)   21d
argocd-server-7b67dbdff8-2xzs9                      1/1     Running   8 (45h ago)   21d
```

`kubectl get services -n argocd`

```bash
pi-1@raspberry-pi-1:~ $ kubectl get services -n argocd
NAME                                      TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
argocd-applicationset-controller          ClusterIP      10.107.177.139   <none>        7000/TCP,8080/TCP            21d
argocd-dex-server                         ClusterIP      10.98.99.20      <none>        5556/TCP,5557/TCP,5558/TCP   21d
argocd-metrics                            ClusterIP      10.98.130.183    <none>        8082/TCP                     21d
argocd-notifications-controller-metrics   ClusterIP      10.108.44.10     <none>        9001/TCP                     21d
argocd-redis                              ClusterIP      10.105.178.34    <none>        6379/TCP                     21d
argocd-repo-server                        ClusterIP      10.105.108.88    <none>        8081/TCP,8084/TCP            21d
argocd-server                             LoadBalancer   10.109.230.70    <pending>     80:32035/TCP,443:31656/TCP   21d
argocd-server-metrics                     ClusterIP      10.103.216.84    <none>        8083/TCP                     21d
```

`kubectl get ingress -n argocd`

```bash
pi-1@raspberry-pi-1:~ $ kubectl get ingress -n argocd
NAME                    CLASS    HOSTS                      ADDRESS   PORTS     AGE
argocd                  <none>   argocd.jenniferpweir.com             80, 443   17d
argocd-server-ingress   nginx    argocd.jenniferpweir.com             80, 443   21d
```

`kubectl get secrets -n argocd`

```bash
pi-1@raspberry-pi-1:~ $ kubectl get secrets -n argocd
NAME                          TYPE                DATA   AGE
argocd-initial-admin-secret   Opaque              1      21d
argocd-notifications-secret   Opaque              0      21d
argocd-redis                  Opaque              1      21d
argocd-repo-server-tls        kubernetes.io/tls   2      21d
argocd-secret                 Opaque              5      21d
argocd-secret-tls-npdhn       Opaque              1      16d
secret-jenniferpweir-com      kubernetes.io/tls   2      17d
```

`kubectl get certificates -n argocd`

```bash
pi-1@raspberry-pi-1:~ $ kubectl get certificates -n argocd
NAME                READY   SECRET              AGE
argocd-secret-tls   False   argocd-secret-tls   16d
```

`kubectl get pods -n ingress-nginx`

```bash
pi-1@raspberry-pi-1:~ $ kubectl get pods -n ingress-nginx
NAME                                                     READY   STATUS    RESTARTS      AGE
nginx-ingress-ingress-nginx-controller-5dfd84cd7-d5x2n   1/1     Running   5 (45h ago)   16d
```

`kubectl get service --namespace ingress-nginx nginx-ingress-ingress-nginx-controller --output wide --watch`

```bash
pi-1@raspberry-pi-1:~ $ kubectl get service --namespace ingress-nginx nginx-ingress-ingress-nginx-controller --output wide --watch
NAME                                     TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE   SELECTOR
nginx-ingress-ingress-nginx-controller   LoadBalancer   10.96.248.246   <pending>     80:31234/TCP,443:31467/TCP   16d   app.kubernetes.io/component=controller,app.kubernetes.io/instance=nginx-ingress,app.kubernetes.io/name=ingress-nginx
```

`kubectl describe ingress argocd-server-ingress -n argocd`

```bash
pi-1@raspberry-pi-1:~ $ kubectl describe ingress argocd-server-ingress -n argocd
Name:             argocd-server-ingress
Labels:           <none>
Namespace:        argocd
Address:
Ingress Class:    nginx
Default backend:  <default>
TLS:
  argocd-secret-tls terminates argocd.jenniferpweir.com
Rules:
  Host                      Path  Backends
  ----                      ----  --------
  argocd.jenniferpweir.com
                            /   argocd-server:https (10.244.2.56:8080)
Annotations:                cert-manager.io/cluster-issuer: letsencrypt-prod
                            nginx.ingress.kubernetes.io/backend-protocol: HTTPS
                            nginx.ingress.kubernetes.io/ssl-passthrough: true
Events:
  Type    Reason  Age   From                      Message
  ----    ------  ----  ----                      -------
  Normal  Sync    26m   nginx-ingress-controller  Scheduled for sync
```

<!-- TODO: figure out how else to do this so its not pending -->
`kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer", "externalIPs":["10.244.2.56"]}}'`

`kubectl get services -n argocd`

```bash
pi-1@raspberry-pi-1:~ $ kubectl get services -n argocd
NAME                                      TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
argocd-applicationset-controller          ClusterIP      10.107.177.139   <none>        7000/TCP,8080/TCP            21d
argocd-dex-server                         ClusterIP      10.98.99.20      <none>        5556/TCP,5557/TCP,5558/TCP   21d
argocd-metrics                            ClusterIP      10.98.130.183    <none>        8082/TCP                     21d
argocd-notifications-controller-metrics   ClusterIP      10.108.44.10     <none>        9001/TCP                     21d
argocd-redis                              ClusterIP      10.105.178.34    <none>        6379/TCP                     21d
argocd-repo-server                        ClusterIP      10.105.108.88    <none>        8081/TCP,8084/TCP            21d
argocd-server                             LoadBalancer   10.109.230.70    10.244.2.56   80:32035/TCP,443:31656/TCP   21d
argocd-server-metrics                     ClusterIP      10.103.216.84    <none>        8083/TCP                     21d
```

<!-- gcloud dns --project=pi-cluster-433101 record-sets create argocd.jenniferpweir.com. --zone="homelab" --type="A" --ttl="300" --rrdatas="10.109.230.70"

gcloud dns --project=pi-cluster-433101 record-sets create www.argocd.jenniferpweir.com. --zone="homelab" --type="CNAME" --ttl="300" --rrdatas="jenniferpweir.com." -->

`kubectl get services --all-namespaces`

<!-- TODO: should only be 1 LB for the ingress-nginx svc and that should route to argocd server -->
```bash
pi-1@raspberry-pi-1:~ $ kubectl get services --all-namespaces
NAMESPACE        NAME                                               TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
argocd           argocd-applicationset-controller                   ClusterIP      10.107.177.139   <none>        7000/TCP,8080/TCP            21d
argocd           argocd-dex-server                                  ClusterIP      10.98.99.20      <none>        5556/TCP,5557/TCP,5558/TCP   21d
argocd           argocd-metrics                                     ClusterIP      10.98.130.183    <none>        8082/TCP                     21d
argocd           argocd-notifications-controller-metrics            ClusterIP      10.108.44.10     <none>        9001/TCP                     21d
argocd           argocd-redis                                       ClusterIP      10.105.178.34    <none>        6379/TCP                     21d
argocd           argocd-repo-server                                 ClusterIP      10.105.108.88    <none>        8081/TCP,8084/TCP            21d
argocd           argocd-server                                      LoadBalancer   10.109.230.70    10.244.2.56   80:32035/TCP,443:31656/TCP   21d
argocd           argocd-server-metrics                              ClusterIP      10.103.216.84    <none>        8083/TCP                     21d
cert-manager     cert-manager                                       ClusterIP      10.106.130.111   <none>        9402/TCP                     16d
cert-manager     cert-manager-webhook                               ClusterIP      10.97.35.13      <none>        443/TCP                      16d
default          kubernetes                                         ClusterIP      10.96.0.1        <none>        443/TCP                      22d
default          metallb-webhook-service                            ClusterIP      10.110.107.139   <none>        443/TCP                      16d
ingress-nginx    nginx-ingress-ingress-nginx-controller             LoadBalancer   10.96.248.246    <pending>     80:31234/TCP,443:31467/TCP   16d
ingress-nginx    nginx-ingress-ingress-nginx-controller-admission   ClusterIP      10.106.68.112    <none>        443/TCP                      16d
kube-system      kube-dns                                           ClusterIP      10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP       22d
metallb-system   metallb-webhook-service                            ClusterIP      10.98.108.235    <none>        443/TCP                      16d
```
