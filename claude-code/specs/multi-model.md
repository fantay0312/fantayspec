# 多模型协作规范

## 角色分工

| 模型 | 角色 | 擅长领域 | 调用方式 |
|:---|:---|:---|:---|
| **Claude** | 编排协调 | 推理、规划、重构、集成、交叉审查 | 主控制器 |
| **Gemini** | 前端专家 | UI/UX、CSS、组件设计、响应式、A11y | `mcp__gemini__gemini` |
| **Codex** | 后端专家 + 审查 | API、算法、数据库、调试、安全 | `mcp__codex__codex` |

## 角色 Prompt 模板

调用外部模型时**必须**加载对应角色 Prompt，禁止发裸任务。

```
~/.claude/prompts/
├── codex/   → analyzer, architect, reviewer, debugger, tester, optimizer
├── gemini/  → analyzer, architect, reviewer, frontend, debugger, tester, optimizer
└── claude/  → orchestrator, reviewer, analyzer
```

**阶段 → 角色映射:**

| 阶段 | Codex 角色 | Gemini 角色 | Claude 角色 |
|:---|:---|:---|:---|
| research | analyzer | analyzer | analyzer |
| ideate | architect | architect | analyzer |
| plan | architect | architect | orchestrator |
| impl | architect | architect/frontend | orchestrator |
| verify | reviewer | reviewer | reviewer |
| debug | debugger | debugger | — |
| test | tester | tester | — |
| optimize | optimizer | optimizer | — |

## 任务路由

```
任务识别 ──┬── 前端/UI ──────► Gemini (设计参谋 → 出原型)
           ├── 后端/逻辑 ────► Codex  (详细实现 → 出原型)
           ├── 全栈 ─────────► Gemini(前端) + Codex(后端) 并行
           ├── 代码审查 ─────► Codex  (逻辑审查) + Gemini(UI 审查)
           └── 架构决策 ─────► Claude 主导，Codex/Gemini 提供意见
```

## 工作流（5 阶段 + 质量门）

```
/research → /ideate → /plan → /impl → /verify
    │          │         │        │        │
    ▼          ▼         ▼        ▼        ▼
  ≥7分?     用户选方案  ≥7分?   SESSION   ≥7分?
  否→补充    否→迭代    否→细化  resume    否→修复
```

### SESSION_ID 持久化

所有阶段的 SESSION_ID 保存到 `.fantayspec/sessions.md`:
```markdown
# 会话状态
## Research 阶段
- CODEX_SESSION: <uuid>
- GEMINI_SESSION: <uuid>
## Ideate 阶段
- CODEX_SESSION: <uuid>
- GEMINI_SESSION: <uuid>
## Plan 阶段
- CODEX_SESSION: <uuid>
- GEMINI_SESSION: <uuid>
```

后续阶段读取前序 SESSION_ID 并 resume，实现**零上下文损失**。
`/clear` 后 SESSION_ID 不丢失（持久化在文件中）。

## 阶段协作

| 阶段 | Gemini | Codex | Claude |
|:---|:---|:---|:---|
| **research** | 前端/UX 分析 (analyzer) | 后端可行性分析 (analyzer) | 综合评估 + 质量门 |
| **ideate** | 前端方案构思 (architect) | 后端方案构思 (architect) | 方案对比 + 用户选择 |
| **plan** | 前端计划审查 (architect) | 后端计划审查 (architect) | 生成统一计划 + 质量门 |
| **impl** | 前端原型输出 (frontend) | 后端原型输出 (architect) | 审查重构应用 |
| **verify** | UI/A11y 审查 (reviewer) | 逻辑/安全审查 (reviewer) | 综合验证 + 质量门 |

## 协作协议

1. **零写权限** - 外部模型只输出 Unified Diff Patch，Codex: `sandbox="read-only"`，Gemini: `sandbox=true`
2. **角色约束** - 必须加载角色 Prompt，禁止发裸任务
3. **审查重构** - Claude 必须审查原型逻辑，去除冗余、统一命名后再应用
4. **交叉验证** - verify 阶段 Codex + Gemini 并行审查，使用 reviewer 角色
5. **辩证思考** - Claude 对外部模型输出必须有独立判断
6. **SESSION 复用** - 始终保存并复用 SESSION_ID，避免冷启动

## 质量门

每个阶段输出都有评分机制 (0-10):
- **≥ 7 分**: 通过，继续下一阶段
- **< 7 分**: 暂停，补充信息或细化后重试

## MCP 调用参考

**Codex** (`mcp__codex__codex`):
```
PROMPT: |
  ROLE: [角色名] (读取 ~/.claude/prompts/codex/[role].md)
  TASK: [任务描述] (英文)
  CONSTRAINTS: [约束集]
  CONTEXT: [相关代码]
  OUTPUT: [期望输出格式]
cd: 项目根目录
sandbox: "read-only"
SESSION_ID: [从 sessions.md 读取，首次为空]
```

**Gemini** (`mcp__gemini__gemini`):
```
PROMPT: |
  ROLE: [角色名] (读取 ~/.claude/prompts/gemini/[role].md)
  TASK: [任务描述] (英文)
  CONSTRAINTS: [约束集]
  CONTEXT: [相关代码]
  OUTPUT: [期望输出格式]
cd: 项目根目录
sandbox: true
SESSION_ID: [从 sessions.md 读取，首次为空]
```

- 始终保存返回的 `SESSION_ID` 到 `.fantayspec/sessions.md`
- Gemini 有效上下文约 1M (gemini-3.1-pro-preview)，可处理大型文件
- Codex 使用 gpt-5.4 + xhigh reasoning + fast tier
- 工具间通信使用英文，结果由 Claude 翻译为中文呈现
