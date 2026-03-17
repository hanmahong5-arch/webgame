import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import HeroSection from '../HeroSection.vue'

describe('HeroSection', () => {
  describe('two-column layout structure', () => {
    it('should render left content area and right slot area', () => {
      const wrapper = mount(HeroSection)

      expect(wrapper.find('.hero-left').exists()).toBe(true)
      expect(wrapper.find('.hero-right').exists()).toBe(true)
    })

    it('should render both columns inside hero-grid container', () => {
      const wrapper = mount(HeroSection)

      const grid = wrapper.find('.hero-grid')
      expect(grid.exists()).toBe(true)
      expect(grid.find('.hero-left').exists()).toBe(true)
      expect(grid.find('.hero-right').exists()).toBe(true)
    })
  })

  describe('semantic HTML and accessibility', () => {
    it('should wrap content in section with aria-label="Hero"', () => {
      const wrapper = mount(HeroSection)

      const section = wrapper.find('section')
      expect(section.exists()).toBe(true)
      expect(section.attributes('aria-label')).toBe('Hero')
    })

    it('should render main headline as h1', () => {
      const wrapper = mount(HeroSection)

      const h1 = wrapper.find('h1')
      expect(h1.exists()).toBe(true)
    })

    it('should contain unified AI gateway positioning in h1', () => {
      const wrapper = mount(HeroSection)

      const h1 = wrapper.find('h1')
      const text = h1.text()
      expect(text).toContain('AI')
      expect(text).toContain('模型')
    })
  })

  describe('CTA buttons', () => {
    it('should render primary CTA linking to api.lurus.cn', () => {
      const wrapper = mount(HeroSection)

      const primaryCta = wrapper.find('a[href="https://api.lurus.cn"]')
      expect(primaryCta.exists()).toBe(true)
      expect(primaryCta.text()).toContain('获取 API Key')
      expect(primaryCta.attributes('target')).toBe('_blank')
      expect(primaryCta.attributes('rel')).toBe('noopener noreferrer')
    })

    it('should render secondary CTA linking to docs.lurus.cn', () => {
      const wrapper = mount(HeroSection)

      const secondaryCta = wrapper.find('a[href="https://docs.lurus.cn"]')
      expect(secondaryCta.exists()).toBe(true)
      expect(secondaryCta.text()).toContain('查看文档')
      expect(secondaryCta.attributes('target')).toBe('_blank')
      expect(secondaryCta.attributes('rel')).toBe('noopener noreferrer')
    })
  })

  describe('slot mechanism', () => {
    it('should render custom content passed to right slot', () => {
      const wrapper = mount(HeroSection, {
        slots: {
          right: '<div class="test-slot-content">Custom Tech Demo</div>',
        },
      })

      const rightCol = wrapper.find('.hero-right')
      expect(rightCol.find('.test-slot-content').exists()).toBe(true)
      expect(rightCol.text()).toContain('Custom Tech Demo')
    })

    it('should render empty right area when no slot content provided', () => {
      const wrapper = mount(HeroSection)

      const rightCol = wrapper.find('.hero-right')
      expect(rightCol.exists()).toBe(true)
      // No visible text content when slot is empty
      expect(rightCol.text().trim()).toBe('')
    })
  })

  describe('product tags', () => {
    it('should render all product items', () => {
      const wrapper = mount(HeroSection)

      const productNames = ['Lurus API', 'GuShen', 'Lurus Switch']
      for (const name of productNames) {
        expect(wrapper.text()).toContain(name)
      }
    })

    it('should render colored dots for each product', () => {
      const wrapper = mount(HeroSection)

      // Infra products use w-3 h-3 dots; app products use w-2.5 h-2.5 dots
      const infraDots = wrapper.findAll('.w-3.h-3.rounded-full').filter(
        (d) => !d.classes().some((c) => c.includes('animate-float') || c.includes('bg-ochre'))
      )
      const appDots = wrapper.findAll('.w-2\\.5.h-2\\.5.rounded-full')
      // Total product dots = infra (4) + app (4) = 8
      expect(infraDots.length + appDots.length).toBe(8)
    })
  })
})
