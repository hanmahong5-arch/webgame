import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ProductSubCard from '../ProductSubCard.vue'
import type { Product } from '../../../types/products'

const createMockProduct = (overrides: Partial<Product> = {}): Product => ({
  id: 'api',
  name: 'Lurus API',
  tagline: 'LLM Gateway',
  description: 'Unified AI model access',
  useCase: '3 lines of code for 50+ AI models',
  url: 'https://api.lurus.cn',
  icon: 'api',
  color: 'product-api',
  bgColor: '#6B8BA4',
  features: ['Unified API', 'Load Balancing', 'Usage Monitoring', 'Multi-tenant'],
  stats: { value: '99.9%', label: 'Availability' },
  layer: 'infra',
  ...overrides,
})

describe('ProductSubCard', () => {
  const mountComponent = (product: Product = createMockProduct()) => {
    return mount(ProductSubCard, {
      props: { product },
    })
  }

  describe('content rendering', () => {
    it('should render product name', () => {
      const wrapper = mountComponent()
      expect(wrapper.text()).toContain('Lurus API')
    })

    it('should render product tagline', () => {
      const wrapper = mountComponent()
      expect(wrapper.text()).toContain('LLM Gateway')
    })

    it('should render product useCase', () => {
      const wrapper = mountComponent()
      expect(wrapper.text()).toContain('3 lines of code for 50+ AI models')
    })

    it('should render product description', () => {
      const wrapper = mountComponent()
      expect(wrapper.text()).toContain('Unified AI model access')
    })
  })

  describe('external links', () => {
    it('should have rel="noopener noreferrer" for external URLs', () => {
      const wrapper = mountComponent()
      const link = wrapper.find('a')
      expect(link.attributes('rel')).toContain('noopener')
      expect(link.attributes('rel')).toContain('noreferrer')
    })

    it('should open external URLs in new tab', () => {
      const wrapper = mountComponent()
      const link = wrapper.find('a')
      expect(link.attributes('target')).toBe('_blank')
    })

    it('should NOT add target/rel for hash URLs', () => {
      const product = createMockProduct({ url: '#' })
      const wrapper = mountComponent(product)
      const link = wrapper.find('a')
      expect(link.attributes('target')).toBeUndefined()
      expect(link.attributes('rel')).toBeUndefined()
    })
  })

  describe('feature tags', () => {
    it('should display at most 2 feature tags', () => {
      const wrapper = mountComponent()
      const tags = wrapper.findAll('[data-testid="feature-tag"]')
      expect(tags).toHaveLength(2)
    })

    it('should display overflow count when features exceed 2', () => {
      const product = createMockProduct({
        features: ['A', 'B', 'C', 'D'],
      })
      const wrapper = mountComponent(product)
      expect(wrapper.text()).toContain('+2')
    })

    it('should NOT display overflow count when features are 2 or fewer', () => {
      const product = createMockProduct({
        features: ['A', 'B'],
      })
      const wrapper = mountComponent(product)
      const tags = wrapper.findAll('[data-testid="feature-tag"]')
      expect(tags).toHaveLength(2)
      // No overflow span should exist (only 2 features shown, no extras)
      const overflowSpans = wrapper.findAll('.text-ink-300')
      const hasOverflow = overflowSpans.some(s => /^\+\d+$/.test(s.text().trim()))
      expect(hasOverflow).toBe(false)
    })
  })

  describe('statistics display', () => {
    it('should display stats value', () => {
      const wrapper = mountComponent()
      expect(wrapper.text()).toContain('99.9%')
    })

    it('should display stats label', () => {
      const wrapper = mountComponent()
      expect(wrapper.text()).toContain('Availability')
    })
  })

  describe('accessibility', () => {
    it('should have aria-hidden on decorative SVG icons', () => {
      const wrapper = mountComponent()
      const svgs = wrapper.findAll('svg[aria-hidden="true"]')
      expect(svgs.length).toBeGreaterThan(0)
    })

    it('should have data-testid="product-card" on root element', () => {
      const wrapper = mountComponent()
      expect(wrapper.find('[data-testid="product-card"]').exists()).toBe(true)
    })
  })

  describe('product color', () => {
    it('should apply product-specific card class', () => {
      const wrapper = mountComponent()
      expect(wrapper.find('.card-api').exists()).toBe(true)
    })

    it('should apply correct class for lucrum product', () => {
      const product = createMockProduct({ id: 'lucrum' })
      const wrapper = mountComponent(product)
      expect(wrapper.find('.card-lucrum').exists()).toBe(true)
    })

    it('should apply correct class for switch product', () => {
      const product = createMockProduct({ id: 'switch' })
      const wrapper = mountComponent(product)
      expect(wrapper.find('.card-switch').exists()).toBe(true)
    })
  })

  describe('icon rendering', () => {
    it('should render icon with product background color', () => {
      const wrapper = mountComponent()
      const iconContainer = wrapper.find('[data-testid="product-icon"]')
      expect(iconContainer.exists()).toBe(true)
      expect(iconContainer.attributes('style')).toContain('#6B8BA4')
    })
  })

  describe('CTA button', () => {
    it('should display CTA text', () => {
      const wrapper = mountComponent()
      expect(wrapper.text()).toContain('了解更多')
    })

    it('should have CTA arrow icon', () => {
      const wrapper = mountComponent()
      const ctaArrow = wrapper.find('[data-testid="cta-arrow"]')
      expect(ctaArrow.exists()).toBe(true)
    })
  })

  describe('showcase area integration', () => {
    it('should render showcase area when product has showcase data', () => {
      const product = createMockProduct({
        showcase: {
          type: 'code',
          fallbackCode: 'curl test',
          fallbackLanguage: 'bash',
          fallbackAriaLabel: 'Test code',
        },
      })
      const wrapper = mountComponent(product)
      expect(wrapper.find('[data-testid="showcase-area"]').exists()).toBe(true)
    })

    it('should not render showcase area when product has no showcase data', () => {
      const product = createMockProduct()
      // No showcase field
      const wrapper = mountComponent(product)
      expect(wrapper.find('[data-testid="showcase-area"]').exists()).toBe(false)
    })

    it('should render features list for features showcase type', () => {
      const product = createMockProduct({
        showcase: {
          type: 'features',
          fallbackFeatures: ['Feature A', 'Feature B'],
        },
      })
      const wrapper = mountComponent(product)
      const features = wrapper.findAll('[data-testid="showcase-feature"]')
      expect(features).toHaveLength(2)
    })
  })
})
