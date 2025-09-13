#!/bin/bash

# Test script for Mi Trayectoria UTP deployment
# This script provides safe testing options without affecting production

echo "🧪 Mi Trayectoria UTP - Deployment Testing Guide"
echo "================================================"
echo ""

# Test resource names - clearly marked as test resources
TEST_RESOURCE_GROUP="coursemap-test-rg"
TEST_LOCATION="westus"
TEST_ACR_NAME="coursemap-test-acr"
TEST_ENV_NAME="coursemap-test-env"
TEST_BACKEND_APP="coursemap-test-backend"
TEST_FRONTEND_APP="coursemap-test-frontend"

# Azure Cognitive Services configuration - SET THESE ENVIRONMENT VARIABLES
# Same as deployment since test-env is a step before real deployment
AZURE_ENDPOINT="${AZURE_ENDPOINT:-}"
AZURE_API_VERSION="${AZURE_API_VERSION:-2024-02-15-preview}"
AZURE_SUBSCRIPTION_KEY="${AZURE_SUBSCRIPTION_KEY:-}"
AZURE_ANALYZER_ID="${AZURE_ANALYZER_ID:-}"

# Track what was created during testing
CREATED_DOCKER_IMAGES=()
CREATED_AZURE_RESOURCES=false

# Function to check Azure CLI installation and login
check_azure_cli() {
    echo "🔍 Checking Azure CLI..."

    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        echo "❌ Azure CLI is not installed."
        echo "Please install Azure CLI from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi

    # Check if user is logged in
    if ! az account show &> /dev/null; then
        echo "❌ You are not logged in to Azure CLI."
        echo "Please run 'az login' to authenticate."
        exit 1
    fi

    echo "✅ Azure CLI is ready!"
}

# Function to check Azure Cognitive Services environment variables
check_azure_cognitive_services() {
    echo "🔍 Checking Azure Cognitive Services configuration..."

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
        echo ""
        echo "💡 Since test-env uses the same Azure Cognitive Services as deployment,"
        echo "   you can use the same values you'll use for production."
        exit 1
    fi

    echo "✅ Azure Cognitive Services configuration is ready!"
}
force_cleanup_existing() {
    echo "🧹 FORCE CLEANUP EXISTING TEST RESOURCES"
    echo "======================================="
    echo ""
    echo "This will forcefully delete any existing test resources with the standard test names:"
    echo "  • Resource Group: $TEST_RESOURCE_GROUP"
    echo "  • Container Apps: $TEST_BACKEND_APP, $TEST_FRONTEND_APP"
    echo "  • Container Registry: $TEST_ACR_NAME"
    echo "  • Container Environment: $TEST_ENV_NAME"
    echo ""

    # Check Azure CLI first
    check_azure_cli

    read -p "⚠️  Are you sure you want to force cleanup existing test resources? (y/N): " confirm_force
    if [[ $confirm_force =~ ^[Yy]$ ]]; then
        cleanup_existing_test_resources
    else
        echo "Force cleanup cancelled."
    fi
}

