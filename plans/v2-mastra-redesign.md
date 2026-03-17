# lurus-www v2 重设计规划 — mastra.ai 对标

**日期**: 2026-03-17
**参照**: mastra.ai（动态 SVG 产品可视化 + 深色精品感）
**核心目标**: 去除"AI 模板化"外观，用产品动态可视化让 Lurus 自身的技术实力"被看到"

---

## 问题诊断

### 当前"AI 味"根因

| 问题 | 具体表现 | 来源 |
|------|---------|------|
| 模板化布局 | 深色 + 径向发光 + bento grid | 2024-2025 AI 创业公司标配 |
| 过度装饰 | 每个标题都 `text-gradient-gold` | 失去层级感 |
| 静态产品展示 | 代码块 = 告诉用户有什么 | mastra 是"让用户看到产品运行" |
| 色调太暗沉 | 全深色 section 堆叠 | 没有视觉节奏，读起来疲劳 |
| 手绘美学被抹除 | 原 UX spec 的 Artisanal Premium 差异点消失 | 与竞品趋同 |

### mastra.ai 核心差异点（值得借鉴）

1. **每个产品功能有独立全宽动态可视化** — Agent 架构图、Workflow 数据流、Server 部署拓扑
2. **SVG animateMotion + stroke-dasharray 动画** — 流动粒子沿路径运动，展示数据流
3. **3D tilt 效果** — 产品 UI 截图有透视旋转感
4. **荧光强调色** — 极暗背景 + 高对比亮色，视觉冲击力强
5. **命令式 Hero CTA** — `npm create mastra` 而非通用按钮
6. **Mono 字体的技术感** — 代码/命令场景强制使用等宽字体

---

## 设计语言升级（Design System v2）

### 颜色调整

```css
/* 背景更极致 — 接近 mastra 的 #050505 */
--color-surface-base:    #080706;   /* 更深 */
--color-surface-raised:  #0F0D0B;   /* 更深 */
--color-surface-overlay: #171411;

/* 产品专属荧光色 — 替代统一 ochre */
--color-api:      #4A9EFF;   /* Electric Blue — API Gateway */
--color-gushen:   #7AFF89;   /* Electric Green — 量化 */
--color-switch:   #FFB86C;   /* Warm Amber — 桌面应用 */
--color-memx:     #4AFFCB;   /* Teal — 记忆 */
--color-identity: #B08EFF;   /* Violet — Identity */

/* ochre 保留，仅用于 CTA 按钮和品牌强调 */
--color-ochre:    #D4A827;
```

### 新增 CSS 工具类

```css
/* 发光节点效果 */
.glow-node-api      { box-shadow: 0 0 20px rgba(74,158,255,0.4); }
.glow-node-gushen   { box-shadow: 0 0 20px rgba(122,255,137,0.4); }

/* 噪点纹理叠加（替代径向发光装饰） */
.noise-overlay::after { background-image: url("data:image/svg+xml..."); opacity: 0.03; }

/* 3D tilt 卡片 */
.tilt-card { transition: transform 0.3s ease; transform-style: preserve-3d; }
.tilt-card:hover { transform: perspective(800px) rotateY(-4deg) rotateX(2deg) translateY(-4px); }

/* 命令行样式 CTA */
.cmd-cta { font-family: 'JetBrains Mono', monospace; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); }
```

---

## Sprint 结构

### Sprint A — Bug 修复（最高优先级，2–3 小时）

#### A1: 登录修复

**问题**: `VITE_ZITADEL_CLIENT_ID` 默认为空，OIDC authorize URL 格式错误。

**修复步骤**:
1. 从 Zitadel admin 获取 lurus-www OIDC App 的 `client_id`（见 `重要信息.md`）
2. 创建 `2c-bs-www/.env.local`：
   ```
   VITE_ZITADEL_CLIENT_ID=<从 Zitadel 获取>
   VITE_ZITADEL_ISSUER=https://auth.lurus.cn
   ```
