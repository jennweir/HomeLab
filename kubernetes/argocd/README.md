# Argocd login

NodePort for now
<https://10.0.0.101:31010>

Username: admin

Password: `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode`
