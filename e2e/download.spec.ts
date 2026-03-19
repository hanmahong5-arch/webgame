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
    await expect(page.locator('h1')).toContainText('下载中心')
  })

  test('should display product filter tabs', async ({ page }) => {
    const allProductsTab = page.getByRole('button', { name: '全部产品' })
    await expect(allProductsTab).toBeVisible()

    const switchTab = page.getByRole('button', { name: 'Lurus Switch' })
    await expect(switchTab).toBeVisible()

    const cliTab = page.getByRole('button', { name: 'Lurus CLI' })
    await expect(cliTab).toBeVisible()
  })

  test('should toggle prerelease filter', async ({ page }) => {
    const prereleaseCheckbox = page.locator('input[type="checkbox"]')
    await expect(prereleaseCheckbox).toBeVisible()

    // Should be unchecked by default
    await expect(prereleaseCheckbox).not.toBeChecked()

    // Toggle on
    await prereleaseCheckbox.click()
    await expect(prereleaseCheckbox).toBeChecked()
  })

  test('should switch between product tabs', async ({ page }) => {
    const switchTab = page.getByRole('button', { name: 'Lurus Switch' })
    const cliTab = page.getByRole('button', { name: 'Lurus CLI' })
    const allTab = page.getByRole('button', { name: '全部产品' })

    // Click Lurus Switch
    await switchTab.click()
    await expect(switchTab).toHaveClass(/bg-primary/)

    // Click Lurus CLI
    await cliTab.click()
    await expect(cliTab).toHaveClass(/bg-primary/)

    // Click All Products
    await allTab.click()
    await expect(allTab).toHaveClass(/bg-primary/)
  })

  test('should display installation guide section', async ({ page }) => {
    const installGuide = page.getByRole('heading', { name: '安装指南' })
    await expect(installGuide).toBeVisible()

    await expect(page.locator('text=Windows 安装')).toBeVisible()
    await expect(page.locator('text=macOS 安装')).toBeVisible()
    await expect(page.locator('text=Linux 安装')).toBeVisible()
  })

  test('should display system requirements section', async ({ page }) => {
    const sysReq = page.getByRole('heading', { name: '系统要求' })
    await expect(sysReq).toBeVisible()

    await expect(page.locator('text=Windows 10 或更高版本')).toBeVisible()
    await expect(page.locator('text=macOS 11 Big Sur 或更高版本')).toBeVisible()
    await expect(page.locator('text=Ubuntu 20.04+ / Debian 11+')).toBeVisible()
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
