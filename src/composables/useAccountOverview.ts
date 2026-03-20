/**
 * Account Overview Composable
 *
 * Fetches aggregated identity overview (VIP, Lubell wallet, subscription)
 * directly from lurus-platform public API using the Zitadel access_token.
 * Errors are silently swallowed — this is a non-critical enhancement.
 * Uses AbortController to cancel stale requests on rapid login/logout toggling.
 */

import { ref, watch } from 'vue'
import type { AccountOverview } from '../types/identity'
import { useAuth } from './useAuth'
import { IDENTITY_URL } from '../config/oidc'

const PRODUCT_ID = 'lurus-www'

export function useAccountOverview() {
  const { isLoggedIn, getAccessToken } = useAuth()
  const overview = ref<AccountOverview | null>(null)
  const loading = ref(false)

  let activeController: AbortController | null = null

  async function fetchOverview(): Promise<void> {
    const token = getAccessToken()
    if (!token) {
      overview.value = null
      return
    }

    // Cancel any previous in-flight request
    activeController?.abort()
    const controller = new AbortController()
    activeController = controller

    loading.value = true
    try {
      const res = await fetch(
        `${IDENTITY_URL}/api/v1/account/me/overview?product_id=${PRODUCT_ID}`,
        {
          headers: { Authorization: `Bearer ${token}` },
          signal: controller.signal,
        },
      )
      if (!res.ok) return
      overview.value = (await res.json()) as AccountOverview
    } catch (err) {
      // Silently ignore aborted requests and other errors (non-critical)
      if (err instanceof DOMException && err.name === 'AbortError') return
    } finally {
      if (activeController === controller) {
        loading.value = false
      }
    }
  }

  // Fetch on login state change; use onCleanup (Vue 3.5) to cancel on re-trigger
  watch(
    isLoggedIn,
    (loggedIn, _old, onCleanup) => {
      if (loggedIn) {
        void fetchOverview()
        onCleanup(() => {
          activeController?.abort()
          activeController = null
        })
      } else {
        activeController?.abort()
        activeController = null
        overview.value = null
      }
    },
    { immediate: true },
  )

  return { overview, loading }
}
