#!/usr/bin/env node
/**
 * Bundle Size Checker
 * Validates that JS and CSS bundles are within size limits
 * NFR-B3: JS bundle ≤ 160KB gzip, CSS bundle ≤ 30KB gzip
 * (Limit raised from 150KB after Sprint 1-5 visual/info-arch upgrade)
 */

import { readdir, stat } from 'node:fs/promises'
import { join } from 'node:path'
import { gzipSync } from 'node:zlib'
import { readFileSync } from 'node:fs'

const LIMITS = {
  js: 160 * 1024,  // 160KB gzip
  css: 30 * 1024,  // 30KB gzip
}

const DIST_DIR = 'dist/assets'

async function checkBundleSize() {
  console.log('Checking bundle sizes...\n')

  let hasError = false
  const results = { js: 0, css: 0 }

  try {
    const files = await readdir(DIST_DIR)

    for (const file of files) {
      const filePath = join(DIST_DIR, file)
      const content = readFileSync(filePath)
      const gzipped = gzipSync(content)
      const size = gzipped.length

      if (file.endsWith('.js')) {
        results.js += size
      } else if (file.endsWith('.css')) {
        results.css += size
      }
    }

    // Check JS bundle
    const jsKB = (results.js / 1024).toFixed(2)
    const jsLimit = (LIMITS.js / 1024).toFixed(0)
    if (results.js > LIMITS.js) {
      console.error(`❌ JS bundle: ${jsKB}KB gzip (limit: ${jsLimit}KB)`)
      hasError = true
    } else {
      console.log(`✓ JS bundle: ${jsKB}KB gzip (limit: ${jsLimit}KB)`)
    }

    // Check CSS bundle
    const cssKB = (results.css / 1024).toFixed(2)
    const cssLimit = (LIMITS.css / 1024).toFixed(0)
    if (results.css > LIMITS.css) {
      console.error(`❌ CSS bundle: ${cssKB}KB gzip (limit: ${cssLimit}KB)`)
      hasError = true
    } else {
      console.log(`✓ CSS bundle: ${cssKB}KB gzip (limit: ${cssLimit}KB)`)
    }

    console.log('')

    if (hasError) {
      console.error('Bundle size check failed!')
      process.exit(1)
    }

    console.log('Bundle size check passed!')
  } catch (error) {
    console.error('Error checking bundle sizes:', error.message)
    process.exit(1)
  }
}

checkBundleSize()
