# FantaySpec v3.0

**Multi-Model Orchestration Framework for Claude Code + Codex CLI**

> Turn Claude Code into a Super CLI that orchestrates Claude + Codex + Gemini in parallel.

## Architecture

```
                    ┌──────────────┐
                    │  Claude Code  │  ← Orchestrator (Opus 4.6, 1M ctx)
                    └──────┬───────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
   ┌─────▼─────┐   ┌──────▼─────┐   ┌──────▼──────┐
   │   Codex    │   │   Gemini   │   │  GrokSearch  │
   │  GPT-5.4   │   │  3.1-pro   │   │  Web Search  │
   │  Backend   │   │  Frontend  │   │              │
   └───────────┘   └────────────┘   └─────────────┘
```

## What's Included

```
fantayspec/
├── claude-code/                    # ~/.claude/ configuration
│   ├── CLAUDE.md                   #   Core config + proactive behavior rules
│   ├── AGENTS.md                   #   Agent instructions
│   ├── settings.json.template      #   Hooks, permissions, plugins
│   ├── mcp.json.template           #   Codex + Gemini + GrokSearch MCP
│   ├── specs/ (8)                  #   Multi-model, security, testing, etc.
│   ├── commands/ (5)               #   /research /ideate /plan /impl /verify
│   ├── prompts/ (16)               #   Role templates: codex/6 gemini/7 claude/3
│   ├── agents/ (15)                #   Specialized sub-agents
│   ├── hooks/                      #   Lifecycle hooks + SESSION_ID auto-save
│   ├── scripts/ (6)                #   Hook scripts (Python + JS)
│   └── skills/ (40)                #   All skills
│
├── codex/                          # ~/.codex/ configuration
│   ├── AGENTS.md                   #   Backend expert instructions
│   ├── config.toml.template        #   Model + MCP + features
│   ├── orchestrator.yaml           #   Streamlined orchestrator
│   ├── hooks.json                  #   Hooks
│   ├── commands/ (11)              #   Slash commands
│   ├── agents/ (8)                 #   Agent definitions
│   ├── skills/ (30)                #   All skills
│   ├── rules/ (7)                  #   Security, coding style, testing, etc.
│   ├── contexts/ (3)               #   Dev, research, review modes
│   ├── templates/ (3)              #   Project templates
│   ├── workflows/ (3)              #   9-step, RIPER, P.A.C.E.
│   └── references/ (2)             #   MCP tools, official commands
│
├── install.sh                      # One-line installer (both platforms)
├── README.md
└── LICENSE
```

## Quick Start

```bash
git clone https://github.com/fantay0312/fantayspec.git
cd fantayspec
chmod +x install.sh
./install.sh
```

### Post-Install

1. **Configure MCP** — Edit `~/.claude/.mcp.json` with your API keys
2. **Install Codex Plugin** — `claude plugin marketplace add openai/codex-plugin-cc && claude plugin install codex@openai-codex`
3. **Restart** — `claude`

## 5-Phase Workflow

```
/research → /ideate → /plan → /impl → /verify
    │          │         │        │        │
  Score≥7?  User picks  Score≥7?  SESSION  Score≥7?
  No→Stop   best plan   No→Fix   resume   No→Fix
```

## Key Features

### Proactive Multi-Model (Auto-Triggered)

| Task Type | Auto Behavior |
|:---|:---|
| Frontend/UI/CSS | → Gemini called automatically |
| Backend/API/DB | → Codex called automatically |
| Full-stack | → Both called **in parallel** |
| Code review | → Both reviewers in parallel |

### SESSION_ID Auto-Persistence

PostToolUse hook saves SESSION_IDs from every Codex/Gemini call. No context lost after `/clear`.

### Quality Gates

Every phase scores 0-10. Score < 7 blocks progression.

### 16 Role Prompts

```
prompts/codex/   → analyzer, architect, reviewer, debugger, tester, optimizer
prompts/gemini/  → analyzer, architect, reviewer, frontend, debugger, tester, optimizer
prompts/claude/  → orchestrator, reviewer, analyzer
```

### Dual-Platform

Same skills and standards across Claude Code (40 skills) and Codex CLI (30 skills).

## Prerequisites

| Tool | Required | Install |
|:---|:---|:---|
| Claude Code | Yes | https://claude.ai/code |
| Codex CLI | Recommended | `npm i -g @openai/codex` |
| Gemini CLI | Optional | https://github.com/google-gemini/gemini-cli |
| Python 3 | Yes (for hooks) | Pre-installed on macOS/Linux |
| Node.js 20+ | Yes | https://nodejs.org |

## License

MIT
