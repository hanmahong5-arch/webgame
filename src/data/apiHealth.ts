/**
 * API Health Check Data
 * Centralized configuration for API health detection (ADR-010 three-state degradation)
 */

import type { ApiHealthConfig } from '../types/apiHealth'

/**
 * Health check endpoint configuration.
 * Uses /v1/models (no auth required) with HEAD request for minimal overhead.
 */
export const apiHealthConfig: ApiHealthConfig = {
  healthEndpoint: `${import.meta.env.VITE_API_URL || '/api'}/v1/models`,
  timeoutMs: 5000,
  maxRetries: 1,
}
