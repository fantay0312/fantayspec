---
name: FantaySpec Verify
description: 验证实现完整性、正确性和一致性。归档前必须执行
allowed-tools: Read, Bash, Glob, Grep, Skill, mcp__codex__codex, mcp__gemini__gemini
---

# 实现验证

## 核心原则

验证三要素：
- **完整性** (Completeness): 所有计划任务已实现
- **正确性** (Correctness): 代码逻辑正确，通过测试
- **一致性** (Coherence): 代码风格统一，与约束集一致

## 前置条件

读取状态文件：
- `.fantayspec/plan.md` - 执行计划
- `.fantayspec/constraints.md` - 约束集
- `.fantayspec/progress.md` - 进度跟踪
- `.fantayspec/sessions.md` - SESSION_ID（可选）

## 执行步骤

### 1. 完整性检查

对照计划检查所有任务：

```markdown
## 完整性检查

### 计划任务 vs 实际完成

| 任务 | 计划状态 | 实际状态 | 差异 |
|------|----------|----------|------|
| Task 1 | ✓ | ✓ | - |
| Task 2 | ✓ | ✗ | 未实现 |

### 未完成项
- [ ] Task 2: 原因/阻塞点
```

### 2. 约束一致性检查

逐项验证约束集：

```markdown
## 约束验证

### 硬约束

| 约束 | 验证方法 | 结果 |
|------|----------|------|
| 约束1 | 代码检查 | ✓ 符合 |
| 约束2 | 单元测试 | ✗ 违反 |

### 软约束

| 约束 | 验证方法 | 结果 |
|------|----------|------|
| 约束1 | 代码审查 | ✓ 符合 |
```

### 3. 自动化测试

运行项目测试（如有）：

```bash
# 检测并运行测试
pnpm test 2>/dev/null || npm test 2>/dev/null || yarn test 2>/dev/null || echo "No test runner found"
```

### 4. 多模型交叉验证（使用 reviewer 角色）

**Codex (逻辑/安全验证)** — 使用 reviewer 角色:
```
读取角色: ~/.claude/prompts/codex/reviewer.md
调用 mcp__codex__codex:
  PROMPT: |
    ROLE: Backend Reviewer
    TASK: Review the following code changes against constraints.

    CONSTRAINTS:
    [constraints.md 内容]

    CODE CHANGES:
    [git diff 内容]

    CHECK:
    1. All hard constraints satisfied
    2. Boundary conditions handled
    3. Error handling complete
    4. Security concerns addressed
    5. No missing implementations

    OUTPUT: JSON { passed: bool, score: 0-10, violations: [], warnings: [] }
  cd: [项目根目录]
  sandbox: "read-only"
  SESSION_ID: [从 sessions.md 读取，可选]
```

**Gemini (UI/一致性验证)** — 与 Codex 并行:
```
读取角色: ~/.claude/prompts/gemini/reviewer.md
调用 mcp__gemini__gemini:
  PROMPT: |
    ROLE: Frontend Reviewer
    TASK: Review the following code changes for UI quality.

    CONSTRAINTS:
    [constraints.md 内容]

    CODE CHANGES:
    [git diff 内容]

    CHECK:
    1. UI constraints satisfied
    2. Accessibility compliance (WCAG 2.1 AA)
    3. Design consistency
    4. Naming coherence
    5. No redundant code

    OUTPUT: JSON { passed: bool, score: 0-10, categories: {...}, violations: [], warnings: [] }
  cd: [项目根目录]
  sandbox: true
  SESSION_ID: [从 sessions.md 读取，可选]
```

### 5. Claude 综合评审

参考 `~/.claude/prompts/claude/reviewer.md`，检查交叉关切：
- 前后端 API 契约是否对齐
- 数据流是否一致
- 命名是否统一

### 6. 验证质量门

**验证评分:**
- Codex 审查: X/10
- Gemini 审查: X/10
- 完整性: X/10
- 约束符合: X/10
- **综合评分**: X/10

**≥ 7 分** → 验证通过
**< 7 分** → 列出阻塞问题，需修复后重新验证

### 7. 生成验证报告

```markdown
## 验证报告

### 总体状态: ✓ 通过 / ✗ 未通过
### 综合评分: X/10

### 完整性
- 计划任务: X/X 完成
- 未完成: [列表或"无"]

### 正确性
- 测试结果: 通过/失败/无测试
- Codex 审查: X/10 — [摘要]

### 一致性
- Gemini 审查: X/10 — [摘要]
- 约束符合: X/X

### 阻塞问题 (必须修复)
1. 问题1: 描述
   - 影响: ...
   - 修复建议: ...

### 建议改进 (可选)
1. 建议1: 描述
```

### 8. 结果处理

**若验证通过**:
```
✅ 验证通过 (X/10)

Codex 审查: X/10 | Gemini 审查: X/10
完整性: ✓ | 正确性: ✓ | 一致性: ✓

报告: .fantayspec/verify.md
```

**若验证未通过**:
```
⚠️ 验证未通过 (X/10)

阻塞问题:
1. [问题描述]

需要修复后重新验证: /verify
```

## 保存状态

- `.fantayspec/verify.md` - 验证报告
- 更新 `.fantayspec/sessions.md`

**重要**: 验证通过后才能归档
