# Agent Delegation Rules

> 与多模型协作配合使用，详见 `~/.claude/specs/multi-model.md`

## When to Delegate

| Scenario | Delegate To | Multi-Model? |
|:---|:---|:---|
| Implementation planning | planner | Codex + Gemini 并行审查 |
| Architecture decisions | architect | Codex(后端) + Gemini(前端) 意见 |
| Code quality review | code-reviewer | Codex(reviewer) + Gemini(reviewer) |
| Security concerns | security-reviewer | Codex(reviewer) 辅助 |
| Build errors | build-error-resolver | — |
| E2E test creation | e2e-runner | Gemini(tester) 辅助 |
| UI/UX design | ui-ux-designer | Gemini(architect) 辅助 |

## Delegation Protocol

1. **Context Handoff** - Provide relevant files, `.fantayspec/` state, and SESSION_ID (if exists)
2. **Clear Objective** - Specific deliverable expected
3. **Role Prompt** - 委派涉及外部模型时，必须指定角色 Prompt (`~/.claude/prompts/`)
4. **Scope Limits** - What agent should NOT do
5. **Return Criteria** - When to return control

## SESSION_ID 传递

子代理涉及 Codex/Gemini 调用时：
1. 读取 `.fantayspec/sessions.md` 获取历史 SESSION_ID
2. 调用外部模型时传入 SESSION_ID 实现上下文复用
3. 调用完成后更新 `.fantayspec/sessions.md`

## Subagent Limits

- Max tools: Limit to required tools only
- Max files: Scope to relevant files
- No cascading: Subagents should not spawn subagents

## Context Management

Use `context: fork` for:
- Experimental changes
- Isolated analysis
- Parallel exploration

## P.A.C.E. 复杂度与委派

| 路径 | 子代理使用 |
|:---|:---|
| **A** 快速 | 不需要子代理 |
| **B** 标准 | planner (可选), code-reviewer |
| **C** 复杂 | planner (必须), code-reviewer, security-reviewer |

## Anti-Patterns

- DON'T delegate simple tasks (Path A)
- DON'T delegate without context and SESSION_ID
- DON'T let subagents modify critical files
- DON'T run multiple subagents on same files
- DON'T call external models without role prompts
