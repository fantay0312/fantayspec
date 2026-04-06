#!/bin/bash
# FantaySpec v3.0 — Complete Installer
# Configures Claude Code + Codex CLI with shared skills
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CODEX_DIR="$HOME/.codex"

echo "╔══════════════════════════════════════════╗"
echo "║     FantaySpec v3.0 Complete Installer    ║"
echo "║  Claude Code + Codex CLI + Shared Skills  ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─── Prerequisites ───
echo "Checking prerequisites..."
check() { command -v "$1" &>/dev/null && echo "  ✓ $1" || echo "  ✗ $1 ($2)"; }
check "claude" "https://claude.ai/code"
check "codex" "npm i -g @openai/codex"
check "gemini" "https://github.com/google-gemini/gemini-cli"
check "python3" "required for hook scripts"
echo ""

# ─── Backup ───
backup() {
  local dir="$1" name="$2"
  if [ -d "$dir" ] && [ "$(ls -A "$dir" 2>/dev/null)" ]; then
    local bak="$dir/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$bak"
    for f in CLAUDE.md AGENTS.md; do [ -f "$dir/$f" ] && cp "$dir/$f" "$bak/"; done
    for d in commands specs prompts agents hooks scripts; do
      [ -d "$dir/$d" ] && cp -r "$dir/$d" "$bak/" 2>/dev/null
    done
    echo "  ✓ $name → $bak"
  fi
}
echo "Backing up..."
backup "$CLAUDE_DIR" "Claude Code"
backup "$CODEX_DIR" "Codex"
echo ""

# ═══ CLAUDE CODE ═══
echo "Installing Claude Code..."
SRC="$SCRIPT_DIR/claude-code"

cp "$SRC/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
cp "$SRC/AGENTS.md" "$CLAUDE_DIR/AGENTS.md"

mkdir -p "$CLAUDE_DIR/specs" && cp "$SRC/specs/"*.md "$CLAUDE_DIR/specs/"
mkdir -p "$CLAUDE_DIR/commands" && cp "$SRC/commands/"*.md "$CLAUDE_DIR/commands/"

mkdir -p "$CLAUDE_DIR/prompts/codex" "$CLAUDE_DIR/prompts/gemini" "$CLAUDE_DIR/prompts/claude"
cp "$SRC/prompts/codex/"*.md "$CLAUDE_DIR/prompts/codex/"
cp "$SRC/prompts/gemini/"*.md "$CLAUDE_DIR/prompts/gemini/"
cp "$SRC/prompts/claude/"*.md "$CLAUDE_DIR/prompts/claude/"

mkdir -p "$CLAUDE_DIR/agents" && cp "$SRC/agents/"*.md "$CLAUDE_DIR/agents/"
mkdir -p "$CLAUDE_DIR/hooks" && cp "$SRC/hooks/hooks.json" "$CLAUDE_DIR/hooks/"
mkdir -p "$CLAUDE_DIR/scripts" && cp "$SRC/scripts/"* "$CLAUDE_DIR/scripts/"

# Templates (don't overwrite existing)
[ ! -f "$CLAUDE_DIR/settings.json" ] && cp "$SRC/settings.json.template" "$CLAUDE_DIR/settings.json" && echo "  ✓ settings.json (from template)"
[ ! -f "$CLAUDE_DIR/.mcp.json" ] && cp "$SRC/mcp.json.template" "$CLAUDE_DIR/.mcp.json" && echo "  ✓ .mcp.json (from template)"

echo "  ✓ Claude Code core installed"

# ═══ CODEX ═══
echo "Installing Codex..."
SRC="$SCRIPT_DIR/codex"
mkdir -p "$CODEX_DIR"

cp "$SRC/AGENTS.md" "$CODEX_DIR/AGENTS.md"
cp "$SRC/orchestrator.yaml" "$CODEX_DIR/orchestrator.yaml"
cp "$SRC/hooks.json" "$CODEX_DIR/hooks.json"

for d in commands agents rules contexts templates workflows references; do
  [ -d "$SRC/$d" ] && mkdir -p "$CODEX_DIR/$d" && cp "$SRC/$d/"* "$CODEX_DIR/$d/" 2>/dev/null
done

[ ! -f "$CODEX_DIR/config.toml" ] && cp "$SRC/config.toml.template" "$CODEX_DIR/config.toml" && echo "  ✓ config.toml (from template)"

echo "  ✓ Codex core installed"

# ═══ SHARED SKILLS ═══
echo "Installing shared skills..."
SKILLS_SRC="$SCRIPT_DIR/shared/skills"
SKILL_COUNT=0

for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name=$(basename "$skill_dir")

  # Install to Claude Code
  mkdir -p "$CLAUDE_DIR/skills/$skill_name"
  cp -R "$skill_dir"* "$CLAUDE_DIR/skills/$skill_name/" 2>/dev/null || true

  # Install to Codex
  mkdir -p "$CODEX_DIR/skills/$skill_name"
  cp -R "$skill_dir"* "$CODEX_DIR/skills/$skill_name/" 2>/dev/null || true

  SKILL_COUNT=$((SKILL_COUNT + 1))
done

echo "  ✓ $SKILL_COUNT skills → both platforms"

# ═══ Summary ═══
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║         ✅ Installation Complete           ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Claude Code ($CLAUDE_DIR):"
echo "  Skills: $(ls -d "$CLAUDE_DIR/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')"
echo "  Agents: $(ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "  Commands: $(ls "$CLAUDE_DIR/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo "Codex CLI ($CODEX_DIR):"
echo "  Skills: $(ls -d "$CODEX_DIR/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')"
echo "  Agents: $(ls "$CODEX_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "  Commands: $(ls "$CODEX_DIR/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/.mcp.json — add API keys"
echo "  2. Edit ~/.codex/config.toml — customize model"
echo "  3. claude plugin marketplace add openai/codex-plugin-cc"
echo "  4. claude plugin install codex@openai-codex"
echo "  5. Restart: claude"
