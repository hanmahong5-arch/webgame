/**
 * Authentication Composable - OIDC PKCE Flow
 * Manages Zitadel OIDC session with Authorization Code + PKCE
 * Uses module-level shared refs (singleton) to prevent state duplication
 */

import { ref, computed } from 'vue'
import type { OIDCTokens, OIDCUserInfo } from '../types/auth'
import { oidcConfig, AUTHORIZE_URL, TOKEN_URL, USERINFO_URL, END_SESSION_URL } from '../config/oidc'
import { generateCodeVerifier, generateCodeChallenge, generateState } from '../utils/pkce'
import { useToast } from './useToast'

// Module-level shared state (singleton across all components)
const tokens = ref<OIDCTokens | null>(null)
const userInfo = ref<OIDCUserInfo | null>(null)
const isLoading = ref(false)
const error = ref<string | null>(null)
let refreshTimer: ReturnType<typeof setTimeout> | null = null

const STORAGE_KEY = 'oidc_tokens'

// Restore tokens from sessionStorage on module load
try {
  const stored = sessionStorage.getItem(STORAGE_KEY)
  if (stored) {
    const parsed: OIDCTokens = JSON.parse(stored)
    if (parsed.expires_at > Date.now()) {
      tokens.value = parsed
    } else {
      sessionStorage.removeItem(STORAGE_KEY)
    }
  }
} catch {
  sessionStorage.removeItem(STORAGE_KEY)
}

function saveTokens(t: OIDCTokens): void {
  tokens.value = t
  try {
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify(t))
  } catch {
    // Storage full or unavailable
  }
}

function clearSession(): void {
  tokens.value = null
  userInfo.value = null
  if (refreshTimer) {
    clearTimeout(refreshTimer)
    refreshTimer = null
  }
  try {
    sessionStorage.removeItem(STORAGE_KEY)
    sessionStorage.removeItem('oidc_code_verifier')
    sessionStorage.removeItem('oidc_state')
    sessionStorage.removeItem('oidc_return_url')
  } catch {
    // Ignore
  }
}

function scheduleRefresh(): void {
  if (!tokens.value?.refresh_token) return

  const expiresAt = tokens.value.expires_at
  // Refresh 60 seconds before expiry
  const refreshIn = Math.max(expiresAt - Date.now() - 60_000, 10_000)

  if (refreshTimer) clearTimeout(refreshTimer)
  refreshTimer = setTimeout(async () => {
    await refreshTokens()
  }, refreshIn)
}

async function refreshTokens(): Promise<void> {
  if (!tokens.value?.refresh_token) return

  try {
    const body = new URLSearchParams({
      grant_type: 'refresh_token',
      client_id: oidcConfig.clientId,
      refresh_token: tokens.value.refresh_token,
    })

    const response = await fetch(TOKEN_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body.toString(),
    })

    if (!response.ok) {
      clearSession()
      notifySessionExpired()
      return
    }

    const data = await response.json()
    const newTokens: OIDCTokens = {
      access_token: data.access_token,
      id_token: data.id_token,
      refresh_token: data.refresh_token || tokens.value.refresh_token,
      token_type: data.token_type,
      expires_in: data.expires_in,
      expires_at: Date.now() + data.expires_in * 1000,
      scope: data.scope,
    }

    saveTokens(newTokens)
    scheduleRefresh()
  } catch {
    clearSession()
    notifySessionExpired()
  }
}

/**
 * Notify user that their session has expired with a re-login action.
 * Only fires when an active session is lost (not on first visit).
 */
function notifySessionExpired(): void {
  const toast = useToast()
  toast.addToast({
    type: 'warning',
    title: '登录已过期',
    message: '请重新登录以继续使用。',
    action: {
      label: '重新登录',
      handler: () => {
        const { login } = useAuth()
        login({ returnUrl: window.location.pathname })
      },
    },
    duration: 0, // persistent until dismissed
  })
}

async function fetchUserInfo(): Promise<void> {
  if (!tokens.value?.access_token) return

  try {
    const response = await fetch(USERINFO_URL, {
      headers: {
        Authorization: `Bearer ${tokens.value.access_token}`,
      },
    })

    if (!response.ok) {
      if (response.status === 401) {
        clearSession()
      }
      return
    }

    userInfo.value = await response.json()
  } catch {
    // Silently fail - user info is non-critical
  }
}

