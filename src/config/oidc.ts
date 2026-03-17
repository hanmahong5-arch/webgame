/**
 * OIDC Configuration
 * Reads Zitadel OIDC settings from environment variables
 */

import type { OIDCConfig } from '../types/auth'

const ISSUER = import.meta.env.VITE_ZITADEL_ISSUER || 'https://auth.lurus.cn'
const CLIENT_ID = import.meta.env.VITE_ZITADEL_CLIENT_ID || ''
const REDIRECT_URI = import.meta.env.VITE_ZITADEL_REDIRECT_URI || `${window.location.origin}/auth/callback`
const POST_LOGOUT_URI = import.meta.env.VITE_ZITADEL_POST_LOGOUT_URI || window.location.origin

export const oidcConfig: OIDCConfig = {
  issuer: ISSUER,
  clientId: CLIENT_ID,
  redirectUri: REDIRECT_URI,
  postLogoutRedirectUri: POST_LOGOUT_URI,
  scopes: ['openid', 'profile', 'email', 'offline_access'],
}

/** Authorization endpoint */
export const AUTHORIZE_URL = `${ISSUER}/oauth/v2/authorize`

/** Token endpoint */
export const TOKEN_URL = `${ISSUER}/oauth/v2/token`

/** UserInfo endpoint */
export const USERINFO_URL = `${ISSUER}/oidc/v1/userinfo`

/** End session endpoint */
export const END_SESSION_URL = `${ISSUER}/oidc/v1/end_session`

/** lurus-platform public base URL */
export const IDENTITY_URL = import.meta.env.VITE_IDENTITY_URL || 'https://identity.lurus.cn'
