/**
 * API Health Check type definitions
 * Used by useApiHealth composable
 */

/**
 * Three-state health status following ADR-010 degradation pattern:
 * loading -> ready | unavailable
 */
export type ApiHealthStatus = 'loading' | 'ready' | 'unavailable'

/**
 * Configuration for API health check
 */
export interface ApiHealthConfig {
  /** Endpoint to check (lightweight, no auth required) */
  healthEndpoint: string
  /** Request timeout in milliseconds */
  timeoutMs: number
  /** Maximum retry attempts on failure */
  maxRetries: number
}
