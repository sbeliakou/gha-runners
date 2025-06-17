# Deploying Github Runner on Kubernetes

This repository provides tools and manifests to help you install and manage key solution components in your Kubernetes cluster, including:

1. **cert-manager**: Automates certificate management for your cluster.
2. **GitHub Actions Runner Controller**: Allows you to run GitHub Actions workflows on your own Kubernetes infrastructure.

---

## Installation Process

All installation and management is streamlined using the provided `Makefile`. You can deploy, verify, and remove components with simple `make` commands.

### Prerequisites

Ensure you have the following tools installed:

- **Bash**: For running scripts.
- **kubectl**: To interact with your Kubernetes cluster.
- **Helm**: For managing Kubernetes applications.
- **make**: To run the provided Makefile targets.

You also need to set the following environment variables:

- **GITHUB_TOKEN**: Your GitHub Personal Access Token ([how to create](https://docs.github.com/en/enterprise-server@3.6/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens))
- **GITHUB_REPO**: The GitHub repository in the format `OWNER/REPOSITORY`

#### How to check that your Githup PAM token has sufficient priviliges to register runners

##### 1. Check Your GitHub Token via CLI

```bash
export GITHUB_TOKEN=github_pat_...
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
{
  "login": "sbeliakou",
  ...
}
```

##### 2. Check Token Scopes

To register a runner, the token must have the following:

- **For repository-level runners:**
	-	`repo`
	-	`admin:repo_hook`

- **For organization-level runners:**
	-	`admin:org`
	-	`repo`

> **NOTE:** You cannot use the default GITHUB_TOKEN provided in Actions; you need to create a **PAT** with scopes.

##### 3. Get a Registration Token (Manually)

Try to issue registration token manually:

```bash
export GITHUB_TOKEN=github_pat_...
export GITHUB_REPO=OWNER/REPOSITORY
curl -X POST \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/${GITHUB_REPO}/actions/runners/registration-token
{
  "token": "BMKTU...",
  "expires_at": "2025-06-16T19:50:26.720+03:00"
}
```

---

## Usage Example

### Getting Help

```bash
make help

Usage:
  make cert-manager
  make gha-runner-controller
  make gha-runner-deployment

Targets:
  help                                     Help
  cert-manager                             Deploy Certificate Manager
  cert-manager-uninstall                   Uninstall Certificate Manager
  gha-runner-controller                    Deploy Github Runner Controller
  gha-runner-controller-uninstall          Uninstall Github Runner Controller
  gha-runner-deployment                    Install Github Runners
  gha-runner-deployment-uninstall          Uninstall Github Runners Deployment

Recommended flow:
  Deployment:
    1. Install Certificate Manager
       make cert-manager
    2. Install Github Runner Controller
       export GITHUB_TOKEN=<your_github_pam_token>
       make gha-runner-controller
    3. Install Github Runners Deployment
       export GITHUB_REPO=<your_github_repo>
       make gha-runner-deployment

  Cleanup:
    1. Uninstall Github Runners Deployment
       make gha-runner-deployment-uninstall
    2. Uninstall Github Runner Controller
       make gha-runner-controller-uninstall
    3. Uninstall Certificate Manager
       make cert-manager-uninstall
```

---

## Project Files

- **[Makefile](./Makefile)**: Main entry point for all management commands.
- **[settings.yaml](./settings.yaml)**: Contains namespace and settings for the controller and runners.
- **[charts/](./charts/)**: Contains runner deplyoment chart

---

## Notes

- The Makefile and settings.yaml allow you to easily customize namespaces and other settings.
- All Helm releases and namespaces are managed automatically.
- The provided RBAC and ServiceAccount settings are suitable for most GitHub Actions runner use cases.
- For production, review and restrict permissions as needed.


## Maintainers

| Name | Email |
| ---- | ------ | 
| Siarhei Beliakou | <sbeliakou@gmail.com> |
---