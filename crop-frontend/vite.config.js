import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    port: 5173,
    proxy: {
      // Proxy /api calls to your Render backend while running locally
      '/api': {
        target: 'https://agri-ai-7fnp.onrender.com',
        changeOrigin: true,
        secure: true,
      },
    },
  },
  build: {
    // For SPA routing on Vercel
    rollupOptions: {
      output: {
        manualChunks: undefined
      }
    }
  }
})