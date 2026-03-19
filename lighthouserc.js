/**
 * Lighthouse CI Configuration
 * NFR-B4: Performance ≥ 90
 * Collects performance data only — continue-on-error: true in CI
 *
 * Note: lhci loads this via CJS require() which returns { default: config }
 * for ESM files. Exporting named `ci` ensures the config is found either way.
 */

const config = {
  ci: {
    collect: {
      staticDistDir: './dist',
      numberOfRuns: 1,
    },
    // No assert section — only collect scores for performance trending
    upload: {
      target: 'temporary-public-storage',
    },
  },
}

export default config
export const ci = config.ci
