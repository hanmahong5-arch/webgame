/**
 * Chat API composable
 * Handles API calls with timeout, retry, error handling, and SSE streaming
 */

import type { ChatApiResponse, ChatStreamDelta } from '../types/chat'
import { TimeoutError, NetworkError } from '../types/chat'

import { useAuth } from './useAuth'

const API_BASE = import.meta.env.VITE_API_URL || '/api'
const API_URL = `${API_BASE}/v1/chat/completions`
const DEMO_API_KEY = import.meta.env.VITE_DEMO_API_KEY || ''
const TIMEOUT_MS = 30000
const MAX_RETRIES = 3

/**
 * Get the appropriate API key: session token for logged-in users, demo key for guests
 */
function getApiKey(): string {
  const { getAccessToken } = useAuth()
  return getAccessToken() || DEMO_API_KEY
}

/**
 * Get human-readable error message based on error type and status code
 */
export const getErrorMessage = (error: unknown, statusCode?: number): string => {
  if (error instanceof DOMException && error.name === 'AbortError') {
    return '请求超时(30秒)，请检查网络后重试'
  }
  if (error instanceof TypeError && error.message.includes('fetch')) {
    return '网络连接失败，请检查网络'
  }
  if (error instanceof TimeoutError) {
    return error.message
  }
  if (error instanceof NetworkError) {
    return error.message
  }
  if (statusCode === 401) return '认证失败，请刷新页面'
  if (statusCode === 429) return '请求过于频繁，请稍后再试'
  if (statusCode === 500) return '服务器繁忙，请稍后重试'
  if (statusCode && statusCode >= 500) return '服务器错误，请稍后重试'
  return '未知错误，请稍后再试'
}

/**
 * Get error code from error for tracking
 */
export const getErrorCode = (error: unknown, statusCode?: number): string => {
  if (error instanceof DOMException && error.name === 'AbortError') {
    return 'TIMEOUT'
  }
  if (error instanceof TypeError && error.message.includes('fetch')) {
    return 'NETWORK_ERROR'
  }
  if (statusCode) {
    return "HTTP_" + statusCode
  }
  return 'UNKNOWN'
}

/**
 * Parse a single SSE chunk line and extract content delta.
 * Returns the content string if present, or null for non-content lines.
 */
export const parseSSEChunk = (line: string): string | null => {
  if (!line || !line.startsWith('data: ')) return null

  const data = line.slice(6).trim()
  if (!data || data === '[DONE]') return null

  try {
    const parsed: ChatStreamDelta = JSON.parse(data)
    const delta = parsed.choices?.[0]?.delta
    if (delta?.content) return delta.content
    return null
  } catch {
    return null
  }
}

/**
 * Validate API key is available before making requests
 */
function assertApiKey(): void {
  const key = getApiKey()
  if (!key) {
    throw new NetworkError('未配置 API Key，请登录或联系管理员')
  }
}

/**
 * Send message with timeout using AbortController (non-streaming)
 */
const sendWithTimeout = async (
  messages: Array<{ role: string; content: string }>,
  model: string
): Promise<ChatApiResponse> => {
  assertApiKey()

  const controller = new AbortController()
  const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS)

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + getApiKey()
      },
      body: JSON.stringify({
        model,
        messages,
        stream: false
      }),
      signal: controller.signal
    })

    if (!response.ok) {
      const errorMsg = getErrorMessage(null, response.status)
      throw new NetworkError(errorMsg)
    }

    return await response.json()
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw new TimeoutError('请求超时(30秒)，请检查网络后重试')
    }
    throw error
  } finally {
    clearTimeout(timeoutId)
  }
}

/**
 * Send message with exponential backoff retry (non-streaming)
 * Retry delays: 1s -> 2s -> 4s (max 3 attempts)
 */
export const sendWithRetry = async (
  messages: Array<{ role: string; content: string }>,
  model: string,
  maxRetries: number = MAX_RETRIES
): Promise<ChatApiResponse> => {
  let lastError: unknown

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await sendWithTimeout(messages, model)
    } catch (error) {
      lastError = error

      // Don't retry on specific errors
      if (error instanceof NetworkError) {
        const msg = error.message
        if (msg.includes('认证失败') || msg.includes('请求过于频繁')) {
          throw error
        }
      }

      // Last attempt, throw the error
      if (attempt === maxRetries - 1) {
        throw error
      }

      // Exponential backoff: 1s, 2s, 4s...
      const delay = Math.min(1000 * Math.pow(2, attempt), 8000)
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }

  throw lastError
}

/**
 * Send message with SSE streaming.
 * Calls onToken callback for each content token received.
 * Uses AbortController for 30s timeout.
 */
export const sendStreamMessage = async (
  messages: Array<{ role: string; content: string }>,
  model: string,
  onToken: (token: string) => void,
  abortSignal?: AbortSignal
): Promise<void> => {
  assertApiKey()

  const controller = new AbortController()
  const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS)

  // Link external abort signal if provided
  if (abortSignal) {
    abortSignal.addEventListener('abort', () => controller.abort())
  }

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + getApiKey()
      },
      body: JSON.stringify({
        model,
        messages,
        stream: true
      }),
      signal: controller.signal
    })

    if (!response.ok) {
      const errorMsg = getErrorMessage(null, response.status)
      throw new NetworkError(errorMsg)
    }

    if (!response.body) {
      throw new NetworkError('服务器未返回流式响应')
    }

    const reader = response.body.getReader()
    const decoder = new TextDecoder()
    let buffer = ''

    while (true) {
      const { done, value } = await reader.read()
      if (done) break

      buffer += decoder.decode(value, { stream: true })

      // Process complete lines from buffer
      const lines = buffer.split(String.fromCharCode(10))
      // Keep the last potentially incomplete line in buffer
      buffer = lines.pop() || ''

      for (const line of lines) {
        const trimmed = line.trim()
        if (!trimmed) continue

        const content = parseSSEChunk(trimmed)
        if (content) {
          onToken(content)
        }
      }
    }

    // Process any remaining buffer content
    if (buffer.trim()) {
      const content = parseSSEChunk(buffer.trim())
      if (content) {
        onToken(content)
      }
    }
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw new TimeoutError('请求超时(30秒)，请检查网络后重试')
    }
    throw error
  } finally {
    clearTimeout(timeoutId)
  }
}

export const useChatApi = () => {
  return {
    sendWithRetry,
    sendStreamMessage,
    getErrorMessage,
    getErrorCode
  }
}
