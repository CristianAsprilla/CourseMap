import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
  },
  preview: {
    allowedHosts: [
      'coursemap-frontend.kindmeadow-14f25848.westus.azurecontainerapps.io',
      'localhost',
      '127.0.0.1'
    ],
  },
})


