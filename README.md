# FantaySpec v3.0

**Multi-Model Orchestration Framework for Claude Code + Codex CLI**

> One install, two platforms, shared skills. Turn Claude Code + Codex into a Super CLI.

## Quick Start

```bash
git clone https://github.com/fantay0312/fantayspec.git
cd fantayspec
chmod +x install.sh && ./install.sh
```

## Architecture

```
┌──────────────┐    ┌──────────────┐
│  Claude Code  │    │  Codex CLI   │
│  Orchestrator │    │ Backend Expert│
└──────┬───────┘    └──────┬───────┘
       │                   │
       └─────────┬─────────┘
                 │
        ┌────────▼────────┐
        │  Shared Skills   │  ← 40 skills, installed to both
        │  (one source)    │
        └─────────────────┘
```

## What's Included

```
fantayspec/
├── claude-code/                    # → ~/.claude/
│   ├── CLAUDE.md                   #   Proactive behavior rules
│   ├── AGENTS.md                   #   Agent instructions
│   ├── settings.json.template      #   Hooks + permissions + plugins
│   ├── mcp.json.template           #   Codex/Gemini/GrokSearch MCP
│   ├── specs/           (8)        #   Specifications
│   ├── commands/        (5)        #   /research /ideate /plan /impl /verify
│   ├── prompts/        (16)        #   Role templates (codex/gemini/claude)
│   ├── agents/         (15)        #   Sub-agents
│   ├── hooks/ + scripts/ (7)       #   Lifecycle hooks + SESSION_ID auto-save
│
├── codex/                          # → ~/.codex/
│   ├── AGENTS.md                   #   Operating contract (standalone + MCP)
│   ├── config.toml.template        #   GPT-5.4 + xhigh + fast
│   ├── orchestrator.yaml           #   Streamlined orchestrator
│   ├── commands/       (11)        #   Slash commands
│   ├── agents/          (8)        #   Agent roles with tiers
│   ├── rules/           (7)        #   Security, style, testing
│   ├── contexts/        (3)        #   Dev/research/review modes
│   ├── workflows/       (3)        #   9-step, RIPER, P.A.C.E.
│
├── shared/skills/      (40)        # → both ~/.claude/skills/ AND ~/.codex/skills/
│
├── install.sh                      #   One-line dual-platform installer
└── README.md
```

## Key Features

### Proactive Multi-Model (Claude Code)

| Task Type | Auto Behavior |
|:---|:---|
| Frontend/UI | → Gemini called automatically |
| Backend/API | → Codex called automatically |
| Full-stack | → Both in **parallel** |
| Code review | → Both reviewers in parallel |

### Codex Standalone (Dual-Mode)

Codex works as both MCP backend expert AND independent CLI:

- **14 agent roles** across 4 tiers (execute/review/plan/fast)
- **Keyword routing**: say `plan`, `review`, `debug` → auto-routes to right agent
- **Leader/Worker delegation**: up to 6 concurrent sub-agents
- **Verification sizing**: lightweight / standard / deep

### Shared Skills (40)

One skill source, installed to both platforms:

| Category | Skills |
|:---|:---|
| Code Quality | code-quality, verification-loop, eval-harness |
| Documents | docx, pdf, pptx, xlsx |
| Frontend | frontend-design, ui-design-brain, react-best-practices, style-extractor |
| Research | py-paper, py-xray-*, knowledge-absorber, sequential-think |
| Web | scrapling, py-fetch, webapp-testing, clone-website |
| Security | wooyun-legacy |
| Dev Tools | context7, mcp-builder, skill-creator, output-skill, better-icons |
| Workflow | phase-router, riper, strategic-compact, multi-ai |

### SESSION_ID Auto-Persistence

PostToolUse hook saves SESSION_IDs from every Codex/Gemini MCP call. Zero context loss after `/clear`.

### Quality Gates

Every phase scores 0-10. Score < 7 blocks progression.

## Prerequisites

| Tool | Required | Install |
|:---|:---|:---|
| Claude Code | Yes | https://claude.ai/code |
| Codex CLI | Recommended | `npm i -g @openai/codex` |
| Gemini CLI | Optional | https://github.com/google-gemini/gemini-cli |
| Python 3 | Yes | Pre-installed on macOS/Linux |
| Node.js 20+ | Yes | https://nodejs.org |

## Post-Install

```bash
# 1. Configure MCP (add your API keys)
vim ~/.claude/.mcp.json

# 2. Install Codex plugin for Claude Code
claude plugin marketplace add openai/codex-plugin-cc
claude plugin install codex@openai-codex

# 3. Start
claude
```

## License

MIT
