#!/bin/bash

# Complete deployment script for the chat application to AKS
# Usage: ./infrastructure/scripts/deploy.sh

set -e

echo "🚀 Starting deployment to Azure Kubernetes Service..."
echo ""

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running from project root
if [ ! -d "infrastructure" ]; then
    echo "❌ Error: Must run this script from the project root directory"
    exit 1
fi

# Check required tools
echo "Checking required tools..."
for cmd in terraform kubectl az docker helm; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Error: $cmd is not installed or not in PATH"
        exit 1
    fi
done
echo "✅ All required tools are available"
echo ""

# 1. Terraform Apply
echo -e "${BLUE}Step 1: Provisioning Azure infrastructure with Terraform...${NC}"
cd infrastructure

if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "📝 Please edit infrastructure/terraform.tfvars with your values and run this script again"
    exit 0
fi

terraform init
terraform plan -out=tfplan
echo ""
read -p "Do you want to apply this Terraform plan? (yes/no): " APPLY_CONFIRM

if [ "$APPLY_CONFIRM" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

terraform apply tfplan
echo -e "${GREEN}✅ Infrastructure provisioned successfully${NC}"
echo ""

# Get terraform outputs
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
AKS_NAME=$(terraform output -raw aks_cluster_name)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)

cd ..

# 2. Configure kubectl
echo -e "${BLUE}Step 2: Configuring kubectl for AKS...${NC}"
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$AKS_NAME" --overwrite-existing
echo -e "${GREEN}✅ kubectl configured${NC}"
echo ""

# 3. Build and push Docker images
echo -e "${BLUE}Step 4: Building and pushing Docker images...${NC}"
az acr login --name "${ACR_LOGIN_SERVER%%.*}"

echo "Building backend image for linux/amd64..."
docker build --platform linux/amd64 -f ./backend/Dockerfile.prod -t "$ACR_LOGIN_SERVER/chatapp-backend:latest" ./backend

echo "Building frontend image for linux/amd64 with API_URL=$API_URL..."
docker build --platform linux/amd64 \
  --build-arg VITE_API_URL="$API_URL" \
  -f ./frontend/Dockerfile.prod \
  -t "$ACR_LOGIN_SERVER/chatapp-frontend:latest" \
  ./frontend

echo "Pushing images to ACR..."
docker push "$ACR_LOGIN_SERVER/chatapp-backend:latest"
docker push "$ACR_LOGIN_SERVER/chatapp-frontend:latest"
echo -e "${GREEN}✅ Images pushed to ACR${NC}"
echo ""

# 5. Create namespace and secrets first
echo -e "${BLUE}Step 5: Creating namespace and Kubernetes secrets...${NC}"
kubectl create namespace chatapp --dry-run=client -o yaml | kubectl apply -f -
./infrastructure/scripts/create-k8s-secrets.sh
echo ""

# 6. Deploy to Kubernetes using Helm
echo -e "${BLUE}Step 6: Deploying to Kubernetes with Helm...${NC}"

# Clean up any orphaned Helm release metadata
echo "Checking for orphaned Helm releases..."
if kubectl get secrets -n default -l name=chatapp,owner=helm &> /dev/null; then
    echo "Cleaning up orphaned Helm release metadata..."
    kubectl delete secrets -n default -l name=chatapp,owner=helm
fi

helm upgrade --install chatapp ./infrastructure/helm/chatapp \
  --set image.registry="$ACR_LOGIN_SERVER" \
  --wait \
  --timeout 10m

echo -e "${GREEN}✅ Deployed to Kubernetes${NC}"
echo ""

# 7. Get service information
echo -e "${BLUE}Step 7: Getting service information...${NC}"
echo ""
echo -e "${YELLOW}Waiting for LoadBalancer IP (this may take a few minutes)...${NC}"
FRONTEND_IP=""
for i in {1..30}; do
    FRONTEND_IP=$(kubectl get svc frontend -n chatapp -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -n "$FRONTEND_IP" ]; then
        break
    fi
    echo -n "."
    sleep 10
done
echo ""

if [ -n "$FRONTEND_IP" ]; then
    echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
    echo ""
    echo "==================== Deployment Information ===================="
    echo ""
    echo "Frontend URL: http://$FRONTEND_IP"
    echo "Backend API: http://$FRONTEND_IP/api (via frontend proxy)"
    echo ""
    echo "Kubernetes Dashboard:"
    echo "  kubectl get all -n chatapp"
    echo ""
    echo "View logs:"
    echo "  kubectl logs -f deployment/backend -n chatapp"
    echo "  kubectl logs -f deployment/frontend -n chatapp"
    echo ""
    echo "================================================================"
else
    echo -e "${YELLOW}⚠️  Frontend LoadBalancer IP not yet assigned${NC}"
    echo "Run this command to get the IP:"
    echo "  kubectl get svc frontend -n chatapp"
fi
