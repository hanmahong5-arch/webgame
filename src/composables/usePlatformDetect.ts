/**
 * Platform detection composable
 * Detects user's OS and architecture from User-Agent
 */

import { computed } from 'vue'
import type { Platform, Architecture } from '../types/release'

export function usePlatformDetect() {
  const detectedPlatform = computed<Platform>(() => {
    const ua = navigator.userAgent.toLowerCase()
    if (ua.includes('android')) return 'android'
    if (ua.includes('iphone') || ua.includes('ipad')) return 'ios'
    if (ua.includes('mac')) return 'darwin'
    if (ua.includes('linux')) return 'linux'
    return 'windows'
  })

  const detectedArch = computed<Architecture>(() => {
    const ua = navigator.userAgent.toLowerCase()
    if (ua.includes('arm64') || ua.includes('aarch64')) return 'arm64'
    return 'x64'
  })

  const platformDisplayName = computed(() => {
    const names: Record<string, string> = {
      windows: 'Windows',
      darwin: 'macOS',
      linux: 'Linux',
      android: 'Android',
      ios: 'iOS',
    }
    return names[detectedPlatform.value] || detectedPlatform.value
  })

  const isMobile = computed(() => {
    return detectedPlatform.value === 'android' || detectedPlatform.value === 'ios'
  })

  return {
    detectedPlatform,
    detectedArch,
    platformDisplayName,
    isMobile,
  }
}
