/**
 * Type definitions index
 * Re-exports all types for convenient importing
 */

// Navigation types
export type { NavItem, NavDropdownItem } from './navigation'

// Product types
export type { Product, ProductStats, ProductIconPaths } from './products'

// API health types
export type { ApiHealthStatus, ApiHealthConfig } from './apiHealth'

// Common types
export type {
  AriaProps,
  Stat,
  TrustBadge,
  ExternalRedirectConfig,
  ChatConfig,
} from './common'

// Chat types (existing)
export type {
  MessageStatus,
  MessageRole,
  ChatMessage,
  ChatApiResponse,
  QuickPrompt,
  ModelOption,
  ChatState,
  DemoMessage,
} from './chat'

export { TimeoutError, NetworkError } from './chat'

// Tracking types
export type { TrackEvent, TrackPayload } from './tracking'
