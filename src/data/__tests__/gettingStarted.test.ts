import { describe, it, expect } from 'vitest'
import { gettingStartedItems } from '../gettingStarted'

describe('gettingStartedItems', () => {
  it('should export exactly 3 items', () => {
    expect(gettingStartedItems).toHaveLength(3)
  })

  it('should have required fields for each item', () => {
    gettingStartedItems.forEach((item) => {
      expect(item.id).toBeTruthy()
      expect(typeof item.id).toBe('string')
      expect(item.label).toBeTruthy()
      expect(typeof item.label).toBe('string')
      expect(item.href).toBeTruthy()
      expect(typeof item.href).toBe('string')
      expect(typeof item.external).toBe('boolean')
      expect(item.ariaLabel).toBeTruthy()
      expect(typeof item.ariaLabel).toBe('string')
      expect(item.iconPath).toBeTruthy()
      expect(typeof item.iconPath).toBe('string')
      expect(item.description).toBeTruthy()
      expect(typeof item.description).toBe('string')
    })
  })

  it('should have unique IDs', () => {
    const ids = gettingStartedItems.map((item) => item.id)
    expect(new Set(ids).size).toBe(ids.length)
  })

  it('should contain the expected item IDs', () => {
    const ids = gettingStartedItems.map((item) => item.id)
    expect(ids).toContain('api-docs')
    expect(ids).toContain('download')
    expect(ids).toContain('lucrum')
  })

  it('should mark external links correctly', () => {
    const apiDocs = gettingStartedItems.find((i) => i.id === 'api-docs')
    expect(apiDocs?.external).toBe(true)
    expect(apiDocs?.href).toMatch(/^https:\/\//)

    const lucrum = gettingStartedItems.find((i) => i.id === 'lucrum')
    expect(lucrum?.external).toBe(true)
    expect(lucrum?.href).toMatch(/^https:\/\//)
  })

  it('should mark download as internal link', () => {
    const download = gettingStartedItems.find((i) => i.id === 'download')
    expect(download?.external).toBe(false)
    expect(download?.href).toBe('/download')
  })

  it('should have ariaLabel for every item', () => {
    gettingStartedItems.forEach((item) => {
      expect(item.ariaLabel.length).toBeGreaterThan(0)
    })
  })
})
