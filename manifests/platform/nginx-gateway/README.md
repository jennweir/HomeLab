# NGINX gateway

## Installation

### Gateway API CRDs

`kubectl kustomize https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.3.0 > base/gateway-api-crds.yaml`

### NGINX Gateway CRDs

`https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.3.0/deploy/crds.yaml`

### NGINX Gateway Deployment

`https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.3.0/deploy/default/deploy.yaml`
