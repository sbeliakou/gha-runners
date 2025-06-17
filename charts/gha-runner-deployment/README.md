# gha-runner-deployment chart

Helm chart for deploying GitHub Actions Runner on Kubernetes

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ghaRunnerClusterRoleRules | list | `[.. revise for your cases ..]` | Runner RBAC Rules (**TOO MUCH FOR PRODUCTION!**) |
| ghaRunnerGracefulStopTimeout | int | `15` | Graceful Stop Timeout for the Runner Pods |
| ghaRunnerLabels | list | `["k8s-sbeliakou"]` | Runner Labels |
| ghaRunnerName | string | `"k8s-gha-runner"` |  |
| ghaRunnerReplicas | int | `1` | Runner Replicas |
| ghaRunnerServiceAccountName | string | `"gha-runner-sa"` | Runner Service Account Name |
| githubRepo | string | `"OWNER/REPOSITORY"` | Github Repository (**REQUIRED**) |
| nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node Selector Rules |
| setupAdditionalTools | list | `[script,script,...]` | Additional Tools to be installed in the Runner Pods |
| tolerations | list | `[]` | Tolerations for the Runner Pods |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Siarhei Beliakou | <sbeliakou@gmail.com> |  |

# Requirements:

The following components should be installed:
- [Cert Manager](https://cert-manager.io/docs/)
- [GitHub Actions Runner Controller (ARC)](https://github.com/actions/actions-runner-controller)

## Installation

```bash
helm upgrade --install gha-runner-deployment charts/gha-runner-deployment \
		--namespace "<NAMESPACE>" --create-namespace \
		--set githubRepo="<GITHUB_REPO>"
```

## Uninstallation

```bash
helm uninstall gha-runner-deployment --namespace "<NAMESPACE>"
```
