# lurus-www 全面重设计规划 2025

> 竞品参考：mastra.ai / platform.iflow.cn
> 当前版本：纸质手绘风 (cream/ochre/sketchy)
> 目标版本：暗色高级感 + 温暖质感 ("Dark Premium Warm")

---

## 一、竞品核心洞察

### mastra.ai
| 元素 | 做法 |
|------|------|
| 色彩 | 纯黑底 #050505 + 亮绿强调 #7aff78，高对比，科技感极强 |
| 字体 | Geist Mono（等宽）+ Greed（品牌字），代码感强化技术可信度 |
| 布局 | Bento Grid — 多尺寸卡片拼接，扫读效率极高 |
| Hero CTA | `npm create mastra` — 开发者直接上手，零摩擦 |
| 社会证明 | GitHub ⭐ 22.1k 显著展示，开源公信力 |
| 产品展示 | 交互式网格，每卡片有悬停动效+箭头跳转 |
| 定价 | 3层：开源免费 / 云平台（即将定价）/ 企业定制 |

### platform.iflow.cn
| 元素 | 做法 |
|------|------|
| 色彩 | 蓝色科技主色 + 橙色强调，企业感 |
| 背景 | 多层装饰图叠加，营造沉浸感和深度层次 |
| Hero | 中心构图，品牌大图 + 核心价值主张 + 单一大CTA |
| 免费钩子 | "完全免费" 作为最强转化点，反复强调 |
| 用例写法 | 人话描述场景："分析黄金价格" 而非 "调用API接口" |
| CLI 展示 | 页面直接放安装命令，一键复制，降低入门摩擦 |
| 特性网格 | 4宫格图标+文案，快速扫读 |

### 当前 lurus-www 问题诊断
- **品位局限**：cream/sketchy 风格温暖但显"学生作品"，缺乏平台级可信度
- **信息密度不足**：大量留白，产品能力没有充分展示
- **Hero 力度弱**：ValuePropositionHero 文案平，无视觉冲击力
- **无代码示例**：API 产品却不在主页展示 curl/SDK 用法
- **缺乏社会证明**：用户数/请求量/模型数没有显著展示
- **动效陈旧**：仅 scrollReveal，无 hero 级别的视觉叙事动效
- **导航定位不清**：访客不知道 Lurus 是什么，产品矩阵太分散

---

## 二、新设计方向："Dark Premium Warm"

### 核心理念
> 不做冷酷的黑色科技，做有温度的高级平台。
> 暗色赋予专业感，温暖强调色保留 Lurus 的人文气质。

### 三大视觉关键词
1. **Ambient Dark** — 暗色底，带温度（暖黑，不是纯黑）
2. **Glowing Accents** — 产品色作为发光强调，对比强烈
3. **Precision Layout** — Bento Grid + 数据感排版，展示技术实力

---

## 三、新设计系统

### 3.1 色彩系统（全面替换）

```css
/* === 基础背景层 === */
--color-surface-base:    #0D0B09;  /* 暖黑底，比纯黑更有质感 */
--color-surface-raised:  #141210;  /* 卡片底色 */
--color-surface-overlay: #1C1916;  /* 悬浮/弹窗 */
--color-surface-border:  #2A2520;  /* 边框/分割线 */

/* === 文字层 === */
--color-text-primary:    #F5F0E8;  /* 主文字，带暖色调的白 */
--color-text-secondary:  #A89B8B;  /* 次要文字（复用原 ink-300） */
--color-text-muted:      #6B5D4D;  /* 弱化文字 */

/* === 强调色（Lurus 品牌暖色升级） === */
--color-accent-ochre:    #D4A827;  /* 主强调，比原 ochre 更亮 */
--color-accent-glow:     rgba(212, 168, 39, 0.15); /* 光晕效果底 */

/* === 产品色（提亮以适应暗底） === */
--color-product-api:     #7BACC8;  /* 蓝 */
--color-product-lucrum:  #8DAD7A;  /* 绿 */
--color-product-switch:  #D98B6A;  /* 橙 */
--color-product-acest:   #6D9DB0;  /* 青蓝 */
--color-product-memx:    #A8966E;  /* 沙棕 */
--color-product-identity:#A87D99;  /* 紫 */

/* === 渐变 === */
--gradient-hero: radial-gradient(ellipse 80% 60% at 50% -10%,
  rgba(212, 168, 39, 0.12) 0%, transparent 70%);
--gradient-card: linear-gradient(135deg,
  rgba(255,255,255,0.04) 0%, rgba(255,255,255,0.01) 100%);
```

