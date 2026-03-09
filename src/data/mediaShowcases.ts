/**
 * Media showcase data for Home page product demos
 * Each entry represents a feature demo section with text + media placeholder
 */

export interface MediaShowcaseItem {
  id: string
  title: string
  description: string
  detail: string
  /** Future: path to GIF/video file */
  mediaSrc?: string
  mediaAlt: string
  color: string
}

export const mediaShowcases: MediaShowcaseItem[] = [
  {
    id: 'switch',
    title: '一个面板，管理所有 AI 工具',
    description: '不再在多个应用之间来回切换。配置、密钥、代理 — 全部集中管理。',
    detail: '支持 Cursor、Windsurf、Cline 等主流 AI 编程工具，统一配置代理和模型路由。',
    mediaAlt: 'Lurus Switch 工具管理演示',
    color: '#C67B5C',
  },
  {
    id: 'api',
    title: '一个接口，接入 50+ AI 模型',
    description: '不再为每个模型单独注册和充值。一个 API Key，统一调用格式。',
    detail: '兼容 OpenAI 格式，零迁移成本接入 Claude、GPT、Gemini、DeepSeek 等。',
    mediaAlt: 'Lurus API 模型接入演示',
    color: '#6B8BA4',
  },
  {
    id: 'acest',
    title: '一个快捷键，唤出你的 AI 助手',
    description: '无论在哪个应用里，都能随时调出 AI — 选中文本，按下快捷键，即刻获取帮助。',
    detail: '全局快捷键调用，支持翻译、总结、改写、编程辅助等多种场景。',
    mediaAlt: 'ACEST 快捷键调用演示',
    color: '#5C7A8B',
  },
]
