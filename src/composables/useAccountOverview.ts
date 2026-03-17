/**
 * Account Overview Composable
 *
 * Fetches aggregated identity overview (VIP, Lubell wallet, subscription)
 * directly from lurus-platform public API using the Zitadel access_token.
 * Errors are silently swallowed — this is a non-critical enhancement.
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

  async function fetchOverview(): Promise<void> {
    const token = getAccessToken()
    if (!token) {
      overview.value = null
      return
    }

    loading.value = true
    try {
      const res = await fetch(
        `${IDENTITY_URL}/api/v1/account/me/overview?product_id=${PRODUCT_ID}`,
        { headers: { Authorization: `Bearer ${token}` } },
      )
      if (!res.ok) return
      overview.value = (await res.json()) as AccountOverview
    } catch {
      // Non-critical — silently degrade
    } finally {
      loading.value = false
    }
  }

  // Fetch on login state change
  watch(
    isLoggedIn,
    (loggedIn) => {
      if (loggedIn) {
        void fetchOverview()
      } else {
        overview.value = null
      }
    },
    { immediate: true },
  )

  return { overview, loading }
}
