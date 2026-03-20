/**
 * Composable for managing releases and downloads
 * Always fetches from real API; shows friendly error on failure.
 * All fetch methods use AbortController to cancel stale requests on rapid navigation.
 */

import { ref, type Ref } from 'vue'
import type {
  Release,
  ReleaseListResponse,
  LatestReleaseResponse,
  FetchReleasesParams,
  ApiResponse,
  ReleaseArtifact,
} from '../types/release'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://api.lurus.cn'

/** Convert HTTP status to user-friendly error text */
function friendlyHttpError(status: number): string {
  if (status === 404) return '请求的资源未找到。'
  if (status === 429) return '请求过于频繁，请稍后再试。'
  if (status >= 500) return '服务器暂时不可用，请稍后重试。'
  if (status === 403) return '访问被拒绝，你可能没有访问权限。'
  return `请求失败 (HTTP ${status})，请重试。`
}

export function useReleases() {
  const releases: Ref<Release[]> = ref([])
  const total: Ref<number> = ref(0)
  const currentPage: Ref<number> = ref(1)
  const pageSize: Ref<number> = ref(20)
  const isLoading: Ref<boolean> = ref(false)
  const error: Ref<string | null> = ref(null)

  // Track active AbortController so callers can cancel in-flight requests
  let activeController: AbortController | null = null

  /**
   * Cancel all pending fetch operations.
   * Call this on component unmount or before starting a new competing fetch.
   */
  function cancelPending(): void {
    activeController?.abort()
    activeController = null
  }

  async function fetchReleases(params: FetchReleasesParams = {}): Promise<void> {
    // Abort any previous in-flight request (prevents stale response overwriting fresh data)
    cancelPending()

    const controller = new AbortController()
    activeController = controller

    isLoading.value = true
    error.value = null

    try {
      const queryParams = new URLSearchParams()

      if (params.product_id) queryParams.append('product_id', params.product_id)
      if (params.release_type) queryParams.append('release_type', params.release_type)
      if (params.include_prerelease !== undefined) {
        queryParams.append('include_prerelease', String(params.include_prerelease))
      }
      if (params.page) queryParams.append('page', String(params.page))
      if (params.page_size) queryParams.append('page_size', String(params.page_size))

      const url = `${API_BASE_URL}/api/releases?${queryParams.toString()}`
      const response = await fetch(url, { signal: controller.signal })

      if (!response.ok) {
        throw new Error(friendlyHttpError(response.status))
      }

      const result: ApiResponse<ReleaseListResponse> = await response.json()

      if (!result.success) {
        throw new Error(result.error || '加载版本列表失败。')
      }

      releases.value = result.data.releases
      total.value = result.data.total
      currentPage.value = result.data.page
      pageSize.value = result.data.page_size
    } catch (err) {
      // Silently ignore aborted requests — they are intentional cancellations
      if (err instanceof DOMException && err.name === 'AbortError') return
      if (err instanceof TypeError && err.message.includes('fetch')) {
        error.value = '网络连接失败，请检查网络设置后重试。'
      } else {
        error.value = err instanceof Error ? err.message : '发生意外错误。'
      }
      console.error('Failed to fetch releases:', err)
    } finally {
      // Only clear loading if this controller is still the active one
      if (activeController === controller) {
        isLoading.value = false
      }
    }
  }

  async function fetchLatestRelease(
    productId: string,
    currentVersion?: string,
    signal?: AbortSignal
  ): Promise<LatestReleaseResponse | null> {
    isLoading.value = true
    error.value = null

    try {
      const queryParams = new URLSearchParams()
      if (currentVersion) {
        queryParams.append('current_version', currentVersion)
      }

      const url = `${API_BASE_URL}/api/releases/latest/${productId}?${queryParams.toString()}`
      const response = await fetch(url, { signal })

      if (!response.ok) {
        throw new Error(friendlyHttpError(response.status))
      }

      const result: ApiResponse<LatestReleaseResponse> = await response.json()

      if (!result.success) {
        throw new Error(result.error || '获取最新版本失败。')
      }

      return result.data
    } catch (err) {
      if (err instanceof DOMException && err.name === 'AbortError') return null
      error.value = err instanceof Error ? err.message : '发生意外错误。'
      console.error('Failed to fetch latest release:', err)
      return null
    } finally {
      isLoading.value = false
    }
  }

  async function fetchReleaseById(
    releaseId: number,
    signal?: AbortSignal
  ): Promise<Release | null> {
    isLoading.value = true
    error.value = null

    try {
      const url = `${API_BASE_URL}/api/releases/${releaseId}`
      const response = await fetch(url, { signal })

      if (!response.ok) {
        throw new Error(friendlyHttpError(response.status))
      }

      const result: ApiResponse<Release> = await response.json()

      if (!result.success) {
        throw new Error(result.error || '加载版本详情失败。')
      }

      return result.data
    } catch (err) {
      if (err instanceof DOMException && err.name === 'AbortError') return null
      error.value = err instanceof Error ? err.message : '发生意外错误。'
      console.error('Failed to fetch release:', err)
      return null
    } finally {
      isLoading.value = false
    }
  }

  function getDownloadUrl(releaseId: number, artifactId: number): string {
    return `${API_BASE_URL}/api/releases/${releaseId}/download/${artifactId}`
  }

  function downloadArtifact(releaseId: number, artifactId: number): void {
    const url = getDownloadUrl(releaseId, artifactId)
    window.location.href = url
  }

  function formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B'

    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`
  }

  function getPlatformName(platform: string): string {
    const names: Record<string, string> = {
      windows: 'Windows',
      darwin: 'macOS',
      linux: 'Linux',
      android: 'Android',
      ios: 'iOS',
    }
    return names[platform] || platform
  }

  function getArchName(arch: string): string {
    const names: Record<string, string> = {
      x64: 'x64',
      arm64: 'ARM64',
      amd64: 'AMD64',
      universal: 'Universal',
    }
    return names[arch] || arch
  }

  function findRecommendedArtifact(artifacts: ReleaseArtifact[]): ReleaseArtifact | null {
    const ua = navigator.userAgent.toLowerCase()
    let platform = 'windows'
    let arch = 'x64'

    if (ua.includes('mac')) {
      platform = 'darwin'
    } else if (ua.includes('linux')) {
      platform = 'linux'
    }

    if (ua.includes('arm64') || ua.includes('aarch64')) {
      arch = 'arm64'
    }

    const exact = artifacts.find(a => a.platform === platform && a.arch === arch)
    if (exact) return exact

    const platformMatch = artifacts.find(a => a.platform === platform)
    if (platformMatch) return platformMatch

    return artifacts[0] || null
  }

  return {
    releases,
    total,
    currentPage,
    pageSize,
    isLoading,
    error,
    fetchReleases,
    fetchLatestRelease,
    fetchReleaseById,
    getDownloadUrl,
    downloadArtifact,
    formatFileSize,
    getPlatformName,
    getArchName,
    findRecommendedArtifact,
    cancelPending,
  }
}
