---
name: research
description: 需求研究，生成约束集。完成后请 /clear
allowed-tools: Read, Glob, Grep, Skill, mcp__auggie-mcp__codebase-retrieval, mcp__codex__codex, mcp__gemini__gemini, AskUserQuestion
---

# 需求研究

**任务**: $ARGUMENTS

## 核心原则

- 产出**约束集**，而非信息堆砌
- 每个约束缩小解空间，让后续阶段零决策
- 有歧义必须用 `AskUserQuestion` 澄清

## 执行步骤

### 1. 加载项目知识

检查并读取 `.knowledge/project/` 目录下的文件：
- 项目背景
- 业务规则
- 术语定义

### 2. 代码检索

使用 `mcp__auggie-mcp__codebase-retrieval` 检索相关代码。
若不可用，回退到 Glob + Grep。

### 3. 多模型并行分析

**并行调用** Codex + Gemini（SESSION_ID 由 hook 自动保存到 `.fantayspec/sessions.md`）:

**Codex** (`mcp__codex__codex`, sandbox: "read-only"):
```
PROMPT: |
  ROLE: Backend Analyzer — Expert in API design, database architecture, security, scalability.
  Focus: technical feasibility, backend complexity, dependency risks, migration effort.
  TASK: [任务描述]
  CONTEXT: [检索到的相关代码]
  OUTPUT: Structured feasibility report. Score 0-10. NO code changes, analysis only.
```

**Gemini** (`mcp__gemini__gemini`, sandbox: true):
```
PROMPT: |
  ROLE: Frontend/UX Analyzer — Expert in user experience, accessibility (WCAG 2.1 AA), responsive design, design systems.
  Focus: UX impact, component reuse, a11y compliance, visual consistency.
  TASK: [任务描述]
  CONTEXT: [检索到的相关代码]
  OUTPUT: Structured UX impact report. Score 0-10. NO code changes, analysis only.
```

### 4. 综合分析 + 质量门

Claude 综合双方分析（参考 `~/.claude/prompts/claude/analyzer.md`）：
- 整合技术约束 + 业务约束 + 依赖关系
- 识别双方分析的盲区
- 解决冲突建议

**研究完整度评分 (0-10):**
- 技术可行性: X/10 (来自 Codex)
- UX 影响: X/10 (来自 Gemini)
- 约束清晰度: X/10 (Claude 自评)
- **综合评分**: X/10

**质量门:**
- **≥ 7 分** → 继续到下一阶段
- **< 7 分** → STOP。列出未解决问题，使用 `AskUserQuestion` 要求用户补充信息

### 5. 生成约束集

```markdown
# 约束集

## 硬约束 (不可违反)
- [ ] 约束描述

## 软约束 (建议遵守)
- [ ] 约束描述

## 依赖关系
- A → B

## 开放问题
- 问题?
```

### 6. 用户确认

使用 `AskUserQuestion` 确认开放问题。

### 7. 保存状态

- `.fantayspec/constraints.md` - 约束集
- `.fantayspec/context.md` - 上下文摘要
- SESSION_ID 已由 hook 自动保存到 `.fantayspec/sessions.md`

## 完成提示

```
✅ 需求研究完成

约束集: .fantayspec/constraints.md
硬约束: X 项 | 软约束: X 项
研究评分: X/10

下一步:
1. /clear 清空上下文
2. /ideate 生成方案选项 (推荐)
   或 /plan 直接生成执行计划
```