export interface LoginOptions {
  /** Set to 'create' to open Zitadel registration flow */
  prompt?: string
  returnUrl?: string
}

export function useAuth() {
  const isLoggedIn = computed(() => {
    if (!tokens.value) return false
    return tokens.value.expires_at > Date.now()
  })

  /**
   * Start OIDC login flow: build authorize URL and redirect
   */
  async function login(options: LoginOptions = {}): Promise<void> {
    const codeVerifier = generateCodeVerifier()
    const codeChallenge = await generateCodeChallenge(codeVerifier)
    const state = generateState()

    // Save PKCE state for callback
    sessionStorage.setItem('oidc_code_verifier', codeVerifier)
    sessionStorage.setItem('oidc_state', state)
    sessionStorage.setItem('oidc_return_url', options.returnUrl || window.location.pathname)

    const params = new URLSearchParams({
      response_type: 'code',
      client_id: oidcConfig.clientId,
      redirect_uri: oidcConfig.redirectUri,
      scope: oidcConfig.scopes.join(' '),
      state,
      code_challenge: codeChallenge,
      code_challenge_method: 'S256',
    })

    if (options.prompt) {
      params.set('prompt', options.prompt)
    }

    window.location.href = `${AUTHORIZE_URL}?${params.toString()}`
  }

  /**
   * Handle OIDC callback: exchange authorization code for tokens
   */
  async function handleCallback(code: string, state: string): Promise<void> {
    isLoading.value = true
    error.value = null

    try {
      // Verify state
      const savedState = sessionStorage.getItem('oidc_state')
      if (state !== savedState) {
        throw new Error('OIDC state 不匹配，可能存在 CSRF 攻击，请重新登录')
      }

      const codeVerifier = sessionStorage.getItem('oidc_code_verifier')
      if (!codeVerifier) {
        throw new Error('缺少 PKCE code_verifier，请重新登录')
      }

      // Exchange code for tokens
      const body = new URLSearchParams({
        grant_type: 'authorization_code',
        client_id: oidcConfig.clientId,
        code,
        redirect_uri: oidcConfig.redirectUri,
        code_verifier: codeVerifier,
      })

      const response = await fetch(TOKEN_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: body.toString(),
      })

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}))
        throw new Error(errorData.error_description || `Token 交换失败 (HTTP ${response.status})`)
      }

      const data = await response.json()
      const newTokens: OIDCTokens = {
        access_token: data.access_token,
        id_token: data.id_token,
        refresh_token: data.refresh_token,
        token_type: data.token_type,
        expires_in: data.expires_in,
        expires_at: Date.now() + data.expires_in * 1000,
        scope: data.scope,
      }

      saveTokens(newTokens)
      scheduleRefresh()

      // Fetch user info
      await fetchUserInfo()

      // Cleanup PKCE state
      sessionStorage.removeItem('oidc_code_verifier')
      sessionStorage.removeItem('oidc_state')
    } catch (err) {
      error.value = err instanceof Error ? err.message : '登录失败'
      clearSession()
      throw err
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Logout: redirect to Zitadel end_session endpoint
   */
  function logout(): void {
    const idToken = tokens.value?.id_token
    clearSession()

    const params = new URLSearchParams({
      post_logout_redirect_uri: oidcConfig.postLogoutRedirectUri,
    })
    if (idToken) {
      params.set('id_token_hint', idToken)
    }

    window.location.href = `${END_SESSION_URL}?${params.toString()}`
  }

  /**
   * Check if current session is valid and fetch user info if needed
   */
  async function checkSession(): Promise<void> {
    if (!tokens.value) return

    if (tokens.value.expires_at <= Date.now()) {
      // Token expired, try refresh
      if (tokens.value.refresh_token) {
        await refreshTokens()
      } else {
        clearSession()
        return
      }
    }

    // Schedule refresh timer
    scheduleRefresh()

    // Fetch user info if not already loaded
    if (!userInfo.value) {
      await fetchUserInfo()
    }
  }

  /**
   * Get access token for API calls
   * Returns null if not authenticated
   */
  function getAccessToken(): string | null {
    if (!tokens.value || tokens.value.expires_at <= Date.now()) {
      return null
    }
    return tokens.value.access_token
  }

  return {
    isLoggedIn,
    userInfo,
    isLoading,
    error,
    login,
    handleCallback,
    logout,
    checkSession,
    getAccessToken,
  }
}
