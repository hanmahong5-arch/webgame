/**
 * Unit tests for App.vue conditional Chat loading
 * Verifies that AIChatSidebar and ChatFloatingTrigger are only rendered
 * when VITE_CHAT_ENABLED=true
 */

import { describe, it, expect, vi, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h } from 'vue'

// Stub child components to isolate App.vue logic
const AppShellStub = defineComponent({
  name: 'AppShell',
  render() {
    return h('div', { class: 'app-shell' }, [
      h('nav', 'topbar'),
      h('main', { id: 'main-content' }, this.$slots.default?.()),
      h('footer', 'footer'),
    ])
  },
})
const RouterViewStub = defineComponent({ name: 'RouterView', render: () => h('div', 'router-view') })

const ChatSidebarStub = defineComponent({
  name: 'AIChatSidebar',
  props: { isOpen: Boolean },
  render() {
    return h('aside', { 'data-testid': 'chat-sidebar' }, 'chat')
  },
})

const ChatTriggerStub = defineComponent({
  name: 'ChatFloatingTrigger',
  props: { isOpen: Boolean },
  render() {
    return h('button', { 'data-testid': 'chat-trigger' }, 'trigger')
  },
})

describe('App.vue conditional Chat loading', () => {
  afterEach(() => {
    vi.resetModules()
    vi.restoreAllMocks()
  })

  it('should not render Chat components when VITE_CHAT_ENABLED is "false"', async () => {
    vi.stubEnv('VITE_CHAT_ENABLED', 'false')

    // Dynamic import to pick up env stub
    const { default: App } = await import('../App.vue')

    const wrapper = mount(App, {
      global: {
        stubs: {
          AppShell: AppShellStub,
          RouterView: RouterViewStub,
          AIChatSidebar: ChatSidebarStub,
          ChatFloatingTrigger: ChatTriggerStub,
        },
      },
    })

    expect(wrapper.find('[data-testid="chat-sidebar"]').exists()).toBe(false)
    expect(wrapper.find('[data-testid="chat-trigger"]').exists()).toBe(false)
  })

  it('should render Chat components when VITE_CHAT_ENABLED is "true"', async () => {
    vi.stubEnv('VITE_CHAT_ENABLED', 'true')

    const { default: App } = await import('../App.vue')

    const wrapper = mount(App, {
      global: {
        stubs: {
          AppShell: AppShellStub,
          RouterView: RouterViewStub,
          AIChatSidebar: ChatSidebarStub,
          ChatFloatingTrigger: ChatTriggerStub,
        },
      },
    })

    // defineAsyncComponent may need a tick to resolve
    await wrapper.vm.$nextTick()
    // With stubs, the async component resolves to the stub immediately
    expect(wrapper.find('[data-testid="chat-sidebar"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="chat-trigger"]').exists()).toBe(true)
  })

  it('should always render AppShell with main content regardless of Chat flag', async () => {
    vi.stubEnv('VITE_CHAT_ENABLED', 'false')

    const { default: App } = await import('../App.vue')

    const wrapper = mount(App, {
      global: {
        stubs: {
          AppShell: AppShellStub,
          RouterView: RouterViewStub,
          AIChatSidebar: true,
          ChatFloatingTrigger: true,
        },
      },
    })

    expect(wrapper.find('.app-shell').exists()).toBe(true)
    expect(wrapper.find('#main-content').exists()).toBe(true)
  })

  it('should render Skip Link for accessibility', async () => {
    vi.stubEnv('VITE_CHAT_ENABLED', 'false')

    const { default: App } = await import('../App.vue')

    const wrapper = mount(App, {
      global: {
        stubs: {
          AppShell: AppShellStub,
          RouterView: RouterViewStub,
          AIChatSidebar: true,
          ChatFloatingTrigger: true,
        },
      },
    })

    const skipLink = wrapper.find('.skip-link')
    expect(skipLink.exists()).toBe(true)
    expect(skipLink.attributes('href')).toBe('#main-content')
  })
})
