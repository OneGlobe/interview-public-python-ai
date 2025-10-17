#!/bin/bash

# Complete destruction script for Azure resources
set -e

echo "🗑️  Starting cleanup of Azure resources..."

cd infrastructure

# Get resource group name from Terraform
RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null || echo "chatapp-dev-rg")

echo "Resource Group: $RESOURCE_GROUP"
echo ""
read -p "Are you sure you want to DELETE all resources? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

# Method 1: Try Terraform destroy first (with timeout)
echo "Attempting Terraform destroy..."
timeout 300 terraform destroy -auto-approve || echo "Terraform destroy failed or timed out, continuing with manual cleanup..."

# Method 2: Delete the entire resource group (faster, deletes everything)
echo "Deleting resource group $RESOURCE_GROUP..."
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

echo ""
echo "✅ Cleanup initiated!"
echo "Note: Resource deletion happens asynchronously and may take 5-10 minutes."
echo "Check status with: az group show --name $RESOURCE_GROUP"

# Clean up local Terraform state
echo ""
read -p "Clean up local Terraform state files? (yes/no): " CLEAN_STATE
if [ "$CLEAN_STATE" = "yes" ]; then
    rm -f terraform.tfstate terraform.tfstate.backup tfplan .terraform.lock.hcl
    rm -rf .terraform
    echo "✅ Local state cleaned"
fi
