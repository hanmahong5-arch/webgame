<script setup lang="ts">
withDefaults(defineProps<{
  variant?: 'down' | 'up'
}>(), {
  variant: 'down',
})
</script>

<template>
  <div class="section-divider-dark" :class="{ 'section-divider-dark--up': variant === 'up' }" aria-hidden="true">
    <svg viewBox="0 0 1440 60" preserveAspectRatio="none" fill="none">
      <path
        d="M0,0 C360,50 1080,50 1440,0 L1440,60 L0,60 Z"
        :fill="variant === 'down' ? 'var(--color-surface-raised)' : 'var(--color-surface-base)'"
      />
    </svg>
  </div>
</template>

<style scoped>
.section-divider-dark {
  width: 100%;
  line-height: 0;
  overflow: hidden;
  margin: -1px 0;
}

.section-divider-dark svg {
  width: 100%;
  height: 40px;
}

.section-divider-dark--up {
  transform: rotate(180deg);
}
</style>
