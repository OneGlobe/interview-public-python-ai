# DevSecOps Engineer Interview

## Interview Guidelines

- :white_check_mark: Google / Internet Search
- :white_check_mark: AI questions w/o copy-paste (eg. Claude, ChatGPT, Perplexity)
- :x: AI coding agents, AI autocomplete (eg. Copilot, Cursor, Claude Code)
- :x: Changes made prior to the interview will not be accepted

## Preparation

- [ ] Fork the repository and clone to your local machine
- [ ] Install Azure CLI
- [ ] Install Terraform CLI
- [ ] Install Helm CLI
- [ ] Install Kubernetes CLI (kubectl)

## Setup

### 1. Login to Azure CLI

You will be provided with Azure service principal credentials. Use them to login:

```bash
az login --service-principal \
  --username "<provided-app-id>" \
  --password "<provided-password>" \
  --tenant "<provided-tenant-id>"

az account set --subscription "<provided-subscription-id>"
```

### 2. Verify Access

```bash
# Check your account
az account show

# List resources in your resource group
az resource list --resource-group InterviewTechChallengeSandbox
```

### 3. Deploy Infrastructure

```bash
./infrastructure/scripts/deploy.sh
```

The deploy script will:
- Initialize and apply Terraform configuration
- Create AKS cluster and container registry
- Deploy the application using Helm
- Run database migrations

## Tasks

You will complete the following tasks to demonstrate your DevSecOps skills:

### 1. Add Blob Storage to Infrastructure (Terraform)

Add Azure Blob Storage to our Terraform configuration in `infrastructure/`:
- Create a storage account
- Create a blob container
- Ensure it's properly configured and deployed with the rest of the infrastructure

### 2. Deploy Frontend to Kubernetes (Helm)

Deploy the frontend application to our AKS cluster:
- Add frontend deployment configuration to the Helm chart in `infrastructure/helm/chatapp/`
- The frontend should be accessible via a LoadBalancer service
- Ensure it can communicate with the backend API

### 3. Create GitHub Action for PR Checks

Create a GitHub Action workflow that runs on pull requests:
- Run `ruff` (linter) on the backend Python code
- Run `pyright` (type checker) on the backend Python code
- The workflow should fail if either check fails

## Requirements

- All infrastructure must be managed as code in this repository
- Be prepared to demonstrate your solution running in Azure and in GitHub

You will be provided with Azure credentials and access to deploy your changes.