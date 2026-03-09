/// <reference types="vite/client" />

/**
 * Vue Single File Component module declaration
 */
declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<Record<string, unknown>, Record<string, unknown>, unknown>
  export default component
}

/**
 * Vite environment variables type definitions
 * @see https://vite.dev/guide/env-and-mode.html#intellisense-for-typescript
 */
interface ImportMetaEnv {
  /** API base URL */
  readonly VITE_API_URL: string
  /** Enable AI Chat feature */
  readonly VITE_CHAT_ENABLED: string
  /** Enable analytics tracking */
  readonly VITE_ANALYTICS_ENABLED: string
  /** ICP registration number for footer display */
  readonly VITE_ICP_NUMBER: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
