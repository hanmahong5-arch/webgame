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
    title: 'Rust 原生，极致轻量',
    description: 'ACEST 用 Rust 从零构建 — 没有 Electron 臃肿，没有 GC 停顿。常驻内存不到 8MB，响应快于你的手速。',
    detail: '零垃圾回收、确定性延迟、内存安全。快捷键唤醒到 AI 响应 < 50ms，本地数据处理保护隐私。',
    mediaAlt: 'ACEST Rust 原生性能展示',
    color: '#5C7A8B',
  },
]
