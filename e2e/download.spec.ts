/**
 * E2E tests for Download page
 */

import { test, expect } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

test.describe('Download Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/download')
  })

  test('should load download page successfully', async ({ page }) => {
    await expect(page).toHaveTitle(/Lurus/)
    await expect(page.locator('h1')).toContainText('ACEST Desktop')
  })

  test('should display Windows download button', async ({ page }) => {
    const downloadBtn = page.getByRole('button', { name: /Download for Windows/i })
    await expect(downloadBtn).toBeVisible()
  })

  test('should display ACEST subtitle', async ({ page }) => {
    await expect(page.locator('text=Adaptive Context Engine for Smart Tasks')).toBeVisible()
  })

  test('should have version badge', async ({ page }) => {
    // Badge shows version and platform, e.g. "v0.2.0 — Windows"
    await expect(page.locator('text=Windows').first()).toBeVisible()
  })

  test('should pass accessibility checks', async ({ page }) => {
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze()

    expect(results.violations).toEqual([])
  })

  // TODO: Add API-mocked tests once release backend endpoints are live
  // Tests for: release cards, download buttons, changelog toggle, checksum display, pagination
})
