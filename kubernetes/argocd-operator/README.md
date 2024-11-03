# Argocd Operator

<https://quay.io/repository/argoprojlabs/argocd-operator-registry?tab=tags&tag=latest>

<https://argocd-operator.readthedocs.io/en/latest/install/olm/>

## Build for arm/aarch64

### If not logged in

`podman login quay.io`

### Build, Tag, Push

Build image on arm mac for pi (arm)

`podman build -t argocd-operator:<date.of.build> .`

`podman tag argocd-operator:<date.of.build> quay.io/jennweir/argocd-operator:<date.of.build>`

`podman push quay.io/jennweir/argocd-operator:<date.of.build>`

## ArgoCD operator

```bash
kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
kubectl get csv -n operators
```

## Errors

```bash
jenn argocd-operator % k describe pod argocd-catalog-m2sh4 -n olm
Name:             argocd-catalog-m2sh4
Namespace:        olm
Priority:         0
Service Account:  argocd-catalog
Node:             raspberry-pi-3/10.0.0.103
Start Time:       Sat, 02 Nov 2024 22:23:06 -0400
Labels:           olm.catalogSource=argocd-catalog
                  olm.managed=true
                  olm.pod-spec-hash=1xc39k6sc24vCFWmtXdj92rxBYbShtsUoUpGpA
Annotations:      cluster-autoscaler.kubernetes.io/safe-to-evict: true
Status:           Running
SeccompProfile:   RuntimeDefault
IP:               10.244.2.208
IPs:
  IP:           10.244.2.208
Controlled By:  CatalogSource/argocd-catalog
Containers:
  registry-server:
    Container ID:   containerd://4eb358a44bdd12aafc615578f4128a4f1d87e23ec69107160bb02b3a427add9c
    Image:          quay.io/jennweir/argocd-operator:11.02.2024@sha256:539ffd536d9f4c2ea5e14b8b80522acf75994bcb9ea2d78a7265d9ecee70949a
    Image ID:       quay.io/jennweir/argocd-operator@sha256:539ffd536d9f4c2ea5e14b8b80522acf75994bcb9ea2d78a7265d9ecee70949a
    Port:           50051/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 02 Nov 2024 22:23:07 -0400
    Ready:          False
    Restart Count:  0
    Requests:
      cpu:        10m
      memory:     50Mi
    Liveness:     exec [grpc_health_probe -addr=:50051] delay=10s timeout=5s period=10s #success=1 #failure=3
    Readiness:    exec [grpc_health_probe -addr=:50051] delay=5s timeout=5s period=10s #success=1 #failure=3
    Startup:      exec [grpc_health_probe -addr=:50051] delay=0s timeout=5s period=10s #success=1 #failure=10
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-m5ml9 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  kube-api-access-m5ml9:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              kubernetes.io/os=linux
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age   From               Message
  ----     ------     ----  ----               -------
  Normal   Scheduled  32s   default-scheduler  Successfully assigned olm/argocd-catalog-m2sh4 to raspberry-pi-3
  Normal   Pulled     31s   kubelet            Container image "quay.io/jennweir/argocd-operator:11.02.2024@sha256:539ffd536d9f4c2ea5e14b8b80522acf75994bcb9ea2d78a7265d9ecee70949a" already present on machine
  Normal   Created    31s   kubelet            Created container registry-server
  Normal   Started    31s   kubelet            Started container registry-server
  Warning  Unhealthy  21s   kubelet            Startup probe errored: rpc error: code = Unknown desc = failed to exec in container: failed to start exec "310d67d1484cd3b0f1b0dbf6e913ab2f460b423fa6a118c3219540178c44fed6": OCI runtime exec failed: exec failed: unable to start container process: exec: "grpc_health_probe": executable file not found in $PATH: unknown
  Warning  Unhealthy  11s   kubelet            Startup probe errored: rpc error: code = Unknown desc = failed to exec in container: failed to start exec "ae033fbed09da997804f1349108875a5c0ec676ce935bbafc4da153617e46e0a": OCI runtime exec failed: exec failed: unable to start container process: exec: "grpc_health_probe": executable file not found in $PATH: unknown
  Warning  Unhealthy  1s    kubelet            Startup probe errored: rpc error: code = Unknown desc = failed to exec in container: failed to start exec "1b8100005569170f4ffe15c4a536ce29e7720a7bf7fa57e895c3e2731dc2e48b": OCI runtime exec failed: exec failed: unable to start container process: exec: "grpc_health_probe": executable file not found in $PATH: unknown
        "Architecture": "arm64",
jenn argocd-operator % k describe node raspberry-pi-1 | grep "kubernetes.io/arch"
Labels:             beta.kubernetes.io/arch=arm64
                    kubernetes.io/arch=arm64
```
