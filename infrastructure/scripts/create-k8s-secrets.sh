#!/bin/bash

# Script to create Kubernetes secrets from Terraform outputs
# Usage: ./infrastructure/scripts/create-k8s-secrets.sh

set -e

echo "Creating Kubernetes secrets from Terraform outputs..."

# Check if terraform directory exists
if [ ! -d "infrastructure" ]; then
    echo "Error: Must run this script from the project root directory"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if terraform outputs are available
cd infrastructure
if [ ! -f "terraform.tfstate" ]; then
    echo "Error: terraform.tfstate not found. Run 'terraform apply' first"
    exit 1
fi

echo "Extracting Terraform outputs..."

# Get outputs
POSTGRES_USERNAME=$(terraform output -raw postgres_admin_username)
POSTGRES_PASSWORD=$(terraform output -raw postgres_admin_password)
POSTGRES_HOST=$(terraform output -raw postgres_host)
POSTGRES_DATABASE=$(terraform output -raw postgres_database_name)

OPENAI_ENDPOINT=$(terraform output -raw openai_endpoint)
OPENAI_API_KEY=$(terraform output -raw openai_api_key)
OPENAI_DEPLOYMENT_NAME=$(terraform output -raw openai_deployment_name)

ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
ACR_USERNAME=$(terraform output -raw acr_admin_username)
ACR_PASSWORD=$(terraform output -raw acr_admin_password)

cd ..

# Note: Namespace will be created by Helm, so we don't create it here

echo "Creating postgres-credentials secret..."
kubectl create secret generic postgres-credentials \
    --from-literal=username="$POSTGRES_USERNAME" \
    --from-literal=password="$POSTGRES_PASSWORD" \
    --from-literal=host="$POSTGRES_HOST" \
    --from-literal=database="$POSTGRES_DATABASE" \
    -n chatapp \
    --dry-run=client -o yaml | kubectl apply -f -

echo "Creating openai-credentials secret..."
kubectl create secret generic openai-credentials \
    --from-literal=endpoint="$OPENAI_ENDPOINT" \
    --from-literal=api-key="$OPENAI_API_KEY" \
    --from-literal=deployment-name="$OPENAI_DEPLOYMENT_NAME" \
    -n chatapp \
    --dry-run=client -o yaml | kubectl apply -f -

echo "Creating acr-credentials secret..."
kubectl create secret docker-registry acr-credentials \
    --docker-server="$ACR_LOGIN_SERVER" \
    --docker-username="$ACR_USERNAME" \
    --docker-password="$ACR_PASSWORD" \
    -n chatapp \
    --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "✅ All secrets created successfully!"
echo ""
echo "Next steps:"
echo "1. Build and push Docker images, then deploy with Helm:"
echo "   Continue with the deploy.sh script"
