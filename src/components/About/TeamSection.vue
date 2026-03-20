<script setup lang="ts">
import { team } from '../../data/team'
</script>

<template>
  <section id="team" class="py-24 section-dark-raised">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="text-center mb-10 reveal-fade-up">
        <h2 class="text-phi-2xl font-bold text-[var(--color-text-primary)] mb-2">我们的团队</h2>
        <p class="text-[var(--color-text-secondary)] max-w-xl mx-auto">
          一群热爱构建工具的工程师和设计师，致力于让 AI 基础设施触手可及。
        </p>
      </div>
      <div class="team-grid reveal-fade-up">
        <div
          v-for="member in team"
          :key="member.role"
          class="team-card"
        >
          <div class="team-avatar" :style="{ backgroundColor: member.color + '20', color: member.color }">
            {{ member.initials }}
          </div>
          <h3 class="team-name">{{ member.name }}</h3>
          <p class="team-role">{{ member.role }}</p>
          <p class="team-bio">{{ member.bio }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

.team-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

@media (min-width: 640px) {
  .team-grid { grid-template-columns: repeat(4, 1fr); }
}

.team-card {
  text-align: center;
  padding: 28px 16px;
  border: 1px solid var(--color-surface-border);
  border-radius: 12px;
  background-color: var(--color-surface-raised);
  transition: border-color 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
}

.team-card:hover {
  border-color: rgba(212, 168, 39, 0.3);
  transform: translateY(-2px);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
}

.team-avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  font-size: 1.125rem;
  margin: 0 auto 14px;
}

.team-name {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 4px;
}

.team-role {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  margin-bottom: 10px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.team-bio {
  font-size: 0.8rem;
  color: var(--color-text-secondary);
  line-height: 1.6;
}
</style>
