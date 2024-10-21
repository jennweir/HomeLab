# Argocd Operator

<https://quay.io/repository/argoprojlabs/argocd-operator-registry?tab=tags&tag=latest>

<https://argocd-operator.readthedocs.io/en/latest/install/olm/>

## Build for arm/aarch64

### If not logged in

`podman login quay.io`

### Build, Tag, Push

Use contents from Containerfile for source repository:

`podman build --arch arm64 -t argocd-operator:<date.of.build> .`

`podman tag argocd-operator:<date.of.build> quay.io/jennweir/argocd-operator:<date.of.build>`

`podman push quay.io/jennweir/argocd-operator:<date.of.build>`
