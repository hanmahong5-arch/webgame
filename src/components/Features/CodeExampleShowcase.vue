<script setup lang="ts">
import { ref } from 'vue'
import CodeShowcase from '../TechDemo/CodeShowcase.vue'
import { codeExamples } from '@/data/codeExamples'

const TAB_COUNT = codeExamples.length
const activeTabIndex = ref(0)


/**
 * Switch to a tab by index, clamped to valid range.
 */
function setActiveTab(index: number) {
  if (index >= 0 && index < TAB_COUNT) {
    activeTabIndex.value = index
  }
}

/**
 * Handle keyboard navigation for WAI-ARIA Tabs pattern.
 * Left/Right arrows cycle tabs, Home/End jump to first/last.
 */
function handleTabKeydown(event: KeyboardEvent) {
  let newIndex = activeTabIndex.value

  switch (event.key) {
    case 'ArrowRight':
      newIndex = (activeTabIndex.value + 1) % TAB_COUNT
      break
    case 'ArrowLeft':
      newIndex = (activeTabIndex.value - 1 + TAB_COUNT) % TAB_COUNT
      break
    case 'Home':
      newIndex = 0
      break
    case 'End':
      newIndex = TAB_COUNT - 1
      break
    default:
      return
  }

  event.preventDefault()
  setActiveTab(newIndex)

  // Focus the newly active tab button
  const tabEl = document.getElementById(`code-tab-${codeExamples[newIndex].id}`)
  tabEl?.focus()
}
</script>

<template>
  <div class="code-example-showcase reveal-fade-up">
    <!-- Tab bar -->
    <div class="tab-bar" role="tablist" aria-label="代码示例切换">
      <button
        v-for="(example, index) in codeExamples"
        :id="`code-tab-${example.id}`"
        :key="example.id"
        role="tab"
        :aria-selected="index === activeTabIndex"
        :aria-controls="`code-tabpanel-${example.id}`"
        :tabindex="index === activeTabIndex ? 0 : -1"
        class="tab-button"
        :class="{ 'tab-button--active': index === activeTabIndex }"
        @click="setActiveTab(index)"
        @keydown="handleTabKeydown"
      >
        {{ example.label }}
      </button>
    </div>

    <!-- Tab panels -->
    <div
      v-for="(example, index) in codeExamples"
      :id="`code-tabpanel-${example.id}`"
      :key="example.id"
      role="tabpanel"
      :aria-labelledby="`code-tab-${example.id}`"
      :hidden="index !== activeTabIndex"
    >
      <CodeShowcase
        v-if="index === activeTabIndex"
        :code="example.code"
        :language="example.language"
        :show-auth-tag="example.showAuthTag"
        :ariaLabel="example.ariaLabel"
      />
    </div>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.code-example-showcase {
  width: 100%;
}

.tab-bar {
  display: flex;
  gap: 0;
  border-bottom: 2px solid var(--color-surface-border);
  margin-bottom: 0;
}

.tab-button {
  padding: 8px 20px;
  font-size: 13px;
  font-weight: 500;
  color: var(--color-text-muted);
  background: transparent;
  border: none;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
  cursor: pointer;
  transition: color 0.2s ease, border-color 0.2s ease;
  font-family: monospace;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.tab-button:hover {
  color: var(--color-text-primary);
}

.tab-button--active {
  color: var(--color-ochre);
  border-bottom-color: var(--color-ochre);
  font-weight: 600;
}

.tab-button:focus-visible {
  outline: 2px solid var(--color-ochre);
  outline-offset: -2px;
  border-radius: 4px 4px 0 0;
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  .tab-button {
    transition: none;
  }
}
</style>
