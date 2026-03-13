import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import StatsDisplay from '../StatsDisplay.vue'
import { stats } from '../../../data/stats'

describe('StatsDisplay', () => {
  const mountComponent = () => {
    return mount(StatsDisplay)
  }

  describe('section structure', () => {
    it('should render a section element', () => {
      const wrapper = mountComponent()
      const section = wrapper.find('section')
      expect(section.exists()).toBe(true)
    })

    it('should have aria-label for accessibility', () => {
      const wrapper = mountComponent()
      const section = wrapper.find('section')
      expect(section.attributes('aria-label')).toBeTruthy()
    })
  })

  describe('stats rendering', () => {
    it('should render exactly 4 stat items', () => {
      const wrapper = mountComponent()
      const statItems = wrapper.findAll('[data-testid="stat-item"]')
      expect(statItems).toHaveLength(4)
    })

    it('should display stat values from data source', () => {
      const wrapper = mountComponent()
      const text = wrapper.text()
      stats.forEach((stat) => {
        expect(text).toContain(stat.value)
      })
    })

    it('should display stat labels from data source', () => {
      const wrapper = mountComponent()
      const text = wrapper.text()
      stats.forEach((stat) => {
        expect(text).toContain(stat.label)
      })
    })

    it('should apply product-specific color classes to values', () => {
      const wrapper = mountComponent()
      const statItems = wrapper.findAll('[data-testid="stat-item"]')
      statItems.forEach((item, index) => {
        const valueEl = item.find('[data-testid="stat-value"]')
        expect(valueEl.classes()).toContain(stats[index].color)
      })
    })
  })

  describe('design system', () => {
    it('should use border-sketchy on stat cards', () => {
      const wrapper = mountComponent()
      const statItems = wrapper.findAll('[data-testid="stat-item"]')
      statItems.forEach((item) => {
        expect(item.classes()).toContain('border-sketchy')
      })
    })

    it('should use bg-cream-50 on stat cards', () => {
      const wrapper = mountComponent()
      const statItems = wrapper.findAll('[data-testid="stat-item"]')
      statItems.forEach((item) => {
        expect(item.classes()).toContain('bg-cream-50')
      })
    })

    it('should use text-phi-2xl on stat values', () => {
      const wrapper = mountComponent()
      const values = wrapper.findAll('[data-testid="stat-value"]')
      values.forEach((value) => {
        expect(value.classes()).toContain('text-phi-2xl')
      })
    })

    it('should use text-ink-500 on stat labels', () => {
      const wrapper = mountComponent()
      const labels = wrapper.findAll('[data-testid="stat-label"]')
      labels.forEach((label) => {
        expect(label.classes()).toContain('text-ink-500')
      })
    })
  })

  describe('scroll reveal', () => {
    it('should have reveal-stagger class on the stats grid', () => {
      const wrapper = mountComponent()
      const grid = wrapper.find('.reveal-stagger')
      expect(grid.exists()).toBe(true)
    })
  })

  describe('accessibility', () => {
    it('should have decorative elements with aria-hidden', () => {
      const wrapper = mountComponent()
      const decorative = wrapper.findAll('[aria-hidden="true"]')
      expect(decorative.length).toBeGreaterThan(0)
    })
  })

  describe('responsive layout', () => {
    it('should use grid-cols-2 for mobile layout', () => {
      const wrapper = mountComponent()
      const grid = wrapper.find('.grid')
      expect(grid.classes()).toContain('grid-cols-2')
    })

    it('should use md:grid-cols-4 for desktop layout', () => {
      const wrapper = mountComponent()
      const grid = wrapper.find('.grid')
      expect(grid.classes()).toContain('md:grid-cols-4')
    })
  })
})
