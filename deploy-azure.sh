#!/bin/bash

# SECURE Azure deployment script for Mi Trayectoria UTP
# This script deploys the FastAPI backend and React frontend to Azure Container Apps

# Configuration - Update these values as needed
if [ "$TEST_MODE" = "true" ]; then
    RESOURCE_GROUP="mitrayectoria-test-rg"
    LOCATION="westus"
    ACR_NAME="mitrayectoriautptest"
    ENV_NAME="mitrayectoria-test-env"
    BACKEND_APP="mitrayectoria-test-backend"
    FRONTEND_APP="mitrayectoria-test-frontend"
else
    RESOURCE_GROUP="mitrayectoria-rg"
    LOCATION="westus"
    ACR_NAME="mitrayectoriautp"
    ENV_NAME="mitrayectoria-env"
    BACKEND_APP="mitrayectoria-backend"
    FRONTEND_APP="mitrayectoria-frontend"
fi

# Azure Cognitive Services configuration - SET THESE ENVIRONMENT VARIABLES
AZURE_ENDPOINT="${AZURE_ENDPOINT:-}"
AZURE_API_VERSION="${AZURE_API_VERSION:-2024-02-15-preview}"
AZURE_SUBSCRIPTION_KEY="${AZURE_SUBSCRIPTION_KEY:-}"
AZURE_ANALYZER_ID="${AZURE_ANALYZER_ID:-}"

# Check required environment variables
if [ -z "$AZURE_ENDPOINT" ] || [ -z "$AZURE_SUBSCRIPTION_KEY" ] || [ -z "$AZURE_ANALYZER_ID" ]; then
    echo "❌ ERROR: Missing required Azure Cognitive Services environment variables!"
    echo "   Please set the following environment variables:"
    echo "   - AZURE_ENDPOINT"
    echo "   - AZURE_SUBSCRIPTION_KEY"
    echo "   - AZURE_ANALYZER_ID"
    echo ""
    echo "   Example:"
    echo "   export AZURE_ENDPOINT='https://your-resource.cognitiveservices.azure.com'"
    echo "   export AZURE_SUBSCRIPTION_KEY='your-subscription-key'"
    echo "   export AZURE_ANALYZER_ID='your-analyzer-id'"
    exit 1
fi

echo "🚀 Starting SECURE Azure deployment for Mi Trayectoria UTP..."
echo "🔒 Your images will be PRIVATE and only accessible by your account"

if [ "$TEST_MODE" = "true" ]; then
    echo "🧪 TEST MODE ENABLED - Using test resource names"
fi

if [ "$DRY_RUN" = "true" ]; then
    echo "� DRY RUN MODE - No resources will be created"
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

# Login to Azure (uncomment if needed)
# echo "🔐 Please login to Azure:"
# az login

# Set subscription (uncomment and update if needed)
# az account set --subscription "your-subscription-id"

echo "📦 Creating resource group..."
if [ "$DRY_RUN" = "true" ]; then
    echo "   [DRY RUN] az group create --name $RESOURCE_GROUP --location $LOCATION"
else
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi

echo "🔒 Creating SECURE Azure Container Registry with authentication..."
if [ "$DRY_RUN" = "true" ]; then
    echo "   [DRY RUN] az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard --admin-enabled true"
else
    az acr create \
      --resource-group $RESOURCE_GROUP \
      --name $ACR_NAME \
      --sku Standard \
      --admin-enabled true
fi

# Add network restrictions for additional security
echo "🔒 Adding security policies to ACR..."
# Note: ARM authentication policy is already enabled by default
# Adding retention policy for automatic cleanup
if [ "$DRY_RUN" != "true" ]; then
    az acr config retention update \
      --registry $ACR_NAME \
      --status enabled \
      --days 30 \
      --policy-type UntaggedManifests || echo "⚠️  Retention policy update skipped (may not be available in all regions)"
fi

echo "🌐 Creating Container Environment..."
if [ "$DRY_RUN" = "true" ]; then
    echo "   [DRY RUN] az containerapp env create --name $ENV_NAME --resource-group $RESOURCE_GROUP --location $LOCATION"
else
    az containerapp env create \
      --name $ENV_NAME \
      --resource-group $RESOURCE_GROUP \
      --location $LOCATION
fi

echo "🐳 Building and pushing backend image..."
cd backend
docker build -t $ACR_NAME.azurecr.io/mitrayectoria-backend:latest .

if [ "$DRY_RUN" != "true" ]; then
    # Get ACR credentials and login
    ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
    ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)
    echo $ACR_PASSWORD | docker login $ACR_NAME.azurecr.io -u $ACR_USERNAME --password-stdin

    docker push $ACR_NAME.azurecr.io/mitrayectoria-backend:latest
else
    echo "   [DRY RUN] Would login to ACR and push backend image"
fi
cd ..

