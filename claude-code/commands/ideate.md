---
name: ideate
description: 多模型并行构思方案。在 research 和 plan 之间执行
allowed-tools: Read, Write, Glob, Grep, mcp__codex__codex, mcp__gemini__gemini, AskUserQuestion
---

# 方案构思

## 前置条件

读取 `.fantayspec/constraints.md` 和 `.fantayspec/sessions.md`。
若不存在，提示先执行 `/research`。

## 核心原则

- 至少产出 **2 个可行方案** 供用户选择
- Codex 和 Gemini **独立构思**，避免相互影响
- Claude 综合评估，推荐最优方案

## 执行步骤

### 1. 加载状态

```
Read .fantayspec/constraints.md  # 约束集
Read .fantayspec/context.md      # 上下文
Read .fantayspec/sessions.md     # SESSION_ID
```

### 2. 并行构思

**Codex (后端视角方案)** — 使用 architect 角色:
```
读取角色: ~/.claude/prompts/codex/architect.md
调用 mcp__codex__codex:
  PROMPT: |
    ROLE: Backend Architect
    TASK: Based on the following constraints, propose 2 distinct implementation approaches.
    For each approach, describe: architecture, key components, trade-offs, estimated complexity.
    
    CONSTRAINTS:
    [constraints.md 内容]
    
    CONTEXT:
    [context.md 内容]
    
    OUTPUT: 2 approaches in structured Markdown. NO code yet.
  cd: [项目根目录]
  sandbox: "read-only"
  SESSION_ID: [从 sessions.md 读取的 CODEX_SESSION，可选]
```

**Gemini (前端视角方案)** — 与 Codex 并行:
```
读取角色: ~/.claude/prompts/gemini/architect.md
调用 mcp__gemini__gemini:
  PROMPT: |
    ROLE: Frontend Architect
    TASK: Based on the following constraints, propose 2 distinct UI/UX approaches.
    For each approach, describe: component structure, state management, UX flow, trade-offs.
    
    CONSTRAINTS:
    [constraints.md 内容]
    
    CONTEXT:
    [context.md 内容]
    
    OUTPUT: 2 approaches in structured Markdown. NO code yet.
  cd: [项目根目录]
  sandbox: true
  SESSION_ID: [从 sessions.md 读取的 GEMINI_SESSION，可选]
```

保存返回的 SESSION_ID。

### 3. Claude 综合评估

对照约束集评估所有方案（参考 `~/.claude/prompts/claude/analyzer.md`）：

```markdown
## 方案对比

| 维度 | 方案 A | 方案 B | 方案 C |
|:---|:---|:---|:---|
| 复杂度 | | | |
| 约束满足度 | | | |
| 扩展性 | | | |
| 实现风险 | | | |
| 预估工作量 | | | |

## 推荐: 方案 X
理由: ...
```

### 4. 用户选择

使用 `AskUserQuestion` 展示方案对比，让用户选择或调整。

### 5. 保存状态

- `.fantayspec/design.md` - 选定方案详情
- 更新 `.fantayspec/sessions.md`:
  ```markdown
  ## Ideate 阶段
  - CODEX_SESSION: <uuid>
  - GEMINI_SESSION: <uuid>
  - 选定方案: X
  ```

## 完成提示

```
✅ 方案构思完成

选定方案: [方案名]
方案详情: .fantayspec/design.md

下一步:
1. /clear 清空上下文
2. /plan 基于选定方案生成执行计划
```
