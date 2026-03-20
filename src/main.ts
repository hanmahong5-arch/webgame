import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import './styles/main.css'
import { getExternalRedirect } from './data/externalRoutes'

// Check for external redirects before Vue app loads
const path = window.location.pathname
const redirectUrl = getExternalRedirect(path)

if (redirectUrl) {
  window.location.href = redirectUrl
} else {
  // Mount Vue app for internal routes
  const app = createApp(App)
  app.use(router)

  // Global error handler — prevents silent crashes during navigation/render
  app.config.errorHandler = (err, _instance, info) => {
    console.error(`[Vue Error] ${info}:`, err)
  }

  app.mount('#app')
}
