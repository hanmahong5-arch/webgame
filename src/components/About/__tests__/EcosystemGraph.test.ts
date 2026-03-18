import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import EcosystemGraph from '../EcosystemGraph.vue'

describe('EcosystemGraph', () => {
  it('should render with data-testid', () => {
    const wrapper = mount(EcosystemGraph)
    expect(wrapper.find('[data-testid="ecosystem-graph"]').exists()).toBe(true)
  })

  it('should render an SVG element', () => {
    const wrapper = mount(EcosystemGraph)
    expect(wrapper.find('svg').exists()).toBe(true)
  })

  it('should have accessible aria-label on SVG', () => {
    const wrapper = mount(EcosystemGraph)
    const svg = wrapper.find('svg')
    expect(svg.attributes('role')).toBe('img')
    expect(svg.attributes('aria-label')).toBeTruthy()
  })

  it('should render center Lurus node', () => {
    const wrapper = mount(EcosystemGraph)
    expect(wrapper.text()).toContain('Lurus')
  })

  it('should render 4 product nodes', () => {
    const wrapper = mount(EcosystemGraph)
    const text = wrapper.text()
    expect(text).toContain('API')
    expect(text).toContain('Lucrum')
    expect(text).toContain('Mail')
    expect(text).toContain('Switch')
  })
})
