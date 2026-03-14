#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🚀 AZURE STATIC WEBSITE DEPLOYER     ║${NC}"
echo -e "${BLUE}║      Space Theme Edition               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

# Generate unique names using timestamp and random numbers
TIMESTAMP=$(date +%s)
RANDOM_NUM=$RANDOM
RESOURCE_GROUP="staticweb2RG-$TIMESTAMP"
STORAGE_ACCOUNT="spaceweb$TIMESTAMP$RANDOM_NUM"
# Storage account names must be lowercase and alphanumeric
STORAGE_ACCOUNT=$(echo "$STORAGE_ACCOUNT" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')
# Ensure max 24 characters
STORAGE_ACCOUNT="${STORAGE_ACCOUNT:0:24}"
LOCATION="italynorth"

echo -e "\n${YELLOW}📋 Deployment Configuration:${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Location: $LOCATION"
echo "Website Files: $(pwd)"

# Step 1: Check Azure CLI
echo -e "\n${BLUE}Step 1: Checking Azure CLI...${NC}"
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found. Please install it first.${NC}"
    echo "Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi
echo -e "${GREEN}✅ Azure CLI found${NC}"

# Step 2: Check Azure Login
echo -e "\n${BLUE}Step 2: Checking Azure login status...${NC}"
az account show &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Not logged in. Opening browser for login...${NC}"
    az login
else
    echo -e "${GREEN}✅ Already logged in${NC}"
fi

# Step 3: Create Resource Group
echo -e "\n${BLUE}Step 3: Creating Resource Group...${NC}"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --tags "Project=SpaceWebsite" "Environment=Production" "DeploymentDate=$(date)"
    
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Resource group created: $RESOURCE_GROUP${NC}"
else
    echo -e "${RED}❌ Failed to create resource group${NC}"
    exit 1
fi

# Step 4: Create Storage Account
echo -e "\n${BLUE}Step 4: Creating Storage Account...${NC}"
echo "This may take a minute or two..."

az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access true

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Storage account created: $STORAGE_ACCOUNT${NC}"
else
    echo -e "${RED}❌ Failed to create storage account${NC}"
    exit 1
fi

# Step 5: Enable Static Website
echo -e "\n${BLUE}Step 5: Enabling static website hosting...${NC}"
az storage blob service-properties update \
    --account-name $STORAGE_ACCOUNT \
    --static-website \
    --index-document index.html \
    --404-document 404.html

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Static website enabled${NC}"
else
    echo -e "${RED}❌ Failed to enable static website${NC}"
    exit 1
fi

# Step 6: Upload Files
echo -e "\n${BLUE}Step 6: Uploading website files to space...${NC}"

# Show files being uploaded
echo "Files to upload:"
ls -la *.html *.css *.js 2>/dev/null || echo "No files found!"

# Upload all files
az storage blob upload-batch \
    --account-name $STORAGE_ACCOUNT \
    --source . \
    --destination \$web \
    --overwrite \
    --pattern "*.*"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ All files uploaded successfully!${NC}"
else
    echo -e "${RED}❌ Failed to upload files${NC}"
    exit 1
fi

# Step 7: Get Website URL
echo -e "\n${BLUE}Step 7: Getting your cosmic website URL...${NC}"
WEBSITE_URL=$(az storage account show \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query "primaryEndpoints.web" \
    --output tsv)

# Step 8: Test the website
echo -e "\n${BLUE}Step 8: Testing website accessibility...${NC}"
sleep 5  # Wait for propagation
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$WEBSITE_URL")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo -e "${GREEN}✅ Website is live and responding!${NC}"
else
    echo -e "${YELLOW}⚠️  Website returned HTTP $HTTP_STATUS (might need a few more seconds)${NC}"
fi

# Final Output
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  🎉 DEPLOYMENT COMPLETE! Your space website is live!       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}🌍 Website URL:${NC}"
echo -e "${GREEN}$WEBSITE_URL${NC}"
echo ""
echo -e "${YELLOW}📊 Deployment Summary:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Deployment Time: $(date)"
echo "Files Deployed:"
ls -1 *.html *.css *.js 2>/dev/null | sed 's/^/  - /'
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}🔧 Useful Commands:${NC}"
echo "View in browser: $WEBSITE_URL"
echo "Delete resources when done: az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo ""
echo -e "${YELLOW}⚠️  Save this URL - you'll need it for screenshots!${NC}"

# Save URL to file
echo $WEBSITE_URL > website-url.txt
echo -e "${GREEN}✅ Website URL saved to website-url.txt${NC}"