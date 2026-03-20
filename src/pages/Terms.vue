<script setup lang="ts">
</script>

<template>
  <div>
    <!-- Header -->
    <section class="py-20 bg-[var(--color-surface-raised)]">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h1 class="text-phi-3xl font-bold text-[var(--color-text-primary)] mb-4">服务条款</h1>
        <p class="text-[var(--color-text-muted)] text-sm">最后更新：2026 年 2 月 25 日</p>
      </div>
    </section>

    <!-- Content -->
    <section class="py-20 bg-[var(--color-surface-base)]">
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="space-y-8">
          <div id="sec-1" class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6">
            <h2 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-3">1. 服务概述</h2>
            <p class="text-[var(--color-text-secondary)] text-sm leading-relaxed">
              Lurus（以下简称"我们"）提供 AI 模型代理 API 服务（以下简称"服务"）。使用本服务即表示您同意遵守本条款。
              本服务通过统一接口为用户提供多家 AI 模型供应商的访问能力，包括但不限于文本生成、对话、翻译等功能。
            </p>
          </div>

          <div id="sec-2" class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6">
            <h2 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-3">2. 账户注册与安全</h2>
            <p class="text-[var(--color-text-secondary)] text-sm leading-relaxed">
              您需注册账户方可使用付费服务。注册时需提供真实有效的信息。您有责任保管账户凭证的安全，
              因账户凭证泄露导致的损失由您自行承担。发现账户异常应立即联系我们。
            </p>
          </div>

          <div id="sec-3" class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6">
            <h2 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-3">3. 服务使用规范</h2>
            <div class="text-[var(--color-text-secondary)] text-sm leading-relaxed space-y-2">
              <p>您承诺不将本服务用于以下用途：</p>
              <ul class="list-disc list-inside space-y-1 ml-2">
                <li>生成违反中华人民共和国法律法规的内容</li>
                <li>侵犯第三方知识产权或合法权益</li>
                <li>生成虚假信息、仇恨言论或歧视性内容</li>
                <li>未经授权的自动化大规模调用</li>
                <li>尝试绕过系统安全机制或配额限制</li>
              </ul>
            </div>
          </div>

          <div id="sec-4" class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6">
            <h2 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-3">4. 付费与退款</h2>
            <p class="text-[var(--color-text-secondary)] text-sm leading-relaxed">
              套餐购买后立即生效。7 天内未使用超过总配额 10% 的用户可申请全额退款。
              超过 7 天或使用超过 10% 后，按实际使用量计算退款金额。退款将原路退回。
            </p>
          </div>

          <div id="sec-5" class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6">
            <h2 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-3">5. 服务等级承诺</h2>
            <p class="text-[var(--color-text-secondary)] text-sm leading-relaxed">
              我们承诺月度服务可用性不低于 99.9%。因不可抗力、第三方供应商故障或系统维护导致的服务中断不计入可用性计算。
              若未达到承诺可用性，用户可申请相应比例的服务延期补偿。
            </p>
          </div>

          <div id="sec-6" class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6">
            <h2 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-3">6. 免责声明</h2>
            <p class="text-[var(--color-text-secondary)] text-sm leading-relaxed">
              AI 模型生成的内容仅供参考，不构成专业建议。我们不对模型输出内容的准确性、完整性或适用性作任何保证。
              用户应自行判断并承担使用 AI 生成内容的风险。
            </p>
          </div>

          <div id="sec-7" class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6">
            <h2 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-3">7. 条款修改</h2>
            <p class="text-[var(--color-text-secondary)] text-sm leading-relaxed">
              我们保留修改本条款的权利。重大变更将提前 15 日通过邮件或网站公告通知。
              继续使用服务即视为接受修改后的条款。
            </p>
          </div>

          <div id="sec-8" class="border border-[var(--color-surface-border)] rounded-xl bg-[var(--color-surface-raised)] p-6">
            <h2 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-3">8. 联系方式</h2>
            <p class="text-[var(--color-text-secondary)] text-sm leading-relaxed">
              如对本条款有任何疑问，请联系：<a href="mailto:legal@lurus.cn" class="text-ochre hover:underline">legal@lurus.cn</a>
            </p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
