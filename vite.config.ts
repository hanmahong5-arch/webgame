import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath } from 'node:url'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    port: 3001,
    proxy: {
      '/api': {
        target: 'https://api.lurus.cn',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    minify: 'esbuild',
    rollupOptions: {
      output: {
        manualChunks(id) {
          // Vendor chunk: Vue core libraries
          if (id.includes('node_modules/vue') || id.includes('node_modules/vue-router')) {
            return 'vue'
          }
          // Chat chunk: all Chat components and related composables (ADR-013)
          if (
            id.includes('/components/Chat/') ||
            id.includes('/composables/useAIChat') ||
            id.includes('/composables/useChatApi') ||
            id.includes('/composables/useChatPersist') ||
            id.includes('/data/chatModels')
          ) {
            return 'chat'
          }
          // Releases chunk: markdown rendering + release pages
          if (id.includes('marked') || id.includes('/pages/Releases')) {
            return 'releases'
          }
        },
      },
    },
  },
})
