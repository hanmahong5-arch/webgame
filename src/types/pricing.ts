/**
 * Pricing page type definitions
 */

export type BillingCycle = 'monthly' | 'yearly'

export type AudienceTierCode = 'personal' | 'team' | 'platform'

export interface AudienceTier {
  code: AudienceTierCode
  name: string
  tagline: string
  icon: string
  highlight?: boolean
}

export type ProductPricingStatus = 'available' | 'coming_soon'

export interface ProductPricing {
  id: string
  name: string
  description: string
  monthlyPrice: number | null
  yearlyPrice: number | null
  unit: string
  features: string[]
  status: ProductPricingStatus
  popular?: boolean
}

export interface ComparisonFeature {
  name: string
  personal: string | boolean
  team: string | boolean
  platform: string | boolean
}
