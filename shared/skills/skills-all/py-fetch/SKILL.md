---
name: py-fetch
description: Unified fetch and scraping skill. Fetches a URL, local file, or raw HTML into a local Markdown file by default, and escalates to scrapling when pages are dynamic, login-gated, Cloudflare/WAF-protected, or require selector-based extraction. Use when the user says fetch/grab/scrape/extract/download to md, wants a page saved locally, wants protected/dynamic pages handled, wants HTML parsed, or wants batch page extraction.
user_invocable: true
allowed-tools: Bash(python*), Bash(pip*), Bash(scrapling*), Bash(markitdown*), WebFetch
---

# py-fetch

你是 **Fetch (抓取刀)**。默认目标只有一个：把目标内容稳定落地为本地 Markdown。

当页面简单时，走最短路径；当页面动态、受保护、需要登录或只想提特定元素时，自动切到 scrapling 路径。

## 输出约定

- 默认输出：`~/Downloads/{filename}.md`
- 默认格式：Markdown
- 如果用户要求提取结构化数据但没指定格式，仍输出 Markdown 报告，不擅自改成 JSON/CSV
- 完成后必须报告：
  - 输出文件路径
  - 最终采用的策略

## 输入解析

从用户输入中提取：

| 部分 | 说明 |
|------|------|
| target | URL、本地文件路径、或已有 HTML |
| `-o name` | 可选，指定输出文件名（不含扩展名） |
| extraction goal | 可选，全文抓取 / 特定元素 / 列表 / 多页面 |

输入分类：

| 输入 | 判定 | 处理 |
|------|------|------|
| `http://` / `https://` | URL 模式 | 走 URL 工作流 |
| 本地存在的文件路径 | 文件模式 | 走本地文件工作流 |
| 明显是 HTML 片段/整页源码 | HTML 模式 | 走纯解析工作流 |
| 其他 | 无效输入 | 告知用户并终止 |

## 工作流

### 1. 本地文件工作流

适用：PDF、DOCX、PPTX、HTML、图片等本地文件。

1. 先尝试：

```bash
markitdown "{file_path}"
```

2. 如果用户不是要全文，而是要某个字段/选择器结果：
   - 对 HTML 文件优先读取 `templates/parse_only.py`
   - 参考 `references/api-quick-ref.md`
   - 用 `Selector` 提取后，写成 Markdown 报告
3. `markitdown` 失败：
   - 告知格式可能不受支持
   - 不编造成功结果

### 2. URL 工作流

#### 2a. 默认全文抓取路径

如果用户只是要“抓下来 / 转成 md / 保存页面内容”，优先走最低成本路径：

**Strategy A: WebFetch**

使用 WebFetch 提取正文，提示词固定为：

```text
Extract the complete main content of this page. Return the full text in clean markdown format, preserving headings, lists, tables, links, and code blocks. Remove navigation, ads, footer, sidebar, and cookie banners.
```

判定成功：

- 内容长度 > 200 字符
- 不是错误页 / 验证页 / 明显残缺页

成功则直接保存。

**Strategy B: markitdown on downloaded HTML**

当 WebFetch 结果不完整、不稳定，或需要更接近原页面结构时：

1. 先下载原始 HTML
2. 保存到 `/tmp/py_fetch_raw.html`
3. 运行：

```bash
markitdown /tmp/py_fetch_raw.html
```

下载实现优先级：

1. `curl -L -s`
2. `requests`

如果到这一步已经成功，不再无谓升级。

#### 2b. scrapling 升级路径

出现以下任一情况时，直接改走 scrapling：

- 页面需要 JS 渲染
- 有 Cloudflare / WAF / 403 / “Just a moment”
- 需要登录态或 cookie
- 用户要特定元素/字段，而不是全文
- 批量抓取多个页面
- WebFetch 与 `markitdown` 路径结果不可靠

升级前按需读取参考：

- `references/site-patterns.md`：先看是否已有站点经验
- `references/api-quick-ref.md`：方法签名和 cookie 格式
- `references/cookie-vault.md`：需要登录 cookie 时再看
- `references/maintenance.md`：未安装或依赖异常时再看
- `references/troubleshooting.md`：运行报错时再看

Fetcher 选择规则：

| 场景 | 方案 | 模板 |
|------|------|------|
| 已有 HTML，只需解析 | Selector | `templates/parse_only.py` |
| 静态页面，无反爬 | Fetcher | `templates/basic_fetch.py` |
| 需要 HTTP 表单登录 | FetcherSession | `templates/session_login.py` |
| Cloudflare / WAF / 403 | StealthyFetcher | `templates/stealth_cloudflare.py` |
| SPA / React / Vue / JS 渲染 | DynamicFetcher | `templates/dynamic_fetch.py` |
| 不确定 | 先 Fetcher，失败再升到 StealthyFetcher 或 DynamicFetcher | 按上表 |

#### 2c. scrapling 输出收口

scrapling 抓完之后，按用户目标收口：

- **全文 Markdown**
  - 优先把抓到的 HTML 写入 `/tmp/py_fetch_raw.html`
  - 再运行 `markitdown /tmp/py_fetch_raw.html`
- **结构化提取**
  - 不强行过 `markitdown`
  - 直接写 Markdown 报告，包含：
    - 来源 URL
    - 采用的 Fetcher
    - 提取规则
    - 提取结果

### 3. HTML 模式

适用：用户直接给你 HTML 字符串或 HTML 文件内容。

1. 读取 `templates/parse_only.py`
2. 用 `Selector` 做提取或正文清洗
3. 输出为 Markdown

## 安装与依赖

- `markitdown` 缺失：先检查是否真的需要安装；需要时再装
- `scrapling` 缺失或浏览器依赖未装：
  - 读取 `references/maintenance.md`
  - 按里面的最小安装路径处理

不要一上来就升级所有依赖。先满足当前任务。

## 文件命名

文件名生成规则（不含 `.md`）：

1. 用户指定 `-o name` → 用 `name`
2. URL 模式 → 用 URL 最后一段，清洗成 kebab-case
3. 文件模式 → 用原文件名去扩展名
4. 仍无法确定 → `fetch-{YYYYMMDD-HHMMSS}`

## 收尾

1. 写入 `~/Downloads/{filename}.md`
2. 清理临时文件：`rm -f /tmp/py_fetch_raw.html`
3. 报告格式：

```text
已抓取 → ~/Downloads/{filename}.md  ({strategy})
```

`strategy` 只写最终成功路径，例如：

- `WebFetch`
- `curl+markitdown`
- `requests+markitdown`
- `scrapling-fetcher+markitdown`
- `scrapling-stealthy+markitdown`
- `scrapling-dynamic+extract`
- `selector-parse`

## 触发示例

<example>
User: /py-fetch https://example.com/post
Assistant: [抓取正文并保存为 Markdown]
</example>

<example>
User: /py-fetch https://site.com/dashboard -- extract title and all links
Assistant: [判断为选择器提取，升级到 scrapling 路径]
</example>

<example>
User: /py-fetch ~/Documents/report.pdf -o report-notes
Assistant: [用 markitdown 转成 Markdown]
</example>

<example>
User: /py-fetch https://protected.site.com/thread
Assistant: [检测 Cloudflare / 登录态，走 StealthyFetcher 或 Session 路径]
</example>
