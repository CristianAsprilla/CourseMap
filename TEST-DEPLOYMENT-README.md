# 🚧 Mi Trayectoria UTP - Test Deployment Script (WORK IN PROGRESS)

> **⚠️ STATUS: NOT COMPLETE - Requires Improvements**

This document outlines the current state of the test deployment script and identifies areas that nee3. Verify Azure Cognitive Services configuration
4. Check Azure CLI authentication status

---

## 📋 Current Status

### ✅ **What's Working**

- Basic script structure and menu system
- Local Docker build testing
- Dry-run mode with Azure Cognitive Services validation
- Test environment mode (calls deploy-azure.sh with TEST_MODE=true)
- Context-aware cleanup options
- Force cleanup functionality
- Resource tracking and session management
- **Clean script organization** - removed redundant test-local.sh

### ❌ **Known Issues & Areas Needing Improvement**

#### **1. Environment Variable Handling**

- **Issue**: Azure Cognitive Services variables are not properly exported to subprocess
- **Current Workaround**: Variables must be set in parent shell before running script
- **Needed**: Better environment variable management and validation

#### **2. Error Handling**

- **Issue**: Limited error handling in some functions
- **Current State**: Basic error handling exists but could be more robust
- **Needed**: Comprehensive error handling with proper rollback mechanisms

#### **3. Resource State Tracking**

- **Issue**: Session-based resource tracking may not be reliable across different terminal sessions
- **Current State**: Uses global variables that reset on script restart
- **Needed**: Persistent state tracking or better session management

#### **4. Azure CLI Dependency**

- **Issue**: Assumes Azure CLI is always available and authenticated
- **Current State**: Basic checks exist but could be more thorough
- **Needed**: Better Azure CLI validation and authentication handling

#### **5. Docker Image Management**

- **Issue**: Docker cleanup may fail silently in some cases
- **Current State**: Basic cleanup with error suppression
- **Needed**: More robust Docker image management and cleanup

#### **6. Test Resource Conflicts**

- **Issue**: No mechanism to handle multiple users testing simultaneously
- **Current State**: Uses fixed test resource names
- **Needed**: User-specific or randomized test resource names

#### **7. Logging and Debugging**

- **Issue**: Limited logging and debugging capabilities
- **Current State**: Basic echo statements
- **Needed**: Structured logging and debug modes

#### **8. Configuration Management**

- **Issue**: Hard-coded test resource names and locations
- **Current State**: Fixed values in script
- **Needed**: Configurable test parameters

## 🎯 **Script Overview**

The `test-deployment.sh` script provides multiple testing modes for the Mi Trayectoria UTP application:

### **Available Modes**

1. **🏠 Local Testing** - Test Docker builds without Azure costs
2. **🔍 Dry Run** - Validate deployment configuration without creating resources
3. **🧪 Test Environment** - Full deployment to separate test resources
4. **📋 Step-by-Step** - Interactive testing guide
5. **🧹 Cleanup** - Remove created test resources
6. **💥 Force Cleanup** - Remove existing test resources

### **Key Features**

- **Safe Testing**: Multiple testing approaches without affecting production
- **Resource Tracking**: Tracks what gets created during testing sessions
- **Context-Aware Cleanup**: Offers appropriate cleanup options based on what was tested
- **Azure Integration**: Uses same deployment logic as production script
- **Environment Validation**: Checks Azure Cognitive Services configuration

## 🚀 **Usage**

```bash
# Set Azure Cognitive Services environment variables
export AZURE_ENDPOINT='https://your-resource.cognitiveservices.azure.com'
export AZURE_SUBSCRIPTION_KEY='your-subscription-key'
export AZURE_ANALYZER_ID='your-analyzer-id'

# Run different test modes
./test-deployment.sh local        # Test Docker builds locally
./test-deployment.sh dry-run      # Validate configuration
./test-deployment.sh test-env     # Deploy to test environment
./test-deployment.sh cleanup      # Clean up session resources
./test-deployment.sh force-cleanup # Clean existing test resources
```

## 🔧 **Architecture**

### **Script Structure**

```text
test-deployment.sh
├── Configuration Section
│   ├── Test resource names
│   ├── Azure Cognitive Services config
│   └── Session tracking variables
├── Core Functions
│   ├── check_azure_cli()
│   ├── check_azure_cognitive_services()
│   ├── cleanup_*() functions
│   └── show_*() functions
├── Testing Modes
│   ├── local_testing()
│   ├── dry_run_testing()
│   ├── test_environment()
│   └── step_by_step_testing()
└── Main Menu & Dispatcher
```

### **Integration with Production**

- Calls `deploy-azure.sh` with `TEST_MODE=true`
- Uses identical Azure Cognitive Services configuration
- Same security features and deployment logic
- Separate test resource names to avoid conflicts

## 📝 **Planned Improvements**

### **High Priority**

1. **Environment Variable Management**
   - Fix export issues to subprocess
   - Add configuration file support
   - Better validation and error messages

2. **Enhanced Error Handling**
   - Add rollback mechanisms
   - Better error reporting
   - Graceful failure recovery

3. **Resource Management**
   - User-specific test resources
   - Better conflict detection
   - Resource usage monitoring

### **Medium Priority**

1. **Logging & Debugging**
   - Structured logging
   - Debug modes
   - Execution tracing

2. **Configuration Flexibility**
   - Configurable test parameters
   - Environment-specific settings
   - Custom resource naming

### **Low Priority**

1. **User Experience**
   - Progress indicators
   - Better prompts and messages
   - Interactive help system

2. **Testing Features**
   - Automated test scenarios
   - Performance testing
   - Integration testing

## 🐛 **Current Workarounds**

### **Environment Variables**

```bash
# Must set variables in parent shell before running script
export AZURE_ENDPOINT='...'
export AZURE_SUBSCRIPTION_KEY='...'
export AZURE_ANALYZER_ID='...'
```

### **Resource Conflicts**

- Use force-cleanup before testing if conflicts occur
- Manually delete test resources if needed

### **Error Recovery**

- Use cleanup options if deployment fails
- Check Azure portal for stuck resources

## 📊 **Testing Checklist**

- [ ] Local Docker builds work correctly
- [ ] Dry-run mode validates configuration
- [ ] Test environment deploys successfully
- [ ] Cleanup removes all created resources
- [ ] No conflicts with production resources
- [ ] Azure Cognitive Services integration works
- [ ] Error handling is robust
- [ ] Session tracking is reliable

## 🎯 **Next Steps**

1. **Fix Environment Variable Export Issues** (High Priority)
2. **Improve Error Handling** (High Priority)
3. **Add Better Resource Conflict Management** (Medium Priority)
4. **Implement Structured Logging** (Medium Priority)
5. **Add Configuration File Support** (Low Priority)

## 📞 **Getting Help**

If you encounter issues with the test script:

1. Check this documentation first
2. Use the force-cleanup option if resources are stuck
3. Verify Azure Cognitive Services configuration
4. Check Azure CLI authentication status

---

**⚠️ Remember**: This script is a work-in-progress. Use with caution and always test cleanup functionality after use.
