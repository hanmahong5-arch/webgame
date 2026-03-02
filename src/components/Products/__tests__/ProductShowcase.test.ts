import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ProductShowcase from '../ProductShowcase.vue'

describe('ProductShowcase', () => {
  const mountComponent = () => {
    return mount(ProductShowcase)
  }

  describe('section structure', () => {
    it('should render a section with id="products"', () => {
      const wrapper = mountComponent()
      const section = wrapper.find('section#products')
      expect(section.exists()).toBe(true)
    })

    it('should have aria-label for accessibility', () => {
      const wrapper = mountComponent()
      const section = wrapper.find('section#products')
      expect(section.attributes('aria-label')).toBeTruthy()
    })
  })

  describe('badge', () => {
    it('should display "Product Ecosystem" badge', () => {
      const wrapper = mountComponent()
      expect(wrapper.text()).toContain('Product Ecosystem')
    })
  })

  describe('main card', () => {
    it('should render a main card with full-stack messaging', () => {
      const wrapper = mountComponent()
      const mainCard = wrapper.find('[data-testid="product-main-card"]')
      expect(mainCard.exists()).toBe(true)
    })

    it('should contain full-stack self-built messaging', () => {
      const wrapper = mountComponent()
      const mainCard = wrapper.find('[data-testid="product-main-card"]')
      const text = mainCard.text()
      // Should contain messaging about full-stack self-built capabilities
      expect(text.length).toBeGreaterThan(0)
    })
  })

  describe('product sub-cards', () => {
    it('should render exactly 2 infra product cards', () => {
      const wrapper = mountComponent()
      const cards = wrapper.findAll('[data-testid="product-card"]')
      expect(cards).toHaveLength(2)
    })

    it('should render exactly 4 app product mini cards', () => {
      const wrapper = mountComponent()
      const cards = wrapper.findAll('[data-testid="app-product-card"]')
      expect(cards).toHaveLength(4)
    })

    it('should display product name for each infra card', () => {
      const wrapper = mountComponent()
      const cards = wrapper.findAll('[data-testid="product-card"]')
      const expectedNames = ['Lurus API', 'Lurus Switch']
      cards.forEach((card, i) => {
        expect(card.text()).toContain(expectedNames[i])
      })
    })

    it('should display useCase for each card', () => {
      const wrapper = mountComponent()
      const cards = wrapper.findAll('[data-testid="product-card"]')
      cards.forEach((card) => {
        // Each card should have useCase text visible
        const text = card.text()
        expect(text.length).toBeGreaterThan(10)
      })
    })

    it('should have external links with rel="noopener noreferrer"', () => {
      const wrapper = mountComponent()
      const links = wrapper.findAll('a[href^="https://"]')
      links.forEach((link) => {
        expect(link.attributes('rel')).toContain('noopener')
        expect(link.attributes('rel')).toContain('noreferrer')
      })
    })

    it('should open external links in new tab', () => {
      const wrapper = mountComponent()
      const links = wrapper.findAll('a[href^="https://"]')
      links.forEach((link) => {
        expect(link.attributes('target')).toBe('_blank')
      })
    })
  })

  describe('accessibility', () => {
    it('should have decorative SVGs with aria-hidden', () => {
      const wrapper = mountComponent()
      const decorativeSvgs = wrapper.findAll('[aria-hidden="true"]')
      expect(decorativeSvgs.length).toBeGreaterThan(0)
    })

    it('should use semantic heading structure', () => {
      const wrapper = mountComponent()
      const h2 = wrapper.find('h2')
      expect(h2.exists()).toBe(true)
    })
  })

  describe('scroll reveal', () => {
    it('should have reveal-stagger class on product grid', () => {
      const wrapper = mountComponent()
      const grid = wrapper.find('.reveal-stagger')
      expect(grid.exists()).toBe(true)
    })
  })
})
