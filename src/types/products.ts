/**
 * Product type definitions
 * Used by ProductShowcase and product data files
 */

export interface ProductStats {
  value: string
  label: string
}

/**
 * Showcase display mode for product cards.
 * - 'screenshot': Display a product screenshot image (with code fallback)
 * - 'code': Display a CodeShowcase code block
 * - 'features': Display a feature highlights list
 */
export type ProductShowcaseType = 'screenshot' | 'code' | 'features'

/**
 * Product showcase area configuration.
 * Defines what appears in the visual demo area of each product card.
 */
export interface ProductShowcase {
  /** Display type for the showcase area */
  type: ProductShowcaseType
  /** Screenshot image source path (only for type='screenshot') */
  screenshotSrc?: string
  /** Alt text for screenshot image (only for type='screenshot') */
  screenshotAlt?: string
  /** Code content for CodeShowcase fallback or primary code display */
  fallbackCode?: string
  /** Language for CodeShowcase syntax highlighting */
  fallbackLanguage?: string
  /** ARIA label for CodeShowcase */
  fallbackAriaLabel?: string
  /** Feature highlights list (only for type='features') */
  fallbackFeatures?: string[]
}

export interface Product {
  id: string
  name: string
  tagline: string
  description: string
  useCase: string
  url: string
  /** Optional docs URL linking to docs.lurus.cn product section */
  docsUrl?: string
  icon: string
  color: string
  bgColor: string
  features: string[]
  stats: ProductStats
  /** Infrastructure layer ('infra') or application product ('app') */
  layer: 'infra' | 'app'
  /** Optional showcase area configuration for visual demo in card */
  showcase?: ProductShowcase
}

export type ProductIconPaths = Record<string, string>
