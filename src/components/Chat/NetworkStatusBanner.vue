<script setup lang="ts">
/**
 * Network status banner for Chat sidebar.
 * Shows offline warning + auto-dismiss "back online" notification.
 */
import { ref, watch, onUnmounted } from 'vue'

const props = defineProps<{
  isOnline: boolean
}>()

const showReconnected = ref(false)
let reconnectedTimer: ReturnType<typeof setTimeout> | null = null

watch(() => props.isOnline, (online, wasOnline) => {
  // Show "back online" only when transitioning from offline to online
  if (online && wasOnline === false) {
    showReconnected.value = true
    if (reconnectedTimer) clearTimeout(reconnectedTimer)
    reconnectedTimer = setTimeout(() => {
      showReconnected.value = false
      reconnectedTimer = null
    }, 3000)
  }
})

onUnmounted(() => {
  if (reconnectedTimer) {
    clearTimeout(reconnectedTimer)
    reconnectedTimer = null
  }
})
</script>

<template>
  <Transition name="slide">
    <div v-if="!isOnline" key="offline" class="network-banner offline" role="alert" aria-live="polite">
      <svg class="icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
          d="M18.364 5.636a9 9 0 010 12.728m0 0l-2.829-2.829m2.829 2.829L21 21M15.536 8.464a5 5 0 010 7.072m0 0l-2.829-2.829m-4.243 2.829a5 5 0 01-1.414-7.072m-2.829 9.9a9 9 0 010-12.728" />
      </svg>
      <span class="text">已离线 — 恢复连接后消息将自动发送</span>
    </div>
    <div v-else-if="showReconnected" key="online" class="network-banner online" role="status" aria-live="polite">
      <svg class="icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
      </svg>
      <span class="text">已恢复连接</span>
    </div>
  </Transition>
</template>

<style scoped>
@reference "../../styles/main.css";

.network-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  font-size: 13px;
}

.network-banner.offline {
  background: rgba(127, 29, 29, 0.2);
  color: #fca5a5;
  border-bottom: 1px solid rgba(239, 68, 68, 0.2);
}

.network-banner.online {
  background: rgba(22, 63, 40, 0.3);
  color: #86efac;
  border-bottom: 1px solid rgba(74, 222, 128, 0.2);
}

.icon {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
}

.text {
  flex: 1;
}

/* Slide transition */
.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  transform: translateY(-100%);
  opacity: 0;
}
</style>
