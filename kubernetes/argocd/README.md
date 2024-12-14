# Argocd login

Username: admin

Password: `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode | pbcopy`
