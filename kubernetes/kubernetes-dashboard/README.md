# Kubernetes Dashboard login

To get token:

`kubectl -n kubernetes-dashboard create token admin-user | pbcopy`

## Note

"...accessing the dashboard via a LoadBalancer service, MetalLB should forward traffic to the NodePort. If 10.0.0.245 is not working, try accessing it via the node's IP directly on port 30902 (which is mapped to the dashboard's internal port 8443)"

### DNS resolution?

todo
