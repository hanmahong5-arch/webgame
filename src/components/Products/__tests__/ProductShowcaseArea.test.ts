import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ProductShowcaseArea from '../ProductShowcaseArea.vue'
import type { ProductShowcase } from '../../../types/products'

describe('ProductShowcaseArea', () => {
  const mountComponent = (showcase?: ProductShowcase) => {
    return mount(ProductShowcaseArea, {
      props: { showcase },
    })
  }

  describe('no showcase data', () => {
    it('should render nothing when showcase is undefined', () => {
      const wrapper = mountComponent(undefined)
      expect(wrapper.find('[data-testid="showcase-area"]').exists()).toBe(false)
    })
  })

  describe('screenshot mode', () => {
    const screenshotShowcase: ProductShowcase = {
      type: 'screenshot',
      screenshotSrc: '/images/lucrum-editor.webp',
      screenshotAlt: 'Lucrum editor screenshot',
      fallbackCode: 'def strategy(): pass',
      fallbackLanguage: 'bash',
      fallbackAriaLabel: 'Fallback code',
    }

    it('should render an image when screenshotSrc is provided', () => {
      const wrapper = mountComponent(screenshotShowcase)
      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('/images/lucrum-editor.webp')
    })

    it('should apply lazy loading to the image', () => {
      const wrapper = mountComponent(screenshotShowcase)
      const img = wrapper.find('img')
      expect(img.attributes('loading')).toBe('lazy')
    })

    it('should set alt text on the image', () => {
      const wrapper = mountComponent(screenshotShowcase)
      const img = wrapper.find('img')
      expect(img.attributes('alt')).toBe('Lucrum editor screenshot')
    })

    it('should switch to code fallback when image fails to load', async () => {
      const wrapper = mountComponent(screenshotShowcase)
      const img = wrapper.find('img')
      // Trigger image error
      await img.trigger('error')
      // Image should no longer be visible, fallback should show
      expect(wrapper.find('img').exists()).toBe(false)
      expect(wrapper.find('.code-showcase').exists()).toBe(true)
    })

    it('should show code fallback when screenshotSrc is empty string', () => {
      const emptyScreenshot: ProductShowcase = {
        ...screenshotShowcase,
        screenshotSrc: '',
      }
      const wrapper = mountComponent(emptyScreenshot)
      expect(wrapper.find('img').exists()).toBe(false)
      expect(wrapper.find('.code-showcase').exists()).toBe(true)
    })
  })

  describe('code mode', () => {
    const codeShowcase: ProductShowcase = {
      type: 'code',
      fallbackCode: 'curl https://api.lurus.cn/v1/models',
      fallbackLanguage: 'bash',
      fallbackAriaLabel: 'API curl example',
    }

    it('should render CodeShowcase component', () => {
      const wrapper = mountComponent(codeShowcase)
      expect(wrapper.find('.code-showcase').exists()).toBe(true)
    })

    it('should pass correct aria-label to CodeShowcase', () => {
      const wrapper = mountComponent(codeShowcase)
      const showcase = wrapper.find('[role="region"]')
      expect(showcase.attributes('aria-label')).toBe('API curl example')
    })
  })

  describe('features mode', () => {
    const featuresShowcase: ProductShowcase = {
      type: 'features',
      fallbackFeatures: [
        'Multi-domain management',
        'SPF/DKIM/DMARC',
        'China delivery optimization',
        'E2E TLS encryption',
      ],
    }

    it('should render feature list items', () => {
      const wrapper = mountComponent(featuresShowcase)
      const items = wrapper.findAll('[data-testid="showcase-feature"]')
      expect(items).toHaveLength(4)
    })

    it('should display feature text', () => {
      const wrapper = mountComponent(featuresShowcase)
      expect(wrapper.text()).toContain('Multi-domain management')
      expect(wrapper.text()).toContain('SPF/DKIM/DMARC')
    })

    it('should render nothing when fallbackFeatures is empty', () => {
      const emptyFeatures: ProductShowcase = {
        type: 'features',
        fallbackFeatures: [],
      }
      const wrapper = mountComponent(emptyFeatures)
      const items = wrapper.findAll('[data-testid="showcase-feature"]')
      expect(items).toHaveLength(0)
    })
  })

  describe('showcase area wrapper', () => {
    it('should have data-testid="showcase-area" when showcase data exists', () => {
      const wrapper = mountComponent({
        type: 'code',
        fallbackCode: 'echo hello',
        fallbackLanguage: 'bash',
        fallbackAriaLabel: 'test',
      })
      expect(wrapper.find('[data-testid="showcase-area"]').exists()).toBe(true)
    })
  })
})
