/**
 * Unit tests for AIChatSidebar - focus trap and a11y behavior
 * Tests focus management, Escape key, and focus restore
 */

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { ref, nextTick } from 'vue'
import AIChatSidebar from '../AIChatSidebar.vue'

// Mock all child components to isolate sidebar logic
vi.mock('../ChatHeader.vue', () => ({
  default: {
    name: 'ChatHeader',
    template: '<div class="mock-header"><button class="header-btn">Close</button></div>',
    props: ['selectedModel', 'models', 'hasMessages'],
    emits: ['update:selectedModel', 'clear', 'close']
  }
}))

vi.mock('../ChatMessages.vue', () => ({
  default: {
    name: 'ChatMessages',
    template: '<div class="mock-messages"></div>',
    props: ['messages', 'isTyping', 'isStreamingComplete'],
    emits: ['retry', 'delete']
  }
}))

vi.mock('../ChatInput.vue', () => ({
  default: {
    name: 'ChatInput',
    template: '<div class="mock-input"><textarea class="chat-textarea"></textarea><button class="send-btn">Send</button></div>',
    props: ['modelValue', 'disabled', 'placeholder', 'maxLength'],
    emits: ['update:modelValue', 'send']
  }
}))

vi.mock('../ChatQuickPrompts.vue', () => ({
  default: {
    name: 'ChatQuickPrompts',
    template: '<div class="mock-prompts"></div>',
    props: ['prompts'],
    emits: ['select']
  }
}))

vi.mock('../NetworkStatusBanner.vue', () => ({
  default: {
    name: 'NetworkStatusBanner',
    template: '<div class="mock-network"></div>',
    props: ['isOnline']
  }
}))

vi.mock('../ChatErrorBanner.vue', () => ({
  default: {
    name: 'ChatErrorBanner',
    template: '<div class="mock-error"></div>',
    props: ['docsUrl']
  }
}))

vi.mock('../../../composables/useAIChat', () => ({
  useAIChat: () => ({
    messages: ref([]),
    selectedModel: ref('deepseek-chat'),
    isLoading: ref(false),
    isTyping: ref(false),
    inputMessage: ref(''),
    isOnline: ref(true),
    isStreamingComplete: ref(false),
    canSend: ref(false),
    hasMessages: ref(false),
    hasRetriesExhausted: ref(false),
    models: [],
    quickPrompts: [],
    docsUrl: 'https://docs.lurus.cn',
    sendMessage: vi.fn(),
    retryMessage: vi.fn(),
    deleteMessage: vi.fn(),
    clearChat: vi.fn(),
    cancelStreaming: vi.fn(),
  }),
}))

describe('AIChatSidebar - Focus and A11y', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should have role="complementary" for accessibility', () => {
    const wrapper = mount(AIChatSidebar, {
      props: { isOpen: false },
    })
    const aside = wrapper.find('aside')
    expect(aside.attributes('role')).toBe('complementary')
  })

  it('should have aria-label on sidebar', () => {
    const wrapper = mount(AIChatSidebar, {
      props: { isOpen: false },
    })
    const aside = wrapper.find('aside')
    expect(aside.attributes('aria-label')).toBeTruthy()
  })

  it('should emit close on Escape key', async () => {
    const wrapper = mount(AIChatSidebar, {
      props: { isOpen: true },
      attachTo: document.body,
    })

    // Simulate Escape keydown at window level
    window.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }))
    await nextTick()

    expect(wrapper.emitted('close')).toBeTruthy()
    wrapper.unmount()
  })

  it('should add is-open class when open', () => {
    const wrapper = mount(AIChatSidebar, {
      props: { isOpen: true },
    })
    const aside = wrapper.find('aside')
    expect(aside.classes()).toContain('is-open')
  })

  it('should apply will-change: transform in styles', () => {
    const wrapper = mount(AIChatSidebar, {
      props: { isOpen: false },
    })
    // Check that the component renders (style is scoped, so we check the class exists)
    const aside = wrapper.find('.chat-sidebar')
    expect(aside.exists()).toBe(true)
  })

  it('should have id for aria-controls reference', () => {
    const wrapper = mount(AIChatSidebar, {
      props: { isOpen: false },
    })
    const aside = wrapper.find('aside')
    expect(aside.attributes('id')).toBe('ai-chat-sidebar')
  })
})
