---
name: plan
description: 生成零决策执行计划。完成后请 /clear
allowed-tools: Read, Write, Glob, Grep, mcp__codex__codex, mcp__gemini__gemini, AskUserQuestion
---

# 执行计划

## 前置条件

读取 `.fantayspec/constraints.md`。
若不存在，提示先执行 `/research`。

读取（若存在）：
- `.fantayspec/design.md` - 选定方案（复杂度 C 时**必须**��，来自 `/ideate`）
- `.fantayspec/sessions.md` - 历史 SESSION_ID

## 核心原则

- 计划必须**零决策**：执行阶段纯机械操作
- 每个步骤包含：文件路径、具体修改、验证方法
- 消除所有"待定"、"视情况而定"等模糊表述

## 执行步骤

### 1. 加载状态

```
Read .fantayspec/constraints.md
Read .fantayspec/context.md
Read .fantayspec/design.md      # 可选
Read .fantayspec/sessions.md    # 可选
```

### 2. 加载技术知识

检查并读取 `.knowledge/tech/` 目录：
- 技术栈说明
- 架构文档
- API 规范

### 3. 多模型并行审查计划

**Codex (后端计划审查)** — 使用 architect 角色:
```
读取角色: ~/.claude/prompts/codex/architect.md
调用 mcp__codex__codex:
  PROMPT: |
    ROLE: Backend Architect
    TASK: Review and refine this implementation plan for backend completeness.
    Check: missing API endpoints, database migrations, error handling, auth flows.
    
    CONSTRAINTS: [constraints.md]
    DESIGN: [design.md or 方案描述]
    
    OUTPUT: Refined step-by-step backend implementation plan with file paths.
  cd: [项目根目录]
  sandbox: "read-only"
  SESSION_ID: [从 sessions.md 读取，可选]
```

**Gemini (前端计划审查)** — 与 Codex 并行:
```
读取角色: ~/.claude/prompts/gemini/architect.md
调用 mcp__gemini__gemini:
  PROMPT: |
    ROLE: Frontend Architect
    TASK: Review and refine this implementation plan for frontend completeness.
    Check: missing components, state management, responsive design, a11y.
    
    CONSTRAINTS: [constraints.md]
    DESIGN: [design.md or 方案描述]
    
    OUTPUT: Refined step-by-step frontend implementation plan with file paths.
  cd: [项目根目录]
  sandbox: true
  SESSION_ID: [从 sessions.md 读取，可选]
```

保存返回的 SESSION_ID。

### 4. Claude 综合生成计划

融合双方建议，生成统一计划：

```markdown
# 执行计划

## 任务清单

- [ ] Task 1: 描述
  - 文件: path/to/file.ts:L10-L50
  - 修改: 具体修改内容
  - 验证: 如何验证
  - 模型: codex/gemini (由哪个模型出原型)

## 执行顺序
Task 1 → Task 2 → Task 3

## 风险点
- 风险: 缓解措施
```

### 5. 计划质量门

**计划完整度评分 (0-10):**
- 步骤具体性: X/10 (每步有文件路径和具体修改)
- 约束覆盖度: X/10 (所有硬约束有对应任务)
- 验证完备性: X/10 (每步有验证方法)
- **综合评分**: X/10

**≥ 7 分** → 提交用户确认
**< 7 分** → 细化计划，补充缺失

### 6. 用户确认

展示计划，使用 `AskUserQuestion` 确认。

### 7. 保存计划

- `.fantayspec/plan.md` - 执行计划
- `.fantayspec/progress.md` - 进度跟踪（所有任务标记为待完成）
- 更新 `.fantayspec/sessions.md`:
  ```markdown
  ## Plan 阶段
  - CODEX_SESSION: <uuid>
  - GEMINI_SESSION: <uuid>
  - 计划评分: X/10
  ```

## 完成提示

```
✅ 计划生成完成

计划: .fantayspec/plan.md
任务数: X | 文件数: X
计划评分: X/10

下一步:
1. /clear 清空上下文
2. /impl 开始实现
```
