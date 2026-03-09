<script setup lang="ts">
</script>

<template>
  <div>
    <!-- Header -->
    <section class="py-fib-6 bg-cream-100 relative overflow-hidden">
      <div class="absolute inset-0 opacity-[0.02]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>
      <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h1 class="text-phi-3xl font-hand font-bold text-ink-900 mb-fib-3">隐私政策</h1>
        <p class="text-ink-400 text-sm">最后更新：2026 年 2 月 25 日</p>
      </div>
    </section>

    <!-- Content -->
    <section class="py-fib-6 bg-cream-50">
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="prose-hand space-y-fib-5">
          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">概述</h2>
            <p class="text-ink-500 text-sm leading-relaxed">
              Lurus Technology（以下简称"我们"）重视您的隐私保护。本政策依据《中华人民共和国个人信息保护法》(PIPL)
              及相关法规制定，说明我们如何收集、使用、存储和保护您的个人信息。
            </p>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">1. 我们收集的信息</h2>
            <div class="text-ink-500 text-sm leading-relaxed space-y-2">
              <p><strong class="text-ink-700">账户信息：</strong>注册时的邮箱地址、用户名。</p>
              <p><strong class="text-ink-700">使用数据：</strong>API 调用次数、Token 消耗量、模型选择偏好（匿名化统计）。</p>
              <p><strong class="text-ink-700">支付信息：</strong>通过第三方支付平台处理，我们不存储完整的支付卡号。</p>
              <p><strong class="text-ink-700">日志数据：</strong>IP 地址、浏览器类型、访问时间（用于安全防护和服务优化）。</p>
            </div>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">2. 我们不收集的信息</h2>
            <div class="text-ink-500 text-sm leading-relaxed space-y-2">
              <p><strong class="text-ink-700">对话内容：</strong>我们不存储、不查看、不分析您通过 API 发送的对话内容。请求数据在处理完成后即时销毁。</p>
              <p><strong class="text-ink-700">生物识别信息：</strong>我们不收集指纹、面部识别等生物识别数据。</p>
            </div>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">3. 信息使用目的</h2>
            <ul class="text-ink-500 text-sm leading-relaxed list-disc list-inside space-y-1 ml-2">
              <li>提供和维护服务正常运行</li>
              <li>处理支付和计费</li>
              <li>安全防护和异常检测</li>
              <li>服务改进和性能优化</li>
              <li>法律法规要求的合规披露</li>
            </ul>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">4. 数据存储与安全</h2>
            <div class="text-ink-500 text-sm leading-relaxed space-y-2">
              <p>您的个人信息存储在中国境内的服务器上，采用以下安全措施：</p>
              <ul class="list-disc list-inside space-y-1 ml-2">
                <li>全链路 TLS 1.3 传输加密</li>
                <li>数据库加密存储 (AES-256)</li>
                <li>严格的访问控制和审计日志</li>
                <li>定期安全漏洞扫描和渗透测试</li>
              </ul>
            </div>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">5. 第三方共享</h2>
            <p class="text-ink-500 text-sm leading-relaxed">
              我们不会出售您的个人信息。仅在以下情况下共享数据：
              向 AI 模型供应商转发 API 请求（不含用户身份信息）；
              向支付服务商提供必要的交易信息；
              法律法规或司法机关要求的披露。
            </p>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">6. 您的权利（PIPL 合规）</h2>
            <div class="text-ink-500 text-sm leading-relaxed space-y-2">
              <p>根据《个人信息保护法》，您享有以下权利：</p>
              <ul class="list-disc list-inside space-y-1 ml-2">
                <li><strong class="text-ink-700">知情权：</strong>了解我们如何处理您的个人信息</li>
                <li><strong class="text-ink-700">访问权：</strong>获取我们持有的您的个人信息副本</li>
                <li><strong class="text-ink-700">更正权：</strong>要求更正不准确的个人信息</li>
                <li><strong class="text-ink-700">删除权：</strong>要求删除您的个人信息</li>
                <li><strong class="text-ink-700">撤回同意权：</strong>随时撤回对信息处理的同意</li>
                <li><strong class="text-ink-700">可携带权：</strong>要求以结构化格式导出个人数据</li>
              </ul>
              <p>行使上述权利请联系：<a href="mailto:privacy@lurus.cn" class="text-ochre hover:underline">privacy@lurus.cn</a></p>
            </div>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">7. Cookie 使用</h2>
            <p class="text-ink-500 text-sm leading-relaxed">
              我们使用必要的 Cookie 维持会话状态和安全验证。不使用第三方跟踪 Cookie。
              您可以通过浏览器设置管理 Cookie 偏好。
            </p>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">8. 未成年人保护</h2>
            <p class="text-ink-500 text-sm leading-relaxed">
              本服务不面向 14 周岁以下的未成年人。若我们发现无意中收集了未成年人的个人信息，将立即删除。
            </p>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">9. 政策更新</h2>
            <p class="text-ink-500 text-sm leading-relaxed">
              本政策可能不时更新。重大变更将通过邮件或网站公告提前通知。建议您定期查阅本政策。
            </p>
          </div>

          <div class="border-sketchy bg-cream-100 p-fib-4">
            <h2 class="text-phi-lg font-hand font-bold text-ink-900 mb-3">10. 联系我们</h2>
            <div class="text-ink-500 text-sm leading-relaxed">
              <p>隐私相关问题请联系：</p>
              <p class="mt-2">邮箱：<a href="mailto:privacy@lurus.cn" class="text-ochre hover:underline">privacy@lurus.cn</a></p>
              <p>客服：<a href="mailto:support@lurus.cn" class="text-ochre hover:underline">support@lurus.cn</a></p>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
