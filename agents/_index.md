# Agents Index

> 子代理与多模型协作配合使用。详见 `~/.claude/specs/multi-model.md` 和 `~/.claude/specs/agents.md`

## 核心代理

| Agent | Role | Model | Multi-Model Integration |
|:---|:---|:---|:---|
| phase-router | 意图识别与路由 | sonnet | P.A.C.E. 复杂度判定 |
| planner | 规划专家 | opus | Codex+Gemini 并行审查计划 |
| init-architect | 架构初始化 | opus | — |
| requirement-mgr | 需求生命周期管理 | sonnet | — |
| design-mgr | 方案生命周期管理 | sonnet | — |
| impl-executor | 开发实施执行 | sonnet | Codex(architect)+Gemini(frontend) 出原型 |
| experience-mgr | 经验沉淀管理 | sonnet | — |
| ui-ux-designer | UI/UX 设计 | sonnet | Gemini(architect) 辅助 |

## 质量保障代理

| Agent | Role | Model | Multi-Model Integration |
|:---|:---|:---|:---|
| code-reviewer | 代码质量审查 | sonnet | Codex(reviewer)+Gemini(reviewer) 并行 |
| security-reviewer | 安全审查 | opus | Codex(reviewer) 辅助 |
| tdd-guide | TDD 指导 | sonnet | Codex(tester)+Gemini(tester) |
| e2e-runner | E2E 测试执行 | haiku | — |

## 故障排除代理

| Agent | Role | Model |
|:---|:---|:---|
| build-error-resolver | 构建错误诊断 | haiku |

## 角色 Prompt 模板

子代理调用 Codex/Gemini 时必须加载对应角色：

```
~/.claude/prompts/
├── codex/   → analyzer, architect, reviewer, debugger, tester, optimizer
├── gemini/  → analyzer, architect, reviewer, frontend, debugger, tester, optimizer
└── claude/  → orchestrator, reviewer, analyzer
```

## SESSION_ID 管理

所有涉及外部模型调用的子代理必须：
1. 读取 `.fantayspec/sessions.md`
2. 传入 SESSION_ID 复用上下文
3. 写回更新后的 SESSION_ID

## 代理协作流程

```
用户请求
    │
    ▼
┌─────────────┐
│ phase-router│ ← P.A.C.E. 复杂度判定
└─────────────┘
    │
    ├── Path A (快速) ──────────────────► impl-executor
    │                                         │
    ├── Path B (标准) ──► planner ──────► impl-executor
    │                                         │
    └── Path C (复杂) ──► planner ──────► impl-executor (多轮)
                            │                 │
                     Codex+Gemini        Codex+Gemini
                     并行审查计划          并行出原型
                                              │
                                              ▼
                                    ┌─────────────────┐
                                    │  code-reviewer   │ ← Codex+Gemini 交叉审查
                                    └─────────────────┘
```
