<script setup lang="ts">
import type { ComparisonFeature } from '../../types/pricing'
import CheckIcon from './icons/CheckIcon.vue'
import MinusIcon from './icons/MinusIcon.vue'

defineProps<{
  features: ComparisonFeature[]
}>()
</script>

<template>
  <div class="overflow-x-auto border-sketchy bg-cream-50">
    <table class="w-full text-left">
      <thead>
        <tr class="border-b-2 border-ink-100">
          <th class="py-4 px-4 text-ink-500 font-medium">功能</th>
          <th class="py-4 px-4 text-ink-500 font-medium text-center">个人</th>
          <th class="py-4 px-4 text-ink-500 font-medium text-center">团队</th>
          <th class="py-4 px-4 text-ink-500 font-medium text-center">平台</th>
        </tr>
      </thead>
      <tbody class="text-sm">
        <tr
          v-for="(feature, idx) in features"
          :key="feature.name"
          :class="idx < features.length - 1 ? 'border-b border-ink-100/50' : ''"
        >
          <td class="py-4 px-4 text-ink-900">{{ feature.name }}</td>
          <td class="py-4 px-4 text-center">
            <template v-if="typeof feature.personal === 'boolean'">
              <CheckIcon v-if="feature.personal" />
              <MinusIcon v-else />
            </template>
            <span v-else class="text-ink-500">{{ feature.personal }}</span>
          </td>
          <td class="py-4 px-4 text-center">
            <template v-if="typeof feature.team === 'boolean'">
              <CheckIcon v-if="feature.team" />
              <MinusIcon v-else />
            </template>
            <span v-else class="text-ink-500">{{ feature.team }}</span>
          </td>
          <td class="py-4 px-4 text-center">
            <template v-if="typeof feature.platform === 'boolean'">
              <CheckIcon v-if="feature.platform" />
              <MinusIcon v-else />
            </template>
            <span v-else class="text-ink-500">{{ feature.platform }}</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
