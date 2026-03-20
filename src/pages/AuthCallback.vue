<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '../composables/useAuth'

const router = useRouter()
const { handleCallback, login } = useAuth()
const error = ref<string | null>(null)
const errorHint = ref<string | null>(null)

/** Classify error and provide actionable hint */
function classifyError(err: unknown, rawParam?: string): { message: string; hint: string } {
  const msg = err instanceof Error ? err.message : String(err)

  if (rawParam === 'access_denied') {
    return { message: '登录已被取消或拒绝。', hint: '你可以重新尝试登录，或返回首页。' }
  }
  if (msg.includes('state') || msg.includes('CSRF')) {
    return { message: '安全验证失败。', hint: '通常是因为登录链接已过期，请重新登录。' }
  }
  if (msg.includes('code_verifier') || msg.includes('PKCE')) {
    return { message: '登录会话数据缺失。', hint: '浏览器可能已清除会话数据，请重新登录。' }
  }
  if (msg.includes('Token') || msg.includes('HTTP')) {
    return { message: '无法完成身份验证。', hint: '认证服务器可能暂时不可用，请稍后重试。' }
  }
  if (msg.includes('fetch') || msg.includes('network') || msg.includes('Network')) {
    return { message: '网络连接失败。', hint: '请检查网络连接后重试。' }
  }
  return { message: msg || '登录过程中发生意外错误。', hint: '请重新尝试登录。如问题持续，请联系客服。' }
}

const canRetryLogin = computed(() => !!error.value)

function retryLogin() {
  const returnUrl = sessionStorage.getItem('oidc_return_url') || '/'
  login({ returnUrl })
}

onMounted(async () => {
  try {
    const params = new URLSearchParams(window.location.search)
    const code = params.get('code')
    const state = params.get('state')
    const errorParam = params.get('error')
    const errorDesc = params.get('error_description')

    if (errorParam) {
      const classified = classifyError(new Error(errorDesc || errorParam), errorParam)
      error.value = classified.message
      errorHint.value = classified.hint
      return
    }

    if (!code || !state) {
      error.value = '缺少授权参数。'
      errorHint.value = '登录链接可能不完整，请重新登录。'
      return
    }

    await handleCallback(code, state)

    // Restore original URL or go home
    const returnUrl = sessionStorage.getItem('oidc_return_url')
    sessionStorage.removeItem('oidc_return_url')
    router.replace(returnUrl || '/')
  } catch (err) {
    const params = new URLSearchParams(window.location.search)
    const classified = classifyError(err, params.get('error') || undefined)
    error.value = classified.message
    errorHint.value = classified.hint
  }
})
</script>

<template>
  <div class="min-h-screen bg-[var(--color-surface-base)] flex items-center justify-center px-4">
    <div class="max-w-md w-full text-center">
      <!-- Loading state -->
      <div v-if="!error" class="space-y-4">
        <div class="w-12 h-12 mx-auto rounded-lg bg-[var(--color-ochre)] flex items-center justify-center border-2 border-[var(--color-surface-border)] animate-pulse">
          <span class="text-white font-bold text-xl">L</span>
        </div>
        <p class="text-[var(--color-text-secondary)] text-xl">正在登录…</p>
      </div>

      <!-- Error state -->
      <div v-else class="space-y-5">
        <div class="w-14 h-14 mx-auto rounded-xl bg-red-900/20 flex items-center justify-center border border-red-500/30">
          <svg class="w-7 h-7 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </div>
        <div>
          <p class="text-[var(--color-text-primary)] font-semibold text-lg">登录失败</p>
          <p class="text-[var(--color-text-secondary)] text-sm mt-2">{{ error }}</p>
          <p v-if="errorHint" class="text-[var(--color-text-muted)] text-xs mt-2">{{ errorHint }}</p>
        </div>

        <!-- Actions: retry login is the primary action -->
        <div class="flex justify-center gap-3 pt-2">
          <button
            v-if="canRetryLogin"
            @click="retryLogin"
            class="btn-primary px-5 py-2.5 text-sm"
          >
            <svg class="w-4 h-4 mr-1.5 inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h5M20 20v-5h-5M20.49 9A9 9 0 015.64 5.64L1 10m23 4l-4.64 4.36A9 9 0 013.51 15" />
            </svg>
            重新登录
          </button>
          <button
            @click="router.replace('/')"
            class="btn-outline px-5 py-2.5 text-sm"
          >
            回到首页
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
