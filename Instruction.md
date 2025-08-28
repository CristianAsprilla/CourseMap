# Instructions to Run the Backend Server

Follow these steps to properly run the backend server:

## Prerequisites
1. Ensure you have `uv` installed. If not, install it by following the [uv documentation](https://docs.astral.sh/uv/).
2. Install the required dependencies by running:
   ```bash
   uv add -r backend/requirements.txt
   ```

## Running the Server
1. Navigate to the project root directory:
   ```bash
   cd /home/cristian/code/mitrayectoriautp-working
   ```

2. Set the `PYTHONPATH` environment variable to include the `backend` directory and run the server using the following command:
   ```bash
   PYTHONPATH=backend uv run -- python -m uvicorn backend.main:app --reload
   ```

   - This ensures that the `backend` directory is included in the module search path.
   - The `--reload` flag enables automatic reloading of the server when code changes are detected.

3. The server will start and be accessible at:
   ```
   http://127.0.0.1:8000
   ```

## Environment Configuration

Create a `.env` file in the project root directory with the following variables:

```env
AZURE_ENDPOINT=https://your-resource.cognitiveservices.azure.com
AZURE_API_VERSION=2025-05-01-preview
AZURE_SUBSCRIPTION_KEY=your-subscription-key
AZURE_ANALYZER_ID=Extract-Table
```

**Important**: The `.env` file should be in the project root (same directory as `docker-compose.yml`), not in the `backend/` directory. This allows Docker Compose to properly load the environment variables.

You can copy the provided `.env.example` file and fill in your actual values:

```bash
cp .env.example .env
# Then edit .env with your actual Azure credentials
```

## Troubleshooting

- If you encounter a `ModuleNotFoundError` for any module, ensure the `PYTHONPATH` is correctly set.
- Verify that all required dependencies are installed.

## 🟢 Cloud Deployment Status

**Status**: ✅ **FULLY FUNCTIONAL** - Successfully deployed to Azure!

### Live Application URLs

- **Frontend**: <https://mitrayectoria-frontend.kindmeadow-14f25848.westus.azurecontainerapps.io>
- **Backend API**: <https://mitrayectoria-backend.kindmeadow-14f25848.westus.azurecontainerapps.io>
- **API Documentation**: <https://mitrayectoria-backend.kindmeadow-14f25848.westus.azurecontainerapps.io/docs>

### Testing the Cloud Deployment

1. **Access the live application**:
   Open <https://mitrayectoria-frontend.kindmeadow-14f25848.westus.azurecontainerapps.io>

2. **Test PDF upload**:
   - Upload a UTP study plan PDF
   - The application should process it successfully
   - You should see the extracted course information displayed

3. **Check backend health**:
   Visit <https://mitrayectoria-backend.kindmeadow-14f25848.westus.azurecontainerapps.io/docs>

4. **Monitor logs** (if you have Azure CLI access):

   ```bash
   az containerapp logs show --name mitrayectoria-backend --resource-group mitrayectoria-rg --follow
   ```

### Deployment Architecture

```text
┌─────────────────┐    ┌─────────────────┐
│   Azure         │    │   Azure         │
│ Container Apps  │    │ Container Apps  │
│   (Frontend)    │◄───┤   (Backend)     │
│                 │    │                 │
│ React + Vite    │    │ FastAPI + Python│
│ Port: 5173      │    │ Port: 8000      │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
          ┌──────────▼───────────┐
          │   Azure Cognitive    │
          │   Services           │
          │   (PDF Processing)   │
          └──────────┬───────────┘
                     │
          ┌──────────▼───────────┐
          │   Azure Container    │
          │   Registry          │
          │   (Private Images)   │
          └──────────────────────┘
```

### Key Features Working in Cloud

- ✅ **PDF Upload & Processing**: Azure Cognitive Services extracts data from UTP study plans
- ✅ **Frontend-Backend Communication**: Secure API communication with CORS configured
- ✅ **Database Operations**: SQLite database for storing processed documents
- ✅ **Error Handling**: Robust error handling for PDF processing edge cases
- ✅ **Security**: Private container registry with authentication required

### Recent Fixes Applied

1. **Fixed PDF Processing Crash**: Added null checks in `backend/utils/cleaner.py` to handle cases where Azure Cognitive Services returns `None` values
2. **Fixed Environment Variables**: Updated deployment script to dynamically retrieve backend URL
3. **Added Debug Logging**: Enhanced frontend with console logging for troubleshooting
4. **Improved CORS Configuration**: Ensured proper cross-origin request handling

### Performance & Cost

- **Response Time**: ~2-5 seconds for PDF processing
- **Cost**: ~$15-60/month depending on usage
- **Scalability**: Auto-scales based on demand

Feel free to reach out if you encounter any issues!