### 3.2 字体系统（升级）

```css
/* 展示标题 — 保留中文书法感但更正式 */
font-display: 'Noto Serif SC', serif;   /* 中文大标题 */

/* UI 正文 — 升级 */
font-body: 'Inter Variable', 'Noto Sans SC', sans-serif;

/* 代码/技术展示 — 新增 */
font-mono: 'Geist Mono', 'JetBrains Mono', monospace;

/* 数字/指标展示 — 新增 */
font-data: 'Inter Variable', monospace;  /* 用 tabular-nums 特性 */
```

> 注：移除 Caveat 手写字体，改为 Noto Serif SC 作为品牌展示字体，
> 保留东方气质但更专业。仅在极少数装饰元素保留手写风。

### 3.3 间距系统（保留 Fibonacci，扩展暗色语境用法）

现有 fib 间距保留不变，新增卡片内部间距规范：
- 卡片内边距：`p-5`（20px）→ `p-6`（24px）标准
- 网格间距：`gap-4`（16px）→ `gap-5`（20px）
- Section 垂直间距：`py-20` ~ `py-28`

### 3.4 卡片/边框系统（替换 sketchy 风格）

```css
/* 标准暗色卡片 */
.card-dark {
  background: var(--gradient-card);
  border: 1px solid var(--color-surface-border);
  border-radius: 12px;
  backdrop-filter: blur(12px);
}

/* 产品高亮卡片（带发光边框） */
.card-glow-{product} {
  border-color: var(--color-product-{product});
  box-shadow: 0 0 20px rgba({product-rgb}, 0.15),
              inset 0 1px 0 rgba(255,255,255,0.06);
}

/* Bento 网格卡片 */
.bento-card {
  background: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  border-radius: 16px;
  overflow: hidden;
  transition: border-color 0.2s, transform 0.2s;
}
.bento-card:hover {
  border-color: var(--color-accent-ochre);
  transform: translateY(-2px);
}
```

### 3.5 按钮系统（替换 btn-hand）

```css
/* 主按钮 — 亮色填充 */
.btn-primary {
  background: var(--color-accent-ochre);
  color: #0D0B09;
  border-radius: 8px;
  font-weight: 600;
  /* 悬停：上移 + 光晕 */
}

/* 次按钮 — 描边 */
.btn-outline {
  border: 1px solid var(--color-surface-border);
  color: var(--color-text-primary);
  border-radius: 8px;
  /* 悬停：边框变强调色 */
}

/* 代码按钮 — 终端风 */
.btn-code {
  font-family: var(--font-mono);
  background: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  /* 含复制图标 */
}
```

---

## 四、页面架构重规划

### 4.1 导航（Navbar）全面升级

**现状问题**：品牌名 + 几个链接，没有产品层级

**新导航结构：**
```
Logo  |  产品 ▾  |  解决方案 ▾  |  定价  |  文档  |  博客      [登录]  [免费开始 →]
```

**产品下拉菜单（Mega Menu）：**
```
┌─────────────────────────────────────────────────────┐
│  个人工具                    开发者 / 平台            │
│  ─────────                  ────────────────        │
│  ACEST Desktop  桌面AI助手   Lurus API   LLM网关     │
│  Lucrum         AI量化交易   Switch      工具管理     │
│  MemX           AI记忆扩展   Identity    认证计费     │
│                             Notification 通知中枢    │
└─────────────────────────────────────────────────────┘
```

**视觉**：毛玻璃背景 (backdrop-blur-xl)，暗色卡片式下拉

### 4.2 全站页面清单

