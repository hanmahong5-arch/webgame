<script setup lang="ts">
</script>

<template>
  <section class="py-fib-5 bg-cream-50">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
      <h3 class="text-phi-lg font-hand font-bold text-ink-900 mb-fib-4">支持的支付方式</h3>
      <div class="flex flex-wrap justify-center gap-fib-5 items-center">
        <!-- Alipay -->
        <div class="flex items-center gap-2 px-4 py-2 border-sketchy-light bg-cream-100">
          <svg class="w-6 h-6 text-[#1677FF]" viewBox="0 0 24 24" fill="currentColor">
            <path d="M21.422 15.358c-3.18-1.44-5.94-3.065-6.39-3.358.51-1.297.87-2.712.99-4.2h-3.36v-1.8h4.2V4.8h-4.2V2.4h-1.8V4.8h-4.2v1.2h4.2v1.8H7.662v1.2h6.87c-.12 1.02-.39 2.04-.81 2.94-1.56-.72-3.3-1.32-4.92-1.32-2.7 0-4.38 1.56-4.38 3.36 0 2.16 2.04 3.6 4.98 3.6 2.16 0 4.08-.84 5.64-2.4 1.62.9 4.56 2.34 6.96 3.24L21.422 15.358zM9.402 16.398c-2.1 0-3.18-.96-3.18-2.16 0-1.08.96-1.92 2.58-1.92 1.32 0 2.76.42 4.26 1.2-1.26 1.8-2.52 2.88-3.66 2.88z"/>
          </svg>
          <span class="text-ink-500 text-sm font-medium">支付宝</span>
        </div>
        <!-- WeChat Pay -->
        <div class="flex items-center gap-2 px-4 py-2 border-sketchy-light bg-cream-100">
          <svg class="w-6 h-6 text-[#07C160]" viewBox="0 0 24 24" fill="currentColor">
            <path d="M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 01.213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 00.167-.054l1.903-1.114a.864.864 0 01.717-.098 10.16 10.16 0 002.837.403c.276 0 .543-.027.811-.05-.857-2.578.157-4.972 1.932-6.446 1.703-1.415 3.882-1.98 5.853-1.838-.576-3.583-4.196-6.348-8.596-6.348z"/>
          </svg>
          <span class="text-ink-500 text-sm font-medium">微信支付</span>
        </div>
        <!-- Stripe -->
        <div class="flex items-center gap-2 px-4 py-2 border-sketchy-light bg-cream-100">
          <svg class="w-6 h-6 text-[#635BFF]" viewBox="0 0 24 24" fill="currentColor">
            <path d="M13.976 9.15c-2.172-.806-3.356-1.426-3.356-2.409 0-.831.683-1.305 1.901-1.305 2.227 0 4.515.858 6.09 1.631l.89-5.494C18.252.975 15.697 0 12.165 0 9.667 0 7.589.654 6.104 1.872 4.56 3.147 3.757 4.992 3.757 7.218c0 4.039 2.467 5.76 6.476 7.219 2.585.92 3.445 1.574 3.445 2.583 0 .98-.84 1.545-2.354 1.545-1.875 0-4.965-.921-7.076-2.19l-.879 5.625C5.248 23.063 8.082 24 11.461 24c2.682 0 4.835-.681 6.319-1.98 1.621-1.413 2.463-3.413 2.463-5.944.044-4.36-2.534-5.922-6.267-6.926z"/>
          </svg>
          <span class="text-ink-500 text-sm font-medium">Stripe</span>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
