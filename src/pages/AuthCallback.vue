<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '../composables/useAuth'

const router = useRouter()
const { handleCallback } = useAuth()
const error = ref<string | null>(null)

onMounted(async () => {
  try {
    const params = new URLSearchParams(window.location.search)
    const code = params.get('code')
    const state = params.get('state')
    const errorParam = params.get('error')
    const errorDesc = params.get('error_description')

    if (errorParam) {
      error.value = errorDesc || errorParam
      return
    }

    if (!code || !state) {
      error.value = '缺少授权参数，请重新登录'
      return
    }

    await handleCallback(code, state)

    // Restore original URL or go home
    const returnUrl = sessionStorage.getItem('oidc_return_url')
    sessionStorage.removeItem('oidc_return_url')
    router.replace(returnUrl || '/')
  } catch (err) {
    error.value = err instanceof Error ? err.message : '登录回调处理失败'
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
        <p class="text-[var(--color-text-secondary)] text-xl">正在登录...</p>
      </div>

      <!-- Error state -->
      <div v-else class="space-y-4">
        <div class="w-12 h-12 mx-auto rounded-lg bg-red-900/30 flex items-center justify-center border-2 border-red-500/40">
          <svg class="w-6 h-6 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </div>
        <p class="text-[var(--color-text-primary)] font-semibold">登录失败</p>
        <p class="text-[var(--color-text-secondary)] text-sm">{{ error }}</p>
        <button
          @click="router.replace('/')"
          class="btn-primary mt-4"
        >
          返回首页
        </button>
      </div>
    </div>
  </div>
</template>