| 路由 | 页面 | 状态 |
|------|------|------|
| `/` | 首页（全面重构） | 重构 |
| `/for-explorers` | 个人用户（To C） | 重构 + 加定价 |
| `/for-entrepreneurs` | 创业者（To B） | 优化 |
| `/for-builders` | 构建者（To B） | 优化 |
| `/pricing` | 定价（仅To C可见完整版）| 重构 |
| `/products/api` | API 产品详情 | **新增** |
| `/products/lucrum` | Lucrum 产品详情 | **新增** |
| `/products/switch` | Switch 产品详情 | **新增** |
| `/products/acest` | ACEST 产品详情 | **新增** |
| `/models` | 模型库 | **新增** |
| `/download` | 下载 | 优化 |
| `/about` | 关于 | 优化 |
| `/blog` | 博客 | **新增**（可先静态）|

---

## 五、首页重构详细设计

### 新首页 Section 顺序

```
S1  Hero — 全屏冲击，定义 Lurus 是什么
S2  社会证明条 — 数字/统计快速建立信任
S3  产品矩阵 Bento — 一屏看懂所有产品
S4  核心能力展示 — API 代码示例 (交互式)
S5  Lucrum 亮点 — 差异化最强产品
S6  生态地图 — 产品间协作关系
S7  用户路径导航 — 我是谁 → 进入对应页
S8  Final CTA
```

---

### S1: Hero（全面重构）

**设计参考**：mastra Hero 的全屏暗色 + 背景光晕，iflow 的中心构图

**布局：**
```
┌──────────────────────────────────────────────────────┐
│  [顶部导航]                                            │
│                                                        │
│         ● ● ● 光晕背景（ochre 渐变，向上发散）          │
│                                                        │
│              [标签] AI 工具平台 · 中文优先              │
│                                                        │
│         让 AI 真正为你所用                              │
│         — 从桌面助手到量化交易                          │
│         — 从 API 网关到记忆引擎                         │
│                                                        │
│      [免费开始 →]    [查看产品演示]                     │
│                                                        │
│  ┌─────────────────────────────────────────────────┐  │
│  │  代码演示窗口（动态打字效果）                       │  │
│  │  curl https://api.lurus.cn/v1/chat/completions  │  │
│  │    -H "Authorization: Bearer $KEY"              │  │
│  │    ...（3秒循环打字动画）                          │  │
│  └─────────────────────────────────────────────────┘  │
│                                                        │
│     ↓ 产品矩阵                                         │
└──────────────────────────────────────────────────────┘
```

**技术实现**：
- 背景：CSS `radial-gradient` 光晕 + SVG 网格点阵（opacity 0.03）
- 代码动效：`useTypingEffect` composable（纯 CSS + JS，无需库）
- 文字：Noto Serif SC 大标题，行高 1.1，letter-spacing -0.02em

---

### S2: 社会证明条（新增）

```
┌─────────────────────────────────────────────────────┐
│  50+ 模型   ·   99.9% 可用性   ·   3行代码接入        │
│  5个产品    ·   全平台支持      ·   7×24 运行          │
└─────────────────────────────────────────────────────┘
```
横向滚动条（无限循环 marquee），半透明暗色背景，数字用 Geist Mono。

---

### S3: 产品矩阵 Bento（核心重构）

**设计参考**：mastra.ai 的多尺寸卡片网格

```
┌───────────────┬──────────┬──────────────────────────┐
│               │  Switch  │                           │
│  Lurus API    │  AI工具  │     Lucrum 谷神           │
│  LLM统一网关  │  管家    │     AI量化交易            │
│  2×1 大卡    │  1×1    │     2×2 超大卡（主推）      │
│               │          │                           │
├───────────────┴──────────┤                           │
│  ACEST Desktop           ├──────────────────────────┤
│  1×1 中卡               │  MemX 记忆扩展             │
│                           │  1×1 中卡               │
└───────────────────────────┴──────────────────────────┘
```

每张卡片：
- 产品名 + 一句话定位
- 代表性数据 or 核心特性 1-2 条
- 悬停：边框发产品色光晕 + 箭头显示
- 点击：跳转产品详情页

---

### S4: API 代码示例（交互式）

**设计参考**：代码编辑器风格面板

