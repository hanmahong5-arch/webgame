/**
 * Testimonials Data
 * Initial placeholder testimonials for social proof.
 * Replace with real customer quotes as they become available.
 */

export interface Testimonial {
  quote: string
  author: string
  role: string
  product: string
}

export const testimonials: Testimonial[] = [
  {
    quote: '从 5 个不同 API 提供商整合到 Lurus API 后，我们的 LLM 调用成本降低了 30%，故障恢复时间从分钟级缩短到秒级。',
    author: '张工',
    role: 'AI 应用负责人',
    product: 'Lurus API',
  },
  {
    quote: 'Kova 的 WAL 持久化让我们的 Agent 在服务器重启后能自动恢复执行，这在生产环境中是不可或缺的。',
    author: '李开发',
    role: '全栈工程师',
    product: 'Kova SDK',
  },
  {
    quote: '用 Creator 处理视频内容，从下载到发布只需要点几下鼠标。以前需要半天的工作现在 10 分钟搞定。',
    author: '王编辑',
    role: '内容创作者',
    product: 'Lurus Creator',
  },
]