3. 验证：点击登录 → 跳转 auth.lurus.cn → 回调 `/auth/callback` → 写入 sessionStorage
4. TopBar 登录按钮状态应切换为用户头像/名称

**涉及文件**: `src/config/oidc.ts`, `.env.local`

#### A2: 邮件报错修复

**待确认**: 需用户截图描述触发路径。
**可能原因**:
- About.vue 联系区段的 `mailto:` 链接（需核查 href 格式）
- 有 email API 调用但后端接口返回错误
- `mail.lurus.cn` (Stalwart) 服务异常

**行动**: 用户提供报错截图后立即修复。

---

### Sprint B — 设计系统升级（4–6 小时）

#### B1: 产品 SVG 可视化升级（5 个）

现有 `ApiDiagram.vue` / `AcestDiagram.vue` / `SwitchDiagram.vue` 是 cream/sketchy 风格。
**全部升级为深色 + 荧光路径 + 动态粒子**，参照 mastra.ai SVG 风格：

| 组件 | 产品 | 可视化内容 | 荧光色 |
|------|------|-----------|--------|
| `ApiFlowDiagram.vue` | Lurus API | 50+ 模型节点 → Gateway → 你的应用，粒子流 | `#4A9EFF` |
| `GushenChartDiagram.vue` | GuShen | K 线图 + AI 信号指标 + 策略触发动画 | `#7AFF89` |
| `SwitchDashDiagram.vue` | Switch | 桌面 UI 模拟截图（3D tilt 效果） | `#FFB86C` |
| `MemxGraphDiagram.vue` | MemX | 知识图谱节点扩展动画 | `#4AFFCB` |
| `IdentityFlowDiagram.vue` | Identity | 认证链路图：用户 → PKCE → Token → 服务 | `#B08EFF` |

每个组件规格：
- 视口尺寸: `viewBox="0 0 600 280"` 全宽响应式
- 背景: 深色 + 极细网格 (`stroke="#1C1916" strokeWidth="0.5"`)
- 节点: 圆角矩形 + `filter: url(#glow)` SVG 滤镜
- 粒子: `<animateMotion>` 沿路径流动，`dur="2s" repeatCount="indefinite"`
- 触发: IntersectionObserver（滚动进入视口才启动动画）
- 可及性: `aria-label` + `prefers-reduced-motion`

#### B2: main.css 扩展

新增：`.glow-node-*` 系列、`.tilt-card`、`.cmd-cta`、`.noise-bg`、`.product-badge-*`

#### B3: 字体扩展

在 `fonts.css` 中引入 JetBrains Mono（CDN fallback），用于命令行/API 场景。

---

### Sprint C — Home.vue 完整重设计（8–12 小时，核心工作）

完全替换当前 bento grid 布局，改为 mastra 风格的"叙事式交替区段"。

#### C1: Hero 区（全新）

```
┌─────────────────────────────────────────────────────┐
│  [eyebrow] AI 基础设施平台                              │
│                                                     │
│  统一 AI 接入                                          │
│  一个 API Key，调用全球 50+ 模型                         │  ← 大字 + 行内产品色
│                                                     │
│  [cmd-cta]  curl https://api.lurus.cn/v1/chat      │  ← 命令式 CTA（可复制）
│  [btn-primary] 免费开始  [btn-outline] 查看文档        │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  ApiFlowDiagram（动态，全宽，600px 高）            │  │  ← 英雄区核心视觉
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

**关键改变**: Hero 不再是文字 + 静态代码块，而是 **可运行命令 + 动态 API 路由可视化**。

#### C2: 统计栏

保留，改用荧光强调数字（`useCountUp` 已有），数值用产品色分色。

#### C3: API 区段（全宽交错）

```
左: 文案 + 功能列表 + CTA
右: ApiFlowDiagram（升级版，更大更复杂）
```

#### C4: GuShen 区段

```
左: GushenChartDiagram（K 线动画）
右: 文案 + "AI 驱动量化策略"
```

#### C5: Switch + MemX 区段（并排两栏）

两个产品卡并排，各自有小型 diagram + 3D tilt

#### C6: 开发者区段（类 mastra "Studio"）

代码示例对比（Before/After 接入 Lurus API），带语法高亮和 tab 切换（现有 `CodeShowcase.vue`）

#### C7: Identity 区段

IdentityFlowDiagram + 平台构建者价值主张

#### C8: 最终 CTA + 信任区段

用户数量 / 运行时间 / 模型支持数 — 真实数据 or 保守估计

---

### Sprint D — 导航重构（2–3 小时）

#### D1: TopBar 新结构（对标 mastra.ai）

```
Logo | 产品▼  解决方案▼  文档  定价 | [控制台] [登录]
```

**产品 mega-menu**（两列）:
```
第一列：消费者产品          第二列：平台产品
  ○ Lurus API                ○ Lurus Identity
    50+ 模型统一网关            认证 + 订阅 + 计费
  ○ GuShen 量化              ○ MemX SDK
    AI 量化交易                 跨会话持久记忆
  ○ Switch 桌面端
    AI 工具统一管理
