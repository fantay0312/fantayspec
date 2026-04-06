# FantaySpec v3.0

> **"Talk is cheap. Show me the code."** — Linus Torvalds

## 核心原则

1. **先读后写** - 修改前必须读取目标文件
2. **阶段清理** - 每阶段完成后 `/clear` 释放上下文
3. **状态同步** - 变更后更新 `.fantayspec/`
4. **验证闭环** - 执行后必须验证结果

## 工作流

```
/research → /ideate → /plan → /impl → /verify
```

### 复杂度路由 (P.A.C.E.)

| 路径 | 标准 | 工作流 |
|:---|:---|:---|
| **A** 快速 | 单文件, <30行 | research → impl → verify |
| **B** 标准 | 2-10 文件 | research → plan → impl → verify |
| **C** 复杂 | >10 文件 | research → ideate → plan → impl → verify (多轮) |

## 主动行为规则（MUST - 始终生效）

以下规则**自动触发**，不需要用户指示：

### 多模型协作（自动触发）

**涉及代码实现时，必须调用外部模型获取原型：**

| 任务类型 | 自动行为 |
|:---|:---|
| 前端/UI/CSS/组件/页面 | → 必须调用 `mcp__gemini__gemini` |
| 后端/API/数据库/算法/逻辑 | → 必须调用 `mcp__codex__codex` |
| 全栈/跨前后端 | → 必须**并行**调用 Codex + Gemini |
| 代码审查/Review | → 并行调用 Codex(reviewer) + Gemini(reviewer) |

**调用时必须**：加载角色 Prompt (`~/.claude/prompts/{codex,gemini}/`)、使用 sandbox、保存 SESSION_ID、审查重构后再应用。

**不触发**：纯配置修改、单行修复、变量重命名、文档编辑、Git 操作。

### 子代理并行（自动触发）

| 场景 | 自动行为 |
|:---|:---|
| 搜索 3+ 文件/理解架构 | → `Agent(Explore)` |
| 代码审查 | → `Agent(code-reviewer)` |
| 安全相关修改 | → `Agent(security-reviewer)` |
| 构建失败 | → `Agent(build-error-resolver)` |
| 多个独立任务 | → 多个 Agent **同时发射** |

### 并行执行（自动触发）

**独立任务必须并行，禁止串行等待：**
- 多文件读取 → 并行 Read
- Codex + Gemini → 并行 MCP 调用
- 多个搜索 → 并行 Agent(Explore)
- 测试 + Lint → 并行 Bash

### 搜索与证据（自动触发）

| 场景 | 自动行为 |
|:---|:---|
| 不熟悉的库/框架 | → GrokSearch 或 context7 |
| 需要最新版本信息 | → GrokSearch |
| 库 API 用法不确定 | → context7 |

## 规范索引

按需加载。根据当前任务类型 Read 对应文件：

| 规范 | 路径 | 适用场景 |
|:---|:---|:---|
| 编码风格 | `~/.claude/specs/coding-style.md` | 写代码时 |
| 安全规范 | `~/.claude/specs/security.md` | 涉及输入验证、认证、敏感数据时 |
| 测试规范 | `~/.claude/specs/testing.md` | 写测试时 |
| Git 工作流 | `~/.claude/specs/git-workflow.md` | 提交、分支、PR 时 |
| 性能优化 | `~/.claude/specs/performance.md` | 性能调优、模型选择时 |
| 多模型协作 | `~/.claude/specs/multi-model.md` | 首次调用外部模型前必读 |
| Agent 委派 | `~/.claude/specs/agents.md` | 委派子代理时 |
| 搜索与证据 | `~/.claude/specs/search.md` | 需要搜索外部信息时 |

## 数据结构

```
.fantayspec/              # 项目状态
├── constraints.md        # 约束集
├── design.md             # 选定方案 (/ideate 产出)
├── sessions.md           # SESSION_ID 持久化 (跨阶段复用)
├── plan.md               # 执行计划
├── progress.md           # 进度跟踪
└── verify.md             # 验证报告
```

## 上下文管理

- 超过 80% 时立即 `/clear`
- 每个阶段完成后 `/clear`
- 状态已保存在 `.fantayspec/`，可从断点继续

## 语言规范

- **交互语言**: 工具调用和模型间通信使用**英文**；用户可见输出使用**中文**
- **思维语言**: 内部推理使用英文
- **格式**: 标准 Markdown，代码块用反引号

## 推理原则

- 简洁、直接、信息密集
- 挑战有缺陷的前提
- 所有结论须注明适用条件和局限
- 不确定时先陈述未知项