# Function to cleanup Docker test images
cleanup_docker_images() {
    echo "🧹 CLEANUP DOCKER TEST IMAGES"
    echo "============================"
    echo ""

    if [ ${#CREATED_DOCKER_IMAGES[@]} -eq 0 ]; then
        echo "ℹ️  No Docker test images were created during this session."
        return
    fi

    echo "The following Docker test images were created:"
    for image in "${CREATED_DOCKER_IMAGES[@]}"; do
        echo "  • $image"
    done
    echo ""

    read -p "🗑️  Do you want to remove these Docker test images? (y/N): " confirm_docker_cleanup
    if [[ $confirm_docker_cleanup =~ ^[Yy]$ ]]; then
        echo "Removing Docker test images..."
        for image in "${CREATED_DOCKER_IMAGES[@]}"; do
            echo "Removing $image..."
            docker rmi "$image" 2>/dev/null || echo "⚠️  Could not remove $image (may not exist)"
        done
        echo "✅ Docker test images cleanup complete!"
        CREATED_DOCKER_IMAGES=()  # Clear the array
    else
        echo "Docker cleanup cancelled."
    fi
}

# Function to cleanup existing Azure test resources (regardless of current session)
cleanup_existing_test_resources() {
    echo "🧹 CLEANUP EXISTING AZURE TEST RESOURCES"
    echo "======================================="
    echo ""

    # Check Azure CLI first
    check_azure_cli

    echo "This will delete the following existing test resources:"
    echo "  • Resource Group: $TEST_RESOURCE_GROUP"
    echo "  • Container Apps: $TEST_BACKEND_APP, $TEST_FRONTEND_APP"
    echo "  • Container Registry: $TEST_ACR_NAME"
    echo "  • Container Environment: $TEST_ENV_NAME"
    echo ""

    read -p "⚠️  Are you sure you want to delete these existing test resources? (y/N): " confirm_cleanup
    if [[ $confirm_cleanup =~ ^[Yy]$ ]]; then
        echo "🗑️  Deleting existing test resources..."

        # Check if resource group exists using a more reliable method
        if az group show --name $TEST_RESOURCE_GROUP --output none 2>/dev/null; then
            echo "Deleting resource group $TEST_RESOURCE_GROUP..."
            az group delete --name $TEST_RESOURCE_GROUP --yes --no-wait
            echo "✅ Existing test resources deletion initiated!"
            echo "💡 Note: Resource deletion may take a few minutes to complete."
        else
            echo "ℹ️  Test resource group $TEST_RESOURCE_GROUP does not exist."
        fi
    else
        echo "Cleanup cancelled."
    fi
}

# Function to cleanup Azure test resources
cleanup_azure_resources() {
    echo "🧹 CLEANUP AZURE TEST RESOURCES"
    echo "=============================="
    echo ""

    if [ "$CREATED_AZURE_RESOURCES" = false ]; then
        echo "ℹ️  No Azure test resources were created during this session."
        return
    fi

    # Check Azure CLI first
    check_azure_cli

    echo "This will delete the following test resources:"
    echo "  • Resource Group: $TEST_RESOURCE_GROUP"
    echo "  • Container Apps: $TEST_BACKEND_APP, $TEST_FRONTEND_APP"
    echo "  • Container Registry: $TEST_ACR_NAME"
    echo "  • Container Environment: $TEST_ENV_NAME"
    echo ""

    read -p "⚠️  Are you sure you want to delete these test resources? (y/N): " confirm_cleanup
    if [[ $confirm_cleanup =~ ^[Yy]$ ]]; then
        echo "🗑️  Deleting test resources..."

        # Delete resource group (this will delete all resources within it)
        if az group show --name $TEST_RESOURCE_GROUP --output none 2>/dev/null; then
            echo "Deleting resource group $TEST_RESOURCE_GROUP..."
            az group delete --name $TEST_RESOURCE_GROUP --yes --no-wait
            echo "✅ Test resources deletion initiated!"
            echo "💡 Note: Resource deletion may take a few minutes to complete."
        else
            echo "ℹ️  Test resource group $TEST_RESOURCE_GROUP does not exist."
        fi
        CREATED_AZURE_RESOURCES=false  # Reset flag
    else
        echo "Cleanup cancelled."
    fi
}

# Function to show context-aware cleanup options
show_cleanup_options() {
    local context="$1"
    local something_created=false

    echo ""
    echo "🧹 CLEANUP OPTIONS"
    echo "=================="

    case "$context" in
        "local")
            if [ ${#CREATED_DOCKER_IMAGES[@]} -gt 0 ]; then
                echo "Docker test images were created during local testing."
                cleanup_docker_images
                something_created=true
            else
                echo "ℹ️  No Docker test images were created during local testing."
            fi
            ;;
        "dry-run")
            echo "ℹ️  Dry-run mode doesn't create any resources, so no cleanup is needed."
            ;;
        "test-env")
            if [ "$CREATED_AZURE_RESOURCES" = true ]; then
                echo "Azure test resources were created during test environment deployment."
                cleanup_azure_resources
                something_created=true
            else
                echo "ℹ️  No Azure test resources were created during this session."
            fi
            ;;
        "all")
            local docker_cleaned=false
            local azure_cleaned=false

            if [ ${#CREATED_DOCKER_IMAGES[@]} -gt 0 ]; then
                cleanup_docker_images
                docker_cleaned=true
            fi

            if [ "$CREATED_AZURE_RESOURCES" = true ]; then
                if [ "$docker_cleaned" = true ]; then
                    echo ""
                fi
                cleanup_azure_resources
                azure_cleaned=true
            fi

            if [ "$docker_cleaned" = false ] && [ "$azure_cleaned" = false ]; then
                echo "ℹ️  No test resources were created during this session."
            fi
            ;;
    esac

    if [ "$something_created" = false ] && [ "$context" != "all" ]; then
        echo "ℹ️  Nothing was created during this test, so no cleanup is needed."
    fi
}

# Function to check if test resources exist
check_test_resources() {
    echo "🔍 Checking for existing test resources..."

    # Use a more reliable method to check if resource group exists
    if az group show --name $TEST_RESOURCE_GROUP --output none 2>/dev/null; then
        echo "⚠️  Test resources already exist!"
        echo "   Resource Group: $TEST_RESOURCE_GROUP"
        echo ""
        read -p "Do you want to cleanup existing test resources first? (y/N): " cleanup_first
        if [[ $cleanup_first =~ ^[Yy]$ ]]; then
            cleanup_existing_test_resources
            echo ""
            read -p "Press Enter to continue with fresh deployment..."
        fi
    else
        echo "✅ No existing test resources found."
    fi
}

# Function to show test URLs
show_test_urls() {
    echo ""
    echo "🌐 TEST URLs:"
    echo "============="
    echo ""
    echo "Frontend: https://$TEST_FRONTEND_APP.azurecontainerapps.io"
    echo "Backend:  https://$TEST_BACKEND_APP.azurecontainerapps.io"
    echo "API Docs: https://$TEST_BACKEND_APP.azurecontainerapps.io/docs"
    echo ""
    echo "💡 Test the application:"
    echo "   1. Open the Frontend URL in your browser"
    echo "   2. Upload a UTP study plan PDF"
    echo "   3. Verify the backend processes it correctly"
    echo ""
}

# Function to handle post-deployment options
post_deployment_menu() {
    echo ""
    echo "🎉 Test deployment completed successfully!"
    show_test_urls

    while true; do
        echo "What would you like to do next?"
        echo ""
        echo "1. 🧪 Test the application (opens URLs in browser)"
        echo "2. 📊 View backend logs"
        echo "3. 📊 View frontend logs"
        echo "4. 🧹 Cleanup test resources"
        echo "5. 🔄 Redeploy test environment"
        echo "6. ❌ Exit"
        echo ""

        read -p "Choose an option (1-6): " choice

        case $choice in
            1)
                echo "🌐 Opening test URLs..."
                echo "Frontend: https://$TEST_FRONTEND_APP.azurecontainerapps.io"
                echo "Backend:  https://$TEST_BACKEND_APP.azurecontainerapps.io"
                echo "API Docs: https://$TEST_BACKEND_APP.azurecontainerapps.io/docs"
                ;;
            2)
                echo "📊 Backend logs (press Ctrl+C to stop):"
                az containerapp logs show --name $TEST_BACKEND_APP --resource-group $TEST_RESOURCE_GROUP --follow
                ;;
            3)
                echo "📊 Frontend logs (press Ctrl+C to stop):"
                az containerapp logs show --name $TEST_FRONTEND_APP --resource-group $TEST_RESOURCE_GROUP --follow
                ;;
            4)
                show_cleanup_options "test-env"
                break
                ;;
            5)
                echo "🔄 Redeploying test environment..."
                test_environment_deployment
                ;;
            6)
                echo "❌ Exiting..."
                break
                ;;
            *)
                echo "❌ Invalid option. Please choose 1-6."
                ;;
        esac
        echo ""
    done
}

