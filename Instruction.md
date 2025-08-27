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
   cd /home/cristian/code/UTP-Project/mitrayectoriautp
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

## Troubleshooting
- If you encounter a `ModuleNotFoundError` for any module, ensure the `PYTHONPATH` is correctly set.
- Verify that all required dependencies are installed.

Feel free to reach out if you encounter any issues!