─────────────────────────────
[查看所有产品 →]
```

**解决方案 mega-menu**（三类用户）:
```
探索者             创业者             构建者
  个人 AI 工具      团队 API 接入       平台基础设施
  → /for-explorers  → /for-entrepreneurs → /for-builders
```

#### D2: Footer 重构（对标 mastra.ai 四列）

```
产品          开发者         公司          法律
Lurus API     文档           关于我们      隐私政策
GuShen        Changelog      博客           服务条款
Switch        GitHub         联系我们
MemX          API 状态        加入我们
Identity
```

---

### Sprint E — 其他页面深色迁移（并行，4–6 小时）

| 页面 | 当前状态 | 目标 |
|------|---------|------|
| `About.vue` | cream/sketchy（旧） | 深色重写，保留时间线动画 |
| `Solutions.vue` | 未知，待查 | 深色重写 |
| `Download.vue` | 未知，待查 | 深色重写 |
| `ForExplorers.vue` | cream/sketchy | **保持不变** |

---

## 实施优先级

```
Week 1（本周）:
  A1 登录 fix → A2 邮件 fix → B1 API/GuShen Diagram 升级 → C1 Hero 重设计

Week 2:
  C2–C8 Home.vue 各区段 → D1 TopBar mega-menu → D2 Footer

Week 3:
  B1 完成剩余3个 Diagram → E1–E3 其他页面深色迁移
```

## 并行可执行的任务

```
独立可并行（无依赖）:
  ├── A1 Login fix
  ├── A2 Email fix
  ├── B2 main.css 扩展（新工具类）
  ├── B3 字体扩展
  └── E 各页面深色迁移

串行（有依赖）:
  B1 Diagram 升级 → C Home.vue 重设计 → D 导航调整
```

---

## 文件影响范围

### 新建文件
- `src/components/Illustrations/ApiFlowDiagram.vue`（替换 ApiDiagram）
- `src/components/Illustrations/GushenChartDiagram.vue`
- `src/components/Illustrations/SwitchDashDiagram.vue`
- `src/components/Illustrations/MemxGraphDiagram.vue`
- `src/components/Illustrations/IdentityFlowDiagram.vue`
- `.env.local`（gitignore，登录用）

### 重写文件
- `src/pages/Home.vue`（全面重设计）
- `src/components/Layout/TopBar.vue`（mega-menu）
- `src/components/Layout/Footer.vue`（四列结构）
- `src/pages/About.vue`（深色迁移）

### 修改文件
- `src/styles/main.css`（新增工具类 + 产品色 token）
- `src/styles/fonts.css`（JetBrains Mono）
- `src/data/navItems.ts`（新导航结构数据）

### 保持不变
- `src/pages/ForExplorers.vue`（cream/sketchy 保留）
- `src/pages/Pricing.vue`（刚完成）
- `src/pages/ForEntrepreneurs.vue`（刚完成）
- `src/pages/ForBuilders.vue`（刚完成）
- 所有 composables（useCountUp / useScrollReveal / useAuth）
