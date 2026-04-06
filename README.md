# FantaySpec v3.0

**Multi-Model Orchestration Framework for Claude Code**

> Turn Claude Code into a Super CLI that orchestrates Claude + Codex + Gemini in parallel.

## What This Is

A complete configuration system that transforms Claude Code from a single-model tool into a multi-model orchestration platform:

- **3 AI models** working in parallel (Claude Opus, Codex GPT-5.4, Gemini 3.1 Pro)
- **5-phase workflow** with quality gates at every stage
- **16 role-specific prompts** so models know exactly what to do
- **16 specialized agents** for parallel task execution
- **Mechanical guarantees** via hooks (SESSION_ID auto-save, file protection, auto-formatting)

## Architecture

```
                    ┌──────────────┐
                    │  Claude Code  │  ← Orchestrator
                    └──────┬───────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
   ┌─────▼─────┐   ┌──────▼─────┐   ┌──────▼──────┐
   │   Codex    │   │   Gemini   │   │  GrokSearch  │
   │  Backend   │   │  Frontend  │   │   Search     │
   └───────────┘   └────────────┘   └─────────────┘
```

## 5-Phase Workflow

```
/research → /ideate → /plan → /impl → /verify
    │          │         │        │        │
  Score≥7?  User picks  Score≥7?  SESSION  Score≥7?
  No→Stop   best plan   No→Fix   resume   No→Fix
```

### P.A.C.E. Complexity Routing

| Path | Criteria | Workflow |
|:---|:---|:---|
| **A** Quick | Single file, <30 lines | research → impl → verify |
| **B** Standard | 2-10 files | research → plan → impl → verify |
| **C** Complex | >10 files | research → ideate → plan → impl → verify |

## What's Included

```
fantayspec/
├── CLAUDE.md                    # Core config with proactive behavior rules
├── AGENTS.md                    # Agent instructions (mirrors CLAUDE.md)
├── specs/                       # 8 specification files
│   ├── multi-model.md           #   Multi-model collaboration protocol
│   ├── agents.md                #   Agent delegation rules
│   ├── coding-style.md          #   Code style conventions
│   ├── security.md              #   Security guidelines
│   ├── testing.md               #   Testing standards
│   ├── git-workflow.md          #   Git conventions
│   ├── performance.md           #   Performance optimization
│   └── search.md                #   Search & evidence rules
├── commands/                    # 5 slash commands
│   ├── research.md              #   /research - constraint generation
│   ├── ideate.md                #   /ideate - parallel solution design
│   ├── plan.md                  #   /plan - zero-decision execution plan
│   ├── impl.md                  #   /impl - code implementation
│   └── verify.md                #   /verify - cross-model verification
├── prompts/                     # 16 role prompt templates
│   ├── codex/                   #   6 backend roles
│   │   ├── analyzer.md
│   │   ├── architect.md
│   │   ├── reviewer.md
│   │   ├── debugger.md
│   │   ├── tester.md
│   │   └── optimizer.md
│   ├── gemini/                  #   7 frontend roles
│   │   ├── analyzer.md
│   │   ├── architect.md
│   │   ├── reviewer.md
│   │   ├── frontend.md
│   │   ├── debugger.md
│   │   ├── tester.md
│   │   └── optimizer.md
│   └── claude/                  #   3 orchestration roles
│       ├── orchestrator.md
│       ├── reviewer.md
│       └── analyzer.md
├── agents/                      # 15 specialized agents
├── hooks/hooks.json             # Lifecycle hooks
├── scripts/session-id-saver.js  # Auto SESSION_ID persistence
├── skills/multi-ai/SKILL.md    # Multi-AI coordination skill
└── install.sh                   # One-line installer
```

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/code) (required)
- [Codex CLI](https://github.com/openai/codex) (optional, for backend collaboration)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) (optional, for frontend collaboration)

### Install

```bash
git clone https://github.com/anthropics/fantayspec.git
cd fantayspec
chmod +x install.sh
./install.sh
```

### Configure MCP Servers

After installation, set up MCP connections for Codex and Gemini in `~/.claude/.mcp.json`:

```json
{
  "mcpServers": {
    "codex": {
      "command": "codex",
      "args": ["mcp-server"]
    },
    "gemini": {
      "command": "gemini",
      "args": ["--mcp"]
    }
  }
}
```

### Usage

```bash
# Start Claude Code
claude

# Run the workflow
/research implement user authentication with JWT
# → Codex + Gemini analyze feasibility in parallel
# → Quality gate: score ≥ 7 to proceed

/ideate
# → Both models propose 2+ solutions each
# → Claude compares, you pick the best

/plan
# → Zero-decision execution plan with file paths

/impl
# → Codex generates backend, Gemini generates frontend
# → Claude reviews, refactors, applies

/verify
# → Cross-model review (Codex: security, Gemini: a11y)
# → Score ≥ 7 = pass
```

## Key Features

### Proactive Multi-Model (Auto-Triggered)

Claude Code **automatically** calls external models based on task type:

| Task Type | Auto Behavior |
|:---|:---|
| Frontend/UI/CSS | → Gemini called automatically |
| Backend/API/DB | → Codex called automatically |
| Full-stack | → Both called **in parallel** |
| Code review | → Both reviewers called in parallel |

### SESSION_ID Persistence (Mechanical Guarantee)

A PostToolUse hook automatically saves SESSION_IDs from every Codex/Gemini call to `.fantayspec/sessions.md`. No context lost after `/clear`.

### Quality Gates

Every phase scores output 0-10. Score < 7 blocks progression and requests more information.

### Role Prompts (Inline)

Each model call includes domain-specific constraints directly in the prompt — no extra file reads needed:

```
ROLE: Backend Architect — Expert in API design, database, auth, security.
TASK: [your task]
OUTPUT: Unified Diff Patch ONLY.
```

## Customization

### Add Your Own Specs

Create `~/.claude/specs/your-spec.md` and add it to the table in `CLAUDE.md`.

### Add Role Prompts

Create `~/.claude/prompts/{codex,gemini,claude}/your-role.md` following the existing pattern.

### Modify Quality Gate Threshold

Edit the `≥ 7` threshold in each command file under the "质量门" section.

## Philosophy

1. **Mechanical > Behavioral** — Use hooks for guarantees, not LLM self-discipline
2. **Parallel > Serial** — Independent tasks must run concurrently
3. **Inline > Reference** — Embed constraints in prompts, don't require extra Read calls
4. **Zero-Decision Plans** — Execution phase is pure mechanical operation
5. **Cross-Model Verification** — No single model reviews its own work

## License

MIT
