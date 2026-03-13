<script setup lang="ts">
import { mediaShowcases } from '../../data/mediaShowcases'
import SwitchDiagram from '../Illustrations/SwitchDiagram.vue'
import ApiDiagram from '../Illustrations/ApiDiagram.vue'
import AcestDiagram from '../Illustrations/AcestDiagram.vue'
import ProductFlowConnector from './ProductFlowConnector.vue'

const diagramComponents: Record<string, typeof SwitchDiagram> = {
  switch: SwitchDiagram,
  api: ApiDiagram,
  acest: AcestDiagram,
}
</script>

<template>
  <section class="py-fib-7 bg-cream-50" aria-label="Product demos">
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="text-center mb-fib-6 reveal-fade-up">
        <h2 class="text-phi-2xl sm:text-phi-3xl text-ink-900 mb-fib-3 font-semibold">
          看看它是怎么工作的
        </h2>
        <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto">
          简单几步，体验更高效的 AI 工作流
        </p>
      </div>

      <div class="space-y-0">
        <template v-for="(item, idx) in mediaShowcases" :key="item.id">
          <div
            class="grid grid-cols-1 lg:grid-cols-2 gap-fib-5 items-center reveal-fade-up"
            :class="{ 'lg:direction-rtl': idx % 2 === 1 }"
          >
            <!-- Text side -->
            <div :class="{ 'lg:order-2': idx % 2 === 1 }">
              <div
                class="w-10 h-10 rounded-lg flex items-center justify-center border-2 border-ink-200 mb-fib-4"
                :style="{ backgroundColor: item.color + '20' }"
              >
                <div class="w-3 h-3 rounded-full" :style="{ backgroundColor: item.color }"></div>
              </div>
              <h3 class="text-phi-xl font-hand font-bold text-ink-900 mb-fib-3">
                {{ item.title }}
              </h3>
              <p class="text-ink-500 leading-relaxed mb-fib-3">
                {{ item.description }}
              </p>
              <p class="text-sm text-ink-400 leading-relaxed">
                {{ item.detail }}
              </p>
            </div>

            <!-- Media / Illustration -->
            <div :class="{ 'lg:order-1': idx % 2 === 1 }">
              <div
                v-if="item.mediaSrc"
                class="aspect-video border-sketchy bg-cream-100 overflow-hidden"
              >
                <img
                  :src="item.mediaSrc"
                  :alt="item.mediaAlt"
                  class="w-full h-full object-cover"
                />
              </div>
              <div
                v-else-if="diagramComponents[item.id]"
                class="aspect-video border-sketchy bg-cream-100 flex items-center justify-center p-4"
              >
                <component :is="diagramComponents[item.id]" />
              </div>
              <div
                v-else
                class="aspect-video border-sketchy bg-cream-100 flex flex-col items-center justify-center gap-fib-3"
              >
                <div
                  class="w-14 h-14 rounded-full border-2 flex items-center justify-center"
                  :style="{ borderColor: item.color + '60', backgroundColor: item.color + '10' }"
                >
                  <svg
                    class="w-6 h-6 ml-0.5"
                    :style="{ color: item.color }"
                    fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"
                  >
                    <path d="M8 5v14l11-7z" />
                  </svg>
                </div>
                <span class="text-sm text-ink-300">产品演示 GIF / 视频</span>
              </div>
            </div>
          </div>

          <!-- Flow connector between showcase items -->
          <ProductFlowConnector
            v-if="idx < mediaShowcases.length - 1"
            :from-color="item.color"
            :to-color="mediaShowcases[idx + 1].color"
          />
        </template>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