```
┌─ bash  ──────────────────────────────────────────────┐
│  # 3行代码，接入50+模型                               │
│  curl https://api.lurus.cn/v1/chat/completions \     │
│    -H "Authorization: Bearer $LURUS_KEY" \           │
│    -d '{"model":"claude-3-5-sonnet","messages":[      │
│           {"role":"user","content":"你好"}]}'         │
└──────────────────────────────────────────────────────┘

[切换语言：bash  Python  JavaScript  Go]
```

语言切换 Tab，对应不同代码片段，纯 Vue 实现无需额外库。

---

### S5: Lucrum 差异化展示（重构）

Lucrum 是最独特的产品（竞品无），用较大篇幅展示：

```
左侧：                              右侧：
"用中文说出你的策略                  [模拟终端/界面截图]
 AI生成可执行的量化代码"
                                    "当5日均线上穿20日均线时买入"
特性列表：                            ↓
✓ 自然语言 → 量化策略                 def strategy(context):
✓ 30+ 金融指标                          ma5 = ta.sma(period=5)
✓ 专业级回测引擎                         ma20 = ta.sma(period=20)
✓ 11个投资流派AI顾问                     if ma5 > ma20: buy()
```

---

### S6: 生态地图（优化现有 EcosystemMap）

展示产品间的协作关系，用连线图：
```
ACEST（桌面感知）→ API（模型调用）→ MemX（结果记忆）
Switch（工具管理）→ API（统一路由）→ 开发者生产力
Identity（认证）→ 所有产品（用户体系统一）
```

---

### S7: 用户路径导航（替换 AudienceStartGuide）

三个大型入口卡片，让访客快速找到自己的位置：

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   我是探索者     │  │   我是创业者     │  │   我是构建者     │
│                 │  │                 │  │                 │
│ 个人工具 · AI   │  │ 团队 · 快速上线 │  │ 开发 · 基础设施 │
│ 桌面体验升级    │  │ 企业级AI能力    │  │ 定制集成        │
│                 │  │                 │  │                 │
│ [开始探索 →]    │  │ [了解方案 →]    │  │ [查看文档 →]    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

---

## 六、To C 产品页（ForExplorers）重构

当前问题：产品卡片单调，右侧视觉占位空间浪费

新设计方向：
- 每个产品用全宽分屏展示（左文字，右交互演示/截图/动效）
- ACEST：右侧展示"浮动面板"截图 + 快捷键动效
- Lucrum：右侧展示代码生成过程（逐字打字动效）
- Switch：右侧展示工具管理面板截图
- MemX：右侧展示记忆图谱可视化

**定价区块**（已移入）：
- 仅展示 Personal 层级的 4 个产品价格
- 卡片设计升级：暗色卡片 + 产品色边框发光

---

## 七、定价页重构

### 受众分层改版

当前：个人/团队/平台 三个Tab
问题：团队/平台是B2B，不应从To C页面链接过来

新方案：
- `/pricing` = 完整定价页，Tab区分三类用户
- To C 产品页的定价区块 = 只展示 Personal 套餐的简化版
- To B CTA 改为 "联系我们定制方案"（已完成）

### 定价页新设计
```
Header: "选择适合你的方案"
↓
[Tab: 个人  |  团队  |  平台企业]
↓
产品卡片（暗色 Bento 布局，Popular卡片发光）
↓
功能对比表（暗色表格，checkbox 替换为 ✓/— 符号）
↓
充值CTA
↓
支付方式
↓
FAQ（手风琴，暗色）
↓
Enterprise CTA（发光卡片）
```

---

## 八、导航与全局 UI 组件升级

### Navbar
- 暗色沉浸式背景，滚动后加毛玻璃 (`backdrop-blur`)
- Logo 左侧，导航中间，登录/注册右侧
- Mega Menu 产品下拉（参见四、4.1）
- 移动端：底部 Tab Bar（不是汉堡菜单）

### Footer
- 暗色背景，4列布局
- 产品列 / 解决方案列 / 资源列 / 公司列
- 底部：ICP备案 + 社交链接 + 版权

### TopBar（广告条）
- 保留，但改为暗色主题，文字更醒目
- 可放：新功能公告、限时优惠

