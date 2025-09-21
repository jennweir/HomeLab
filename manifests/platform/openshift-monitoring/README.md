# Update alertmanager config

```bash
oc -n openshift-monitoring replace secret --filename=<(oc -n openshift-monitoring create secret generic alertmanager-main \
  --from-file=alertmanager.yaml=<(kubectl get secret alertmanager-discord-config -n openshift-monitoring -o jsonpath='{.data.alertmanager\.yaml}' | base64 -d) \
  --dry-run=client -o yaml)
```
