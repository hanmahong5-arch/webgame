import { describe, it, expect } from 'vitest'
import { products, productIconPaths, curlExample } from './products'

describe('products', () => {
  it('should export exactly 6 products', () => {
    expect(products).toHaveLength(6)
  })

  it('should contain all core products: api, gushen, webmail, switch, acest, memx', () => {
    const ids = products.map((p) => p.id)
    expect(ids).toContain('api')
    expect(ids).toContain('gushen')
    expect(ids).toContain('webmail')
    expect(ids).toContain('switch')
    expect(ids).toContain('acest')
    expect(ids).toContain('memx')
  })

  it('should have valid URLs for each product', () => {
    products.forEach((product) => {
      // URLs can be external (https://), internal paths (/...), or placeholder (#)
      const isExternal = /^https?:\/\//.test(product.url)
      const isInternalPath = product.url.startsWith('/')
      const isPlaceholder = product.url === '#'
      expect(isExternal || isInternalPath || isPlaceholder).toBe(true)
    })
  })

  it('should have icon paths for all product icons', () => {
    products.forEach((product) => {
      expect(productIconPaths[product.icon]).toBeTruthy()
    })
  })

  it('should have a useCase field for each product', () => {
    products.forEach((product) => {
      expect(product.useCase).toBeTruthy()
      expect(product.useCase.length).toBeGreaterThan(0)
    })
  })

  it('should have required fields for each product', () => {
    products.forEach((product) => {
      expect(product.id).toBeTruthy()
      expect(product.name).toBeTruthy()
      expect(product.tagline).toBeTruthy()
      expect(product.description).toBeTruthy()
      expect(product.color).toBeTruthy()
      expect(product.bgColor).toMatch(/^#[0-9A-Fa-f]{6}$/)
      expect(product.features.length).toBeGreaterThan(0)
      expect(product.stats.value).toBeTruthy()
      expect(product.stats.label).toBeTruthy()
    })
  })

  it('should export a non-empty curl example string', () => {
    expect(curlExample).toBeTruthy()
    expect(curlExample).toContain('curl')
    expect(curlExample).toContain('api.lurus.cn')
  })

  describe('showcase data', () => {
    it('should have showcase field for infra products', () => {
      const infraProducts = products.filter((p) => p.layer === 'infra')
      infraProducts.forEach((product) => {
        expect(product.showcase).toBeDefined()
        expect(product.showcase?.type).toBeTruthy()
      })
    })

    it('API Gateway should have code showcase type', () => {
      const api = products.find((p) => p.id === 'api')
      expect(api?.showcase?.type).toBe('code')
      expect(api?.showcase?.fallbackCode).toBeTruthy()
      expect(api?.showcase?.fallbackLanguage).toBe('bash')
      expect(api?.showcase?.fallbackAriaLabel).toBeTruthy()
    })

    it('GuShen should have screenshot showcase type with fallback code', () => {
      const gushen = products.find((p) => p.id === 'gushen')
      expect(gushen?.showcase?.type).toBe('screenshot')
      expect(gushen?.showcase?.fallbackCode).toBeTruthy()
      expect(gushen?.showcase?.fallbackLanguage).toBeTruthy()
      expect(gushen?.showcase?.fallbackAriaLabel).toBeTruthy()
      expect(gushen?.showcase?.screenshotAlt).toBeTruthy()
    })

    it('Webmail should have features showcase type', () => {
      const webmail = products.find((p) => p.id === 'webmail')
      expect(webmail?.showcase?.type).toBe('features')
      expect(webmail?.showcase?.fallbackFeatures).toBeDefined()
      expect(webmail?.showcase?.fallbackFeatures?.length).toBeGreaterThan(0)
    })

    it('Switch should have features showcase type', () => {
      const sw = products.find((p) => p.id === 'switch')
      expect(sw?.showcase?.type).toBe('features')
      expect(sw?.showcase?.fallbackFeatures).toBeDefined()
      expect(sw?.showcase?.fallbackFeatures?.length).toBeGreaterThan(0)
    })

    it('showcase types should be valid', () => {
      const validTypes = ['screenshot', 'code', 'features']
      products.forEach((product) => {
        if (product.showcase) {
          expect(validTypes).toContain(product.showcase.type)
        }
      })
    })
  })
})