# Function to handle deployment errors and cleanup
handle_deployment_error() {
    echo ""
    echo "❌ DEPLOYMENT ERROR OCCURRED!"
    echo "=============================="
    echo ""
    echo "An error occurred during deployment. Any resources that were created will be cleaned up."
    echo ""

    read -p "Do you want to cleanup the partially created resources? (Y/n): " cleanup_error
    if [[ ! $cleanup_error =~ ^[Nn]$ ]]; then
        # Check if any resources were actually created and clean them up
        if az group show --name $TEST_RESOURCE_GROUP --output none 2>/dev/null; then
            cleanup_existing_test_resources
        else
            echo "ℹ️  No resources were created, so no cleanup is needed."
        fi
    fi
}

# Function for test environment deployment (internal)
test_environment_deployment() {
    # Check Azure Cognitive Services configuration first
    check_azure_cognitive_services

    # Set test environment variables
    export TEST_MODE=true
    export DRY_RUN=false
    export RESOURCE_GROUP="$TEST_RESOURCE_GROUP"
    export LOCATION="$TEST_LOCATION"
    export ACR_NAME="$TEST_ACR_NAME"
    export ENV_NAME="$TEST_ENV_NAME"
    export BACKEND_APP="$TEST_BACKEND_APP"
    export FRONTEND_APP="$TEST_FRONTEND_APP"

    # Export Azure Cognitive Services configuration
    export AZURE_ENDPOINT="$AZURE_ENDPOINT"
    export AZURE_API_VERSION="$AZURE_API_VERSION"
    export AZURE_SUBSCRIPTION_KEY="$AZURE_SUBSCRIPTION_KEY"
    export AZURE_ANALYZER_ID="$AZURE_ANALYZER_ID"

    # Call the deployment script with error handling
    if ./deploy-azure.sh; then
        CREATED_AZURE_RESOURCES=true  # Mark that resources were created
        post_deployment_menu
    else
        handle_deployment_error
    fi
}

