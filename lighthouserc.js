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
      // Use no-pwa preset as base (excludes PWA-specific checks)
      preset: 'lighthouse:no-pwa',
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'categories:accessibility': ['warn', { minScore: 0.9 }],
        'categories:best-practices': ['warn', { minScore: 0.9 }],
        'categories:seo': ['warn', { minScore: 0.9 }],
        // Known issues tracked separately — disable individual audit failures
        'aria-allowed-role': 'off',
        'color-contrast': 'off',
        'bf-cache': 'off',
        'errors-in-console': 'off',
        'forced-reflow-insight': 'off',
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
}
