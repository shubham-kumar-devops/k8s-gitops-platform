SHELL := /bin/bash
CLUSTER := gitops-demo
KUBECONFIG_EXPORT := export KUBECONFIG=$$(kind get kubeconfig-path --name=$(CLUSTER) 2>/dev/null || echo $$HOME/.kube/config)

.PHONY: help demo cluster argocd bootstrap urls lint destroy

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "\033[36m%-15s\033[0m %s\n",$$1,$$2}'

demo: cluster argocd bootstrap urls ## Full end-to-end demo

cluster: ## Create Kind cluster
	kind create cluster --name $(CLUSTER) --config kind/cluster.yaml
	kubectl cluster-info --context kind-$(CLUSTER)

argocd: ## Install Argo CD
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.11.0/manifests/install.yaml
	kubectl -n argocd rollout status deploy/argocd-server --timeout=300s

bootstrap: ## Apply root app-of-apps
	kubectl apply -f bootstrap/root-app.yaml
	@echo "Argo CD will now sync platform + apps. Watch with: kubectl -n argocd get applications -w"

urls: ## Print URLs & credentials
	@echo "=========================================="
	@echo " Argo CD:  https://argocd.localtest.me"
	@echo " Grafana:  https://grafana.localtest.me (admin / prom-operator)"
	@echo " App:      https://app.localtest.me"
	@echo "=========================================="
	@echo "Argo CD admin password:"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

lint: ## Validate all manifests
	@which kubeconform >/dev/null || (echo "install kubeconform"; exit 1)
	find . -name '*.yaml' -not -path './.git/*' | xargs kubeconform -strict -ignore-missing-schemas || true

destroy: ## Delete the cluster
	kind delete cluster --name $(CLUSTER)