# Function to show test options
show_test_options() {
    echo "Choose a testing approach:"
    echo ""
    echo "1. 🏠 LOCAL TESTING (No Azure costs)"
    echo "   Test Docker builds and basic functionality locally"
    echo ""
    echo "2. 🔍 DRY RUN MODE (No Azure resources created)"
    echo "   See what would be deployed without actually deploying"
    echo ""
    echo "3. 🧪 TEST ENVIRONMENT (Separate resources)"
    echo "   Deploy to test resources that won't affect production"
    echo ""
    echo "4. 📋 STEP-BY-STEP TESTING (Interactive)"
    echo "   Test each component individually"
    echo ""
    echo "5. 🧹 CLEANUP TEST RESOURCES"
    echo "   Delete existing test resources to avoid conflicts"
    echo ""
    echo "6. 💥 FORCE CLEANUP EXISTING RESOURCES"
    echo "   Forcefully delete any existing test resources"
    echo ""
}

# Function for local testing
local_testing() {
    echo "🏠 LOCAL TESTING MODE"
    echo "===================="
    echo ""
    echo "This tests your Docker builds without using Azure:"
    echo ""

    # Reset Docker images array
    CREATED_DOCKER_IMAGES=()

    # Test backend build
    echo "🐳 Testing backend Docker build..."
    cd backend
    if docker build -t coursemap-backend:test .; then
        echo "✅ Backend build successful"
        CREATED_DOCKER_IMAGES+=("coursemap-backend:test")
    else
        echo "❌ Backend build failed"
        cd ..
        return 1
    fi
    cd ..

    # Test frontend build
    echo "🐳 Testing frontend Docker build..."
    cd frontend
    if docker build -t coursemap-frontend:test .; then
        echo "✅ Frontend build successful"
        CREATED_DOCKER_IMAGES+=("coursemap-frontend:test")
    else
        echo "❌ Frontend build failed"
        cd ..
        return 1
    fi
    cd ..

    echo ""
    echo "✅ Local testing complete!"
    echo "💡 Tip: Run the app locally with:"
    echo "   cd backend && PYTHONPATH=backend uv run -- python -m uvicorn backend.main:app --reload"
    echo "   cd frontend && pnpm dev"

    # Show cleanup options for Docker images
    show_cleanup_options "local"
}

