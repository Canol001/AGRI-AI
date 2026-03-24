import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");

  return {
    plugins: [react()],

    server: {
      host: true,
      port: 5173,

      proxy: {
        // During local development
        // /api -> https://agri-ai-7fnp.onrender.com/api
        "/api": {
          target: env.VITE_API_BASE_URL,
          changeOrigin: true,
          secure: true,
        },
      },
    },

    define: {
      // makes env accessible safely
      __API_BASE_URL__: JSON.stringify(env.VITE_API_BASE_URL),
    },

    build: {
      rollupOptions: {
        output: {
          manualChunks: undefined,
        },
      },
    },
  };
});