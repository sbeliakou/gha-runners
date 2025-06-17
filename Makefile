.PHONY: help cert-manager gha-runner-controller gha-runner-controller-uninstall gha-runner-deployment gha-runner-deployment-uninstall
help:  ## Help
	@echo Usage:
	@echo "  make cert-manager"
	@echo "  make gha-runner-controller"
	@echo "  make gha-runner-deployment"
	@echo
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo 'Recommended flow:'
	@echo "  Deployment:"
	@echo "    1. Install Certificate Manager"
	@printf "       \033[32m%s\033[0m\n" "make cert-manager"
	@echo "    2. Install Github Runner Controller"
	@printf "       \033[32m%s\033[0m\n" "export GITHUB_TOKEN=<your_github_pam_token>"
	@printf "       \033[32m%s\033[0m\n" "make gha-runner-controller"
	@echo "    3. Install Github Runners Deployment"
	@printf "       \033[32m%s\033[0m\n" "export GITHUB_REPO=<your_github_repo>"
	@printf "       \033[32m%s\033[0m\n" "make gha-runner-deployment"
	@echo
	@echo '  Cleanup:'
	@echo "    1. Uninstall Github Runners Deployment"
	@printf "       \033[32m%s\033[0m\n" "make gha-runner-deployment-uninstall"
	@echo "    2. Uninstall Github Runner Controller"
	@printf "       \033[32m%s\033[0m\n" "make gha-runner-controller-uninstall"
	@echo "    3. Uninstall Certificate Manager"
	@printf "       \033[32m%s\033[0m\n" "make cert-manager-uninstall"
	@echo


GHA_CONTROLLER_NS := $(shell cat settings.yaml | grep gha-runner-controller-namespace | sed 's/^.* //')
GHA_RUNNER_NS := $(shell cat settings.yaml | grep gha-runner-namespace | sed 's/^.* //')

cert-manager: ## Deploy Certificate Manager
	@helm repo add jetstack https://charts.jetstack.io
	@helm upgrade --install \
		cert-manager jetstack/cert-manager \
		--namespace cert-manager \
		--create-namespace \
		--version v1.13.1 \
		--set installCRDs=true
	@printf "\nChecking Resources in 'cert-manager' namespace\n\n"
	@kubectl get all -n cert-manager
	@printf "\nSUCCESS: installed cert-manager\n\n"

cert-manager-uninstall: ## Uninstall Certificate Manager
	@helm uninstall cert-manager -n cert-manager
	@kubectl delete ns cert-manager --ignore-not-found=true

gha-runner-controller: ## Deploy Github Runner Controller
	@if [ -z ${GITHUB_TOKEN} ]; then echo Please set GITHUB_TOKEN env variable; exit 1; else true; fi

	@printf "\033[36m%s\033[0m\n" "Configuring $(GHA_CONTROLLER_NS) namespace"
	@kubectl create ns $(GHA_CONTROLLER_NS) --dry-run=client -o yaml | \
		kubectl apply -f -|| true

	@kubectl create secret generic controller-manager \
		-n $(GHA_CONTROLLER_NS) \
		--from-literal=github_token=${GITHUB_TOKEN} \
		--dry-run=client -o yaml | \
		kubectl apply -f -
	@echo

	@printf "\033[36m%s\033[0m\n" "Installing Github Runner Controller"
	@helm upgrade --install actions-runner-controller \
		--namespace $(GHA_CONTROLLER_NS) \
		actions-runner-controller/actions-runner-controller \
		--set syncPeriod=1m \
		--wait
	@echo

	@printf "\033[36m%s\033[0m\n" "Installing Github Runner Controller Scale Set"
	@helm upgrade --install actions-runner-controller-scaleset \
		--namespace $(GHA_CONTROLLER_NS) \
		oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
	@echo

	@printf "\033[36m%s\033[0m\n" "Checking Resources in '$(GHA_CONTROLLER_NS)' namespace"
	@kubectl get all -n $(GHA_CONTROLLER_NS)
	@echo

gha-runner-controller-uninstall: ## Uninstall Github Runner Controller
	@printf "\033[36m%s\033[0m\n" "Uninstalling Github Runner Controller Scale Set"
	@helm uninstall actions-runner-controller-scaleset -n $(GHA_CONTROLLER_NS)
	@echo

	@printf "\033[36m%s\033[0m\n" "Uninstalling Github Runner Controller"
	@helm uninstall actions-runner-controller -n $(GHA_CONTROLLER_NS)
	@echo

	@printf "\033[36m%s\033[0m\n" "Deleting Github Runner Controller Namespace"
	@kubectl delete ns $(GHA_CONTROLLER_NS) --ignore-not-found=true

gha-runner-deployment: ## Install Github Runners
	@if [ -z ${GITHUB_REPO} ]; then echo Please set GITHUB_REPO env variable; exit 1; else true; fi

	@printf "\033[36m%s\033[0m\n" "Configuring RunnerDeployment in $(GHA_RUNNER_NS) namespace"
	helm upgrade --install gha-runner-deployment charts/gha-runner-deployment \
		--namespace "$(GHA_RUNNER_NS)" --create-namespace \
		--set githubRepo="${GITHUB_REPO}"

	@printf "\033[36m%s\033[0m\n" "Checking Resources in '$(GHA_RUNNER_NS)' namespace"
	kubectl get all -n $(GHA_RUNNER_NS)
	@printf "\nSUCCESS: installed Github Actions components\n\n"

gha-runner-deployment-uninstall: ## Uninstall Github Runners Deployment
	@printf "\033[36m%s\033[0m\n" "Uninstalling Github Runners Deployment"
	helm uninstall gha-runner-deployment -n $(GHA_RUNNER_NS)
	@echo
	@printf "\033[36m%s\033[0m\n" "Deleting Github Runners Namespace"
	kubectl delete ns $(GHA_RUNNER_NS) --ignore-not-found=true
	@echo
	@printf "\033[36m%s\033[0m\n" "SUCCESS: uninstalled Github Actions components\n\n"