# Function for dry run testing
dry_run_testing() {
    echo "🔍 DRY RUN TESTING MODE"
    echo "======================"
    echo ""
    echo "This shows what would be deployed without creating resources:"
    echo ""

    # Check Azure Cognitive Services configuration first
    check_azure_cognitive_services

    # Set test environment variables
    export TEST_MODE=true
    export DRY_RUN=true
    export RESOURCE_GROUP="$TEST_RESOURCE_GROUP"
    export LOCATION="$TEST_LOCATION"
    export ACR_NAME="$TEST_ACR_NAME"
    export ENV_NAME="$TEST_ENV_NAME"
    export BACKEND_APP="$TEST_BACKEND_APP"
    export FRONTEND_APP="$TEST_FRONTEND_APP"

    # Export Azure Cognitive Services configuration
    export AZURE_ENDPOINT="$AZURE_ENDPOINT"
    export AZURE_API_VERSION="$AZURE_API_VERSION"
    export AZURE_SUBSCRIPTION_KEY="$AZURE_SUBSCRIPTION_KEY"
    export AZURE_ANALYZER_ID="$AZURE_ANALYZER_ID"

    # Call the deployment script
    ./deploy-azure.sh

    # Dry-run doesn't create anything, so no cleanup needed
    echo ""
    echo "ℹ️  Dry-run mode doesn't create any resources, so no cleanup is needed."
}

# Function for test environment
test_environment() {
    echo "🧪 TEST ENVIRONMENT MODE"
    echo "======================="
    echo ""
    echo "This creates separate test resources (will incur costs):"
    echo ""
    echo "Test Resources to be created:"
    echo "  • Resource Group: $TEST_RESOURCE_GROUP"
    echo "  • Container Registry: $TEST_ACR_NAME"
    echo "  • Container Environment: $TEST_ENV_NAME"
    echo "  • Backend App: $TEST_BACKEND_APP"
    echo "  • Frontend App: $TEST_FRONTEND_APP"
    echo ""

    # Check for existing resources
    check_test_resources

    read -p "⚠️  This will create real Azure resources. Continue? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        test_environment_deployment
    else
        echo "Test cancelled."
    fi
}

# Function for step-by-step testing
step_by_step_testing() {
    echo "📋 STEP-BY-STEP TESTING MODE"
    echo "==========================="
    echo ""
    echo "Test each component individually:"
    echo ""

    echo "Step 1: Test Docker builds locally"
    read -p "Run local Docker tests? (y/N): " run_local
    if [[ $run_local =~ ^[Yy]$ ]]; then
        local_testing
    fi

    echo ""
    echo "Step 2: Test deployment script in dry-run mode"
    read -p "Run dry-run deployment? (y/N): " run_dry
    if [[ $run_dry =~ ^[Yy]$ ]]; then
        dry_run_testing
    fi

    echo ""
    echo "Step 3: Deploy to test environment"
    read -p "Deploy to test environment? (y/N): " run_test
    if [[ $run_test =~ ^[Yy]$ ]]; then
        test_environment
    fi

    # Show final cleanup options
    echo ""
    echo "🎯 TESTING SESSION COMPLETE"
    echo "==========================="
    show_cleanup_options "all"
}

# Main menu
case "${1:-}" in
    "local")
        local_testing
        ;;
    "dry-run")
        dry_run_testing
        ;;
    "test-env")
        test_environment
        ;;
    "step-by-step")
        step_by_step_testing
        ;;
    "cleanup")
        show_cleanup_options "all"
        ;;
    "force-cleanup")
        force_cleanup_existing
        ;;
    *)
        show_test_options
        echo "Usage:"
        echo "  $0 local         - Test Docker builds locally"
        echo "  $0 dry-run       - Show deployment plan without executing"
        echo "  $0 test-env      - Deploy to test environment"
        echo "  $0 step-by-step  - Interactive testing guide"
        echo "  $0 cleanup       - Show cleanup options for created resources"
        echo "  $0 force-cleanup - Force cleanup existing test resources"
        echo ""
        ;;
esac