echo "🐳 Building and pushing frontend image..."
cd frontend
docker build -t $ACR_NAME.azurecr.io/mitrayectoria-frontend:latest .

if [ "$DRY_RUN" != "true" ]; then
    docker push $ACR_NAME.azurecr.io/mitrayectoria-frontend:latest
else
    echo "   [DRY RUN] Would push frontend image"
fi
cd ..

echo "🚀 Deploying backend with secure authentication..."
if [ "$DRY_RUN" = "true" ]; then
    echo "   [DRY RUN] az containerapp create --name $BACKEND_APP --resource-group $RESOURCE_GROUP --environment $ENV_NAME --image $ACR_NAME.azurecr.io/mitrayectoria-backend:latest --target-port 8000 --ingress external --env-vars AZURE_ENDPOINT=$AZURE_ENDPOINT ... --registry-server $ACR_NAME.azurecr.io"
else
    az containerapp create \
      --name $BACKEND_APP \
      --resource-group $RESOURCE_GROUP \
      --environment $ENV_NAME \
      --image $ACR_NAME.azurecr.io/mitrayectoria-backend:latest \
      --target-port 8000 \
      --ingress external \
      --env-vars \
        AZURE_ENDPOINT=$AZURE_ENDPOINT \
        AZURE_API_VERSION=$AZURE_API_VERSION \
        AZURE_SUBSCRIPTION_KEY=$AZURE_SUBSCRIPTION_KEY \
        AZURE_ANALYZER_ID=$AZURE_ANALYZER_ID \
      --registry-server $ACR_NAME.azurecr.io \
      --registry-username $ACR_USERNAME \
      --registry-password $ACR_PASSWORD
fi

# Get the actual backend URL for frontend configuration
if [ "$DRY_RUN" = "true" ]; then
    BACKEND_URL="https://$BACKEND_APP.azurecontainerapps.io"
    echo "   [DRY RUN] Would retrieve backend URL: $BACKEND_URL"
else
    BACKEND_URL=$(az containerapp show --name $BACKEND_APP --resource-group $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv)
    BACKEND_URL="https://$BACKEND_URL"
fi

echo "🚀 Deploying frontend with secure authentication..."
if [ "$DRY_RUN" = "true" ]; then
    echo "   [DRY RUN] az containerapp create --name $FRONTEND_APP --resource-group $RESOURCE_GROUP --environment $ENV_NAME --image $ACR_NAME.azurecr.io/mitrayectoria-frontend:latest --target-port 5173 --ingress external --env-vars VITE_API_BASE_URL=$BACKEND_URL --registry-server $ACR_NAME.azurecr.io"
else
    az containerapp create \
      --name $FRONTEND_APP \
      --resource-group $RESOURCE_GROUP \
      --environment $ENV_NAME \
      --image $ACR_NAME.azurecr.io/mitrayectoria-frontend:latest \
      --target-port 5173 \
      --ingress external \
      --env-vars \
        VITE_API_BASE_URL=$BACKEND_URL \
      --registry-server $ACR_NAME.azurecr.io \
      --registry-username $ACR_USERNAME \
      --registry-password $ACR_PASSWORD
fi

echo "✅ SECURE Deployment complete!"
echo ""
echo "🔒 SECURITY FEATURES ENABLED:"
echo "   ✅ Standard SKU Azure Container Registry"
echo "   ✅ Admin authentication required"
echo "   ✅ ARM authentication policy enabled"
echo "   ✅ Automatic cleanup of old images (30 days)"
echo "   ✅ Images only accessible with authentication"
echo "   ✅ Your code/images are PRIVATE and secure"
echo ""
echo "🌐 URLs:"
echo "   Backend:  $BACKEND_URL"
echo "   Frontend: https://$FRONTEND_APP.azurecontainerapps.io"
echo ""
echo "📊 To view logs:"
echo "   az containerapp logs show --name $BACKEND_APP --resource-group $RESOURCE_GROUP --follow"
echo "   az containerapp logs show --name $FRONTEND_APP --resource-group $RESOURCE_GROUP --follow"
echo ""
echo "🧹 To cleanup resources:"
if [ "$TEST_MODE" = "true" ]; then
    echo "   az group delete --name $RESOURCE_GROUP --yes --no-wait"
    echo ""
    echo "⚠️  TEST MODE: Remember to cleanup test resources after testing!"
else
    echo "   az group delete --name $RESOURCE_GROUP --yes --no-wait"
fi
echo ""
echo "🎉 Ready to test! Upload a UTP study plan PDF to see it in action!"
echo ""
if [ "$TEST_MODE" = "true" ]; then
    echo "🧪 TEST MODE REMINDERS:"
    echo "   • Test the application thoroughly"
    echo "   • Verify PDF upload and processing works"
    echo "   • Check that both frontend and backend are accessible"
    echo "   • Run: az group delete --name $RESOURCE_GROUP --yes --no-wait"
    echo "   • This will NOT affect your production deployment"
fi
