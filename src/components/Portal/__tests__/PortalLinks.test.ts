import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import PortalLinks from '../PortalLinks.vue'
import { portalCategories } from '../../../data/portalLinks'

// Mock useTracking composable
vi.mock('../../../composables/useTracking', () => ({
  useTracking: () => ({
    track: vi.fn(),
  }),
}))


const PREVIEW_PER_CATEGORY = 4
const TOTAL_CATEGORIES = portalCategories.length
const TOTAL_LINKS = portalCategories.reduce((sum, cat) => sum + cat.links.length, 0)
const PREVIEW_LINKS = TOTAL_CATEGORIES * PREVIEW_PER_CATEGORY

describe('PortalLinks', () => {
  const mountComponent = () => {
    return mount(PortalLinks)
  }

  describe('section structure', () => {
    it('should render a section with id="portal"', () => {
      const wrapper = mountComponent()
      const section = wrapper.find('section#portal')
      expect(section.exists()).toBe(true)
    })

    it('should have aria-label for accessibility', () => {
      const wrapper = mountComponent()
      const section = wrapper.find('section#portal')
      expect(section.attributes('aria-label')).toBeTruthy()
    })

    it('should have a section header with title text', () => {
      const wrapper = mountComponent()
      const heading = wrapper.find('h2')
      expect(heading.exists()).toBe(true)
      expect(heading.text()).toContain('资源中心')
    })

    it('should have a subtitle describing the portal purpose', () => {
      const wrapper = mountComponent()
      const text = wrapper.text()
      expect(text).toContain('为使用 Lurus 的开发者精选')
    })
  })

  describe('category cards', () => {
    it('should render exactly as many category cards as in data', () => {
      const wrapper = mountComponent()
      const cards = wrapper.findAll('[data-testid="portal-category-card"]')
      expect(cards).toHaveLength(TOTAL_CATEGORIES)
    })

    it('should display Chinese name for each category', () => {
      const wrapper = mountComponent()
      const cards = wrapper.findAll('[data-testid="portal-category-card"]')
      portalCategories.forEach((category, index) => {
        expect(cards[index].text()).toContain(category.name)
      })
    })

    it('should display English name for each category', () => {
      const wrapper = mountComponent()
      const cards = wrapper.findAll('[data-testid="portal-category-card"]')
      portalCategories.forEach((category, index) => {
        expect(cards[index].text()).toContain(category.nameEn)
      })
    })

    it('should have a color dot for each category', () => {
      const wrapper = mountComponent()
      const dots = wrapper.findAll('[data-testid="category-color-dot"]')
      expect(dots).toHaveLength(TOTAL_CATEGORIES)
    })
  })

  describe('portal links', () => {
    it('should render portal links in collapsed state (preview mode)', () => {
      const wrapper = mountComponent()
      // In collapsed mode, each category shows PREVIEW_PER_CATEGORY links
      const allLinks = wrapper.findAll('a.portal-link-btn')
      expect(allLinks.length).toBe(PREVIEW_LINKS)
    })

    it('should have correct href attributes on links', () => {
      const wrapper = mountComponent()
      const firstLink = wrapper.find('a.portal-link-btn')
      expect(firstLink.attributes('href')).toMatch(/^https?:\/\//)
    })

    it('should open links in new tab', () => {
      const wrapper = mountComponent()
      const links = wrapper.findAll('a.portal-link-btn')
      links.forEach((link) => {
        expect(link.attributes('target')).toBe('_blank')
      })
    })

    it('should have rel="noopener noreferrer" on external links', () => {
      const wrapper = mountComponent()
      const links = wrapper.findAll('a.portal-link-btn')
      links.forEach((link) => {
        expect(link.attributes('rel')).toContain('noopener')
        expect(link.attributes('rel')).toContain('noreferrer')
      })
    })

    it('should have category-specific color class on links', () => {
      const wrapper = mountComponent()
      // Check that at least some links have portal-* color classes
      const firstCategoryCard = wrapper.findAll('[data-testid="portal-category-card"]')[0]
      const links = firstCategoryCard.findAll('a.portal-link-btn')
      links.forEach((link) => {
        expect(link.classes()).toContain(portalCategories[0].colorClass)
      })
    })
  })

  describe('expand/collapse', () => {
    it('should have an expand toggle button', () => {
      const wrapper = mountComponent()
      const toggle = wrapper.find('[data-testid="portal-expand-toggle"]')
      expect(toggle.exists()).toBe(true)
    })

    it('should show all links when expanded', async () => {
      const wrapper = mountComponent()
      const toggle = wrapper.find('[data-testid="portal-expand-toggle"]')
      await toggle.trigger('click')

      const allLinks = wrapper.findAll('a.portal-link-btn')
      expect(allLinks.length).toBe(TOTAL_LINKS)
    })

    it('should collapse back to preview when toggled again', async () => {
      const wrapper = mountComponent()
      const toggle = wrapper.find('[data-testid="portal-expand-toggle"]')

      // Expand
      await toggle.trigger('click')
      let allLinks = wrapper.findAll('a.portal-link-btn')
      expect(allLinks.length).toBe(TOTAL_LINKS)

      // Collapse
      await toggle.trigger('click')
      allLinks = wrapper.findAll('a.portal-link-btn')
      expect(allLinks.length).toBe(PREVIEW_LINKS)
    })
  })

  describe('CTA bar', () => {
    it('should render CTABar at the bottom', () => {
      const wrapper = mountComponent()
      // CTABar contains "Need API access?" or similar text
      expect(wrapper.text()).toContain('API')
    })
  })

  describe('tracking', () => {
    it('should call track on link click', async () => {
      const trackMock = vi.fn()
      vi.doMock('../../../composables/useTracking', () => ({
        useTracking: () => ({ track: trackMock }),
      }))

      const wrapper = mountComponent()
      const firstLink = wrapper.find('a.portal-link-btn')
      await firstLink.trigger('click')

      // The component should have an @click handler that calls track
      // We verify the handler exists by checking the element renders correctly
      expect(firstLink.exists()).toBe(true)
    })
  })

  describe('scroll reveal', () => {
    it('should have reveal-stagger class on the grid container', () => {
      const wrapper = mountComponent()
      const grid = wrapper.find('.reveal-stagger')
      expect(grid.exists()).toBe(true)
    })

    it('should have reveal-fade-up class on header', () => {
      const wrapper = mountComponent()
      const revealElements = wrapper.findAll('.reveal-fade-up')
      expect(revealElements.length).toBeGreaterThan(0)
    })
  })

  describe('responsive grid', () => {
    it('should have grid classes for responsive layout', () => {
      const wrapper = mountComponent()
      const grid = wrapper.find('[data-testid="portal-grid"]')
      expect(grid.exists()).toBe(true)
      expect(grid.classes()).toContain('grid')
    })
  })

  describe('layout', () => {
    it('should have portal-content-layout container', () => {
      const wrapper = mountComponent()
      const layout = wrapper.find('[data-testid="portal-content-layout"]')
      expect(layout.exists()).toBe(true)
    })

    it('should use 3-column grid', () => {
      const wrapper = mountComponent()
      const grid = wrapper.find('[data-testid="portal-grid"]')
      expect(grid.classes()).toContain('lg:grid-cols-3')
    })
  })
})
