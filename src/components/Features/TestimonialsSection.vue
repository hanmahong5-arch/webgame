<script setup lang="ts">
import { testimonials } from '../../data/testimonials'
</script>

<template>
  <section class="section-dark-raised py-20" aria-label="客户评价">
    <div class="max-w-6xl mx-auto px-6 sm:px-8 lg:px-12">
      <div class="text-center mb-14 reveal-fade-up">
        <h2 class="testimonials-title">用户怎么说</h2>
        <p class="testimonials-subtitle">来自真实使用者的反馈</p>
      </div>
      <div class="testimonials-grid reveal-fade-up">
        <div
          v-for="t in testimonials"
          :key="t.author"
          class="testimonial-card"
        >
          <svg class="testimonial-quote-icon" viewBox="0 0 24 24" fill="var(--color-surface-border)" aria-hidden="true">
            <path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10H14.017zM0 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151C7.546 6.068 5.983 8.789 5.983 11H10v10H0z" />
          </svg>
          <p class="testimonial-text">{{ t.quote }}</p>
          <div class="testimonial-footer">
            <div class="testimonial-avatar">{{ t.author.charAt(0) }}</div>
            <div>
              <p class="testimonial-author">{{ t.author }}</p>
              <p class="testimonial-role">{{ t.role }} · {{ t.product }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

.testimonials-title {
  font-size: clamp(1.75rem, 4vw, 2.5rem);
  font-weight: 800;
  color: var(--color-text-primary);
  letter-spacing: -0.03em;
}

.testimonials-subtitle {
  font-size: 1rem;
  color: var(--color-text-secondary);
  margin-top: 8px;
}

.testimonials-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

@media (max-width: 767px) {
  .testimonials-grid { grid-template-columns: 1fr; }
}

.testimonial-card {
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  border-radius: 14px;
  padding: 28px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.testimonial-quote-icon {
  width: 24px;
  height: 24px;
  opacity: 0.3;
}

.testimonial-text {
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  line-height: 1.7;
  flex: 1;
}

.testimonial-footer {
  display: flex;
  align-items: center;
  gap: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--color-surface-border);
}

.testimonial-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background-color: var(--color-ochre);
  color: #0D0B09;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.875rem;
  flex-shrink: 0;
}

.testimonial-author {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.testimonial-role {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  margin-top: 2px;
}
</style>
