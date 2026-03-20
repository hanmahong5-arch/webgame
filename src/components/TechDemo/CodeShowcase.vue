<script setup lang="ts">
import { ref, computed, onUnmounted } from 'vue'
import { copyToClipboard } from '@/utils/clipboard'

interface Token {
  type: 'keyword' | 'url' | 'string' | 'flag' | 'plain' | 'key' | 'number' | 'boolean' | 'null'
  value: string
}

const props = withDefaults(defineProps<{
  code: string
  language: string
  showLineNumbers?: boolean
  ariaLabel: string
  showAuthTag?: boolean
}>(), {
  showLineNumbers: false,
  showAuthTag: false,
})

const COPY_FEEDBACK_DURATION_MS = 2000
const DEBOUNCE_INTERVAL_MS = 300

const copied = ref(false)
const lastCopyTime = ref(0)
let copyResetTimer: ReturnType<typeof setTimeout> | null = null

onUnmounted(() => {
  if (copyResetTimer) {
    clearTimeout(copyResetTimer)
    copyResetTimer = null
  }
})

/**
 * Tokenize a bash/curl code string into typed tokens for CSS-only syntax highlighting.
 * Supports keywords, URLs, strings, flags, and plain text.
 */
function tokenizeBash(code: string): Token[] {
  const tokens: Token[] = []
  // Pattern order matters: URLs before strings (URLs may contain quotes context)
  const regex = /(\bhttps?:\/\/[^\s"'\\]+)|(["'][^"']*["'])|(\\?\b(?:curl|GET|POST|PUT|DELETE|HEAD|PATCH)\b)|(-[a-zA-Z]\b)|(\\\n)/g

  let lastIndex = 0
  let match: RegExpExecArray | null

  while ((match = regex.exec(code)) !== null) {
    // Capture plain text before the match
    if (match.index > lastIndex) {
      tokens.push({ type: 'plain', value: code.slice(lastIndex, match.index) })
    }

    if (match[1]) {
      tokens.push({ type: 'url', value: match[0] })
    } else if (match[2]) {
      tokens.push({ type: 'string', value: match[0] })
    } else if (match[3]) {
      tokens.push({ type: 'keyword', value: match[0] })
    } else if (match[4]) {
      tokens.push({ type: 'flag', value: match[0] })
    } else if (match[5]) {
      tokens.push({ type: 'plain', value: match[0] })
    }

    lastIndex = match.index + match[0].length
  }

  // Remaining plain text
  if (lastIndex < code.length) {
    tokens.push({ type: 'plain', value: code.slice(lastIndex) })
  }

  return tokens
}


/**
 * Tokenize a JSON code string into typed tokens for CSS-only syntax highlighting.
 * Supports object keys, string values, numbers, booleans, and null.
 */
function tokenizeJson(code: string): Token[] {
  const tokens: Token[] = []
  // Match JSON tokens: keys ("key":), strings ("value"), numbers, booleans, null
  const regex = /("(?:[^"\\]|\\.)*")\s*(:)|("(?:[^"\\]|\\.)*")|(\b(?:true|false)\b)|(\bnull\b)|(-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)\b/g

  let lastIndex = 0
  let match: RegExpExecArray | null

  while ((match = regex.exec(code)) !== null) {
    // Capture plain text before the match (brackets, commas, whitespace)
    if (match.index > lastIndex) {
      tokens.push({ type: 'plain', value: code.slice(lastIndex, match.index) })
    }

    if (match[1] && match[2]) {
      // Object key followed by colon
      tokens.push({ type: 'key', value: match[1] })
      tokens.push({ type: 'plain', value: match[2] })
    } else if (match[3]) {
      // String value (not a key)
      tokens.push({ type: 'string', value: match[3] })
    } else if (match[4]) {
      // Boolean
      tokens.push({ type: 'boolean', value: match[4] })
    } else if (match[5]) {
      // Null
      tokens.push({ type: 'null', value: match[5] })
    } else if (match[6]) {
      // Number
      tokens.push({ type: 'number', value: match[6] })
    }

    lastIndex = match.index + match[0].length
  }

  // Remaining plain text
  if (lastIndex < code.length) {
    tokens.push({ type: 'plain', value: code.slice(lastIndex) })
  }

  return tokens
}

/**
 * Tokenize a code string into typed tokens for CSS-only syntax highlighting.
 * Delegates to language-specific tokenizers.
 */
function tokenize(code: string): Token[] {
  if (props.language === 'bash') {
    return tokenizeBash(code)
  }
  if (props.language === 'json') {
    return tokenizeJson(code)
  }
  return [{ type: 'plain', value: code }]
}

const tokens = computed(() => tokenize(props.code))

const lineCount = computed(() => props.code.split('\n').length)

async function handleCopy() {
  const now = Date.now()
  if (now - lastCopyTime.value < DEBOUNCE_INTERVAL_MS) return
  lastCopyTime.value = now

  const success = await copyToClipboard(props.code)
  if (success) {
    copied.value = true
    if (copyResetTimer) clearTimeout(copyResetTimer)
    copyResetTimer = setTimeout(() => {
      copied.value = false
      copyResetTimer = null
    }, COPY_FEEDBACK_DURATION_MS)
  }
}
</script>

<template>
  <div class="code-showcase" role="region" :aria-label="ariaLabel">
    <!-- Header bar -->
    <div class="code-header">
      <span class="code-language">{{ language }}</span>
      <div class="code-actions">
        <span v-if="showAuthTag" class="auth-tag">
          需 API Key
        </span>
        <button
          type="button"
          class="copy-btn"
          :class="{ 'copy-btn--copied': copied }"
          :aria-label="copied ? '已复制到剪贴板' : '复制代码'"
          @click="handleCopy"
        >
          <!-- Clipboard icon (idle) -->
          <svg
            v-if="!copied"
            class="copy-icon"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            aria-hidden="true"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
          </svg>
          <!-- Checkmark icon (success) -->
          <svg
            v-else
            class="copy-icon"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            aria-hidden="true"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          <span class="copy-label">{{ copied ? '已复制' : '复制' }}</span>
        </button>
      </div>
    </div>

    <!-- Code block -->
    <div class="code-body">
      <pre class="code-pre"><code :aria-label="ariaLabel"><template v-if="showLineNumbers"><span
            v-for="(_, idx) in lineCount"
            :key="idx"
            class="line-number"
            aria-hidden="true"
          >{{ idx + 1 }}</span></template><span
          v-for="(token, idx) in tokens"
          :key="idx"
          :class="`token-${token.type}`"
        >{{ token.value }}</span></code></pre>
    </div>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.code-showcase {
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid var(--color-surface-border);
}

.code-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 16px;
  background-color: var(--color-surface-raised);
  border-bottom: 1px solid var(--color-surface-border);
}

.code-language {
  font-family: monospace;
  font-size: 12px;
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.code-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.auth-tag {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 4px;
  background-color: rgba(201, 162, 39, 0.2);
  color: var(--color-ochre);
}

.copy-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  border: none;
  border-radius: 4px;
  background-color: transparent;
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: color 0.2s ease, background-color 0.2s ease;
  font-size: 12px;
  font-family: inherit;
}

.copy-btn:hover {
  color: var(--color-ochre);
  background-color: rgba(201, 162, 39, 0.1);
}

.copy-btn--copied {
  color: #86EFAC;
  background-color: rgba(134, 239, 172, 0.1);
}

.copy-icon {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

.copy-label {
  font-size: 12px;
}

.code-body {
  background-color: var(--color-surface-raised);
  overflow-x: auto;
}

.code-pre {
  margin: 0;
  padding: 21px;
  font-family: 'Cascadia Code', 'Fira Code', 'JetBrains Mono', monospace;
  font-size: 14px;
  line-height: 1.6;
  color: var(--color-text-primary);
  white-space: pre;
}

.line-number {
  display: inline-block;
  width: 2em;
  margin-right: 1em;
  text-align: right;
  color: var(--color-text-muted);
  border-right: 1px solid var(--color-surface-border);
  padding-right: 0.75em;
  user-select: none;
}

/* CSS-only syntax highlighting tokens */
.token-keyword {
  color: var(--color-ochre);
  font-weight: 600;
}

.token-url {
  color: #7DD3FC;
}

.token-string {
  color: #86EFAC;
}

.token-flag {
  color: #F5E6B8;
}

.token-plain {
  color: var(--color-text-primary);
}


/* CSS-only syntax highlighting tokens - JSON */
.token-key {
  color: var(--color-ochre);
}

.token-number {
  color: #7DD3FC;
}

.token-boolean {
  color: #F9A8D4;
}

.token-null {
  color: var(--color-text-secondary);
}

/* Reduced motion: disable copy-flash transition */
@media (prefers-reduced-motion: reduce) {
  .copy-btn {
    transition-duration: 0ms;
  }

  .copy-btn--copied {
    transition-duration: 0ms;
  }
}
</style>
