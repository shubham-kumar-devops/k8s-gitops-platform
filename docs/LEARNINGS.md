# Learnings

## Why app-of-apps?
A single "root" Argo CD Application points to a folder of child Application manifests. Bootstrap = `kubectl apply` one file; Argo CD does the rest declaratively.

## Why Kind over Minikube?
- Multi-node cluster in seconds
- Uses Docker Desktop's engine directly (no extra VM)
- Native support for `extraPortMappings` → host `:80/:443` work

## Why `localtest.me`?
Public DNS wildcard that resolves to `127.0.0.1`. No `/etc/hosts` edits, works on Windows/macOS/Linux identically.

## Docker Desktop tuning
- Allocate **4 CPU / 8 GB RAM** minimum (Settings → Resources)
- Enable WSL2 backend on Windows for best performance
- If ports 80/443 are in use, change `hostPort` in `kind/cluster.yaml`

## Argo CD sync waves
Ingress must be up before cert-manager issuers can validate. Prometheus CRDs must exist before ServiceMonitors. We order via filename prefix (`01-`, `02-`, ...) and rely on Argo CD retry.

## Cost
Everything runs locally. **$0.**
