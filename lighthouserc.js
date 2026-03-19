/**
 * Lighthouse CI Configuration
 * NFR-B4: Performance ≥ 90
 * Collects performance data only — assertions are advisory (continue-on-error: true)
 */

export default {
  ci: {
    collect: {
      staticDistDir: './dist',
      numberOfRuns: 1,
    },
    // No assert section — lhci collects scores for trending without blocking CI
    // Category score targets (NFR-B4): performance ≥ 90, accessibility ≥ 90
    upload: {
      target: 'temporary-public-storage',
    },
  },
}
