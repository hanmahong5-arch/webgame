/**
 * Lighthouse CI Configuration
 * NFR-B4: Performance ≥ 90
 */

export default {
  ci: {
    collect: {
      url: ['http://localhost:4173/'],
      startServerCommand: 'bun run preview',
      startServerReadyPattern: 'Local',
      numberOfRuns: 3,
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'categories:accessibility': ['warn', { minScore: 0.9 }],
        'categories:best-practices': ['warn', { minScore: 0.9 }],
        'categories:seo': ['warn', { minScore: 0.9 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
}
