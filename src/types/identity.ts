/**
 * Identity Overview Types
 *
 * TypeScript interfaces mirroring the lurus-platform
 * GET /api/v1/account/me/overview response schema.
 */

export interface AccountSummary {
  id: number
  lurus_id: string
  display_name: string
  avatar_url: string
}

export interface VIPSummary {
  level: number
  level_name: string
  level_en: string
  points: number
  level_expires_at: string | null
}

export interface WalletSummary {
  balance: number
  frozen: number
}

export interface SubscriptionSummary {
  product_id: string
  plan_code: string
  status: string
  expires_at: string | null
  auto_renew: boolean
}

export interface AccountOverview {
  account: AccountSummary
  vip: VIPSummary
  wallet: WalletSummary
  subscription: SubscriptionSummary | null
  topup_url: string
}
