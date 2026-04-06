---
name: multi-ai
description: |
  Multi-AI coordination for Claude Code, Codex CLI, and Gemini CLI.
  Handles task delegation, context handoff, and result synchronization
  across different AI engines. Works with orchestrator.yaml.
---

# Multi-AI Coordination Skill

> 完整协作规范: `~/.claude/specs/multi-model.md`
> 角色 Prompt: `~/.claude/prompts/{codex,gemini,claude}/`

## Supported Engines

| Engine | Strengths | MCP Tool |
|:---|:---|:---|
| Claude Code | 推理, 规划, 审查, 编排 | 主控制器 |
| Codex CLI | 后端, API, 算法, 安全 | `mcp__codex__codex` |
| Gemini CLI | 前端, UI/UX, A11y, 长上下文 | `mcp__gemini__gemini` |

## Phase Integration

| 阶段 | Codex 角色 | Gemini 角色 | Claude 角色 |
|:---|:---|:---|:---|
| /research | analyzer | analyzer | analyzer |
| /ideate | architect | architect | analyzer |
| /plan | architect | architect | orchestrator |
| /impl | architect | architect/frontend | orchestrator |
| /verify | reviewer | reviewer | reviewer |

## Coordination Protocol

### Task Delegation
```
1. 读取角色 Prompt: ~/.claude/prompts/{model}/{role}.md
2. 构造 PROMPT (英文): ROLE + TASK + CONSTRAINTS + CONTEXT + OUTPUT
3. 调用 MCP tool (sandbox mode)
4. 保存 SESSION_ID → .fantayspec/sessions.md
5. Claude 审查重构 → 应用
```

### Context Handoff
```yaml
PROMPT: |
  ROLE: [角色名]
  TASK: [任务描述]
  CONSTRAINTS: [约束集]
  CONTEXT: [相关代码]
  OUTPUT: [期望格式]
cd: [项目根目录]
sandbox: "read-only" | true
SESSION_ID: [从 sessions.md 读取]
```

### SESSION_ID Persistence
```markdown
# .fantayspec/sessions.md
## Research 阶段
- CODEX_SESSION: <uuid>
- GEMINI_SESSION: <uuid>
## Plan 阶段
- CODEX_SESSION: <uuid>
- GEMINI_SESSION: <uuid>
```

`/clear` 后 SESSION_ID 不丢失。下一阶段读取并 resume。

### Lock Mechanism
```yaml
.ai_state/meta/session.lock:
  engine: claude
  task_id: REQ-001
  started: 2025-01-23T15:00:00Z
  status: active
```

## Engine Selection (Auto)

```yaml
前端/UI/CSS/组件 → Gemini (必须)
后端/API/数据库 → Codex (必须)
全栈 → Codex + Gemini (并行)
代码审查 → Codex(reviewer) + Gemini(reviewer) (并行)
纯配置/文档 → Claude only (不触发)
```