---

## 九、动效体系升级

### 已有（保留优化）
- `useScrollReveal` — 滚动出现动效，升级为更流畅的 cubic-bezier

### 新增（纯 CSS + Vue，不引入 GSAP）

**1. Hero 打字动效**
```ts
// useTypingEffect.ts
// 循环展示多条代码示例，逐字打出
```

**2. 数字计数动效（已有 useCountUp）**
升级为：进入视口时触发，带 easing

**3. 卡片悬停光晕**
```css
.bento-card::before {
  content: '';
  position: absolute;
  inset: -1px;
  border-radius: inherit;
  background: conic-gradient(from var(--angle), transparent 20%,
    var(--product-color) 40%, transparent 60%);
  animation: rotate 4s linear infinite;
  opacity: 0;
  transition: opacity 0.3s;
}
.bento-card:hover::before { opacity: 1; }
```

**4. 背景粒子/网格（轻量）**
纯 CSS SVG 网格点阵 + 极低 opacity，增加深度感

**5. 模型跑马灯（社会证明条）**
CSS `animation: marquee linear infinite` 实现无缝循环

---

## 十、技术方案

### 保留
- Vue 3.5 + TypeScript + vue-router 4
- Vite 6 + Tailwind CSS 4
- Bun 包管理
- nginx 部署架构

### 新增依赖（最小化）
| 包 | 用途 | 大小 |
|----|------|------|
| `@fontsource/geist-mono` | 代码字体 | ~100KB |
| `@fontsource-variable/inter` | 正文可变字体 | ~200KB |
| 无其他依赖 | 动效用纯CSS实现 | — |

### 字体加载策略
```html
<!-- 优先级 1: Inter Variable (正文) -->
<link rel="preload" as="font" href="/fonts/inter-var.woff2">
<!-- 优先级 2: Geist Mono (代码展示) -->
<link rel="preload" as="font" href="/fonts/geist-mono.woff2">
<!-- Noto Serif SC 中文字体按需加载 (subset) -->
```

---

## 十一、实施优先级

### Phase 1 — 设计系统 (基础，1-2天)
1. `main.css` 全量替换：新色彩系统 + 暗色 body
2. 新增：`card-dark`, `bento-card`, `btn-primary`, `btn-outline`, `btn-code`
3. 字体引入：Geist Mono + Inter Variable
4. 移除：`btn-hand`, `card-sketchy`, `border-sketchy`（全站替换）

### Phase 2 — 首页重构 (核心，3-4天)
1. Hero 重构（打字动效 + 背景光晕）
2. 社会证明条（新组件）
3. 产品 Bento Grid（新组件 `ProductBento.vue`）
4. API 代码示例（新组件 `CodeDemo.vue`）
5. 用户路径导航（替换 AudienceStartGuide）

### Phase 3 — 产品页重构 (2-3天)
1. ForExplorers — 分屏展示 + 定价升级
2. ForEntrepreneurs — CTA 文案调整（已完成 "联系销售"）
3. ForBuilders — 无变化

### Phase 4 — 定价页重构 (1-2天)
1. 暗色卡片 + 发光效果
2. 功能对比表重设计

### Phase 5 — 导航/全局 (1天)
1. Navbar Mega Menu
2. Footer 4列布局
3. 移动端 Bottom Tab Bar

### Phase 6 — 新增页面 (按需)
1. 模型库页 `/models`（参考 iflow 模型展示）
2. 产品详情页（按产品优先级排）

---

## 十二、设计原则约定

1. **暗色优先**：所有新组件先设计暗色版本
2. **无外部动效库**：动效全部用 CSS Transition / Animation 实现
3. **中文优先**：字号不低于 16px，行高不低于 1.6
4. **代码即产品**：每个技术产品页必须有可复制的代码示例
5. **移除手绘风**：btn-hand / border-sketchy / font-hand 只保留极少量装饰性使用
6. **数字说话**：关键指标（99.9%/50+/3行代码）用 Geist Mono + 大字号突显
7. **To C 有价格，To B 无价格**：定价仅在 /pricing 和 ForExplorers 出现
