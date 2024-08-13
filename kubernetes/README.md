# Commands to check status

`kubectl get pods -n argocd`

`kubectl get services -n argocd`

`kubectl get ingress -n argocd`

`kubectl get secrets -n argocd`

`kubectl get certificates -n argocd`

`kubectl get pods -n ingress-nginx`

`kubectl get service --namespace ingress-nginx nginx-ingress-ingress-nginx-controller --output wide --watch`

`kubectl describe ingress argocd-server-ingress -n argocd`
