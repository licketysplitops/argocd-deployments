# Bootstrapping the environment

Once terraform has created the kubernetes cluster,
a few things need to be manually prepared before ArgoCD can take over and deploy the applictaions.

## Create ArgoCD namespace

```bash
kubectl create ns argocd
```

## Restore sealed-secrets key (if present)

```bash
kubectl -n kube-system apply -f sealed-secrets.key
```

### If that key does not exist
The sealed secrets operator needs to be deployed first
```bash
kustomize build manifests/sealed-secrets/base | kubectl apply -f -
```
and all files named `*-sealed.yaml` in `manifests` need to be recreated.

```bash
find manifests -name "*-sealed.yaml"
```

## Bootstrap ArgoCD

```bash
kustomize build manifests/argocd/overlays | kubectl apply -f -
```

SSO will not work yet, because all dependant secrets and services are missing.
Such as cert-manager & ingress-nginx

### Deploy core App of Apps

```bash
kubectl apply -f apps/core.yaml
```
will create the above-mentioned app deployments

Login to ArgoCD through port forward and re-sync the apps until everything is healthy.
You might as well leave it for a few minutes and take a coffee break.
Argo will do it automatically, but it'll take some time.

## Deploy CI apps

```bash
kubectl apply -f apps/ci.yaml
```
creates concourse CI and Vault.
Vault does the autounseal through Azure Key vault.
Update `manifests/vault/base/vault-autounseal-sealed.yaml` if necessary.

## Managing the Cluster through Concourse

All defined pipelines are in the `concourse-pipelines` repository.
As of now, they
- execute terraform
- deploy all defined `apps/*.yaml` files