/**
 * Client-side sliding window rate limiter
 * Uses sessionStorage to persist across page navigations within a session
 */

const STORAGE_KEY = 'lurus_chat_rate_limit'
const DEFAULT_MAX_REQUESTS = 10
const DEFAULT_WINDOW_MS = 60_000

interface RateLimitResult {
  allowed: boolean
  retryAfterMs?: number
}

/**
 * Retrieve timestamps from sessionStorage, pruning expired entries
 */
function getTimestamps(windowMs: number): number[] {
  try {
    const raw = sessionStorage.getItem(STORAGE_KEY)
    if (!raw) return []
    const timestamps: number[] = JSON.parse(raw)
    const cutoff = Date.now() - windowMs
    return timestamps.filter(t => t > cutoff)
  } catch {
    return []
  }
}

/**
 * Persist timestamps to sessionStorage
 */
function setTimestamps(timestamps: number[]): void {
  try {
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify(timestamps))
  } catch {
    // sessionStorage unavailable — silently allow
  }
}

/**
 * Check if a new request is allowed under the sliding window limit.
 * If allowed, records the current timestamp.
 */
export function checkRateLimit(
  maxRequests: number = DEFAULT_MAX_REQUESTS,
  windowMs: number = DEFAULT_WINDOW_MS
): RateLimitResult {
  const timestamps = getTimestamps(windowMs)

  if (timestamps.length >= maxRequests) {
    const oldest = timestamps[0]
    const retryAfterMs = oldest + windowMs - Date.now()
    return { allowed: false, retryAfterMs: Math.max(retryAfterMs, 0) }
  }

  timestamps.push(Date.now())
  setTimestamps(timestamps)
  return { allowed: true }
}
