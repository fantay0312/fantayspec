#!/bin/bash
# FantaySpec v3.0 — Complete Installer
# Configures both Claude Code and Codex CLI
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CODEX_DIR="$HOME/.codex"

echo "╔══════════════════════════════════════════╗"
echo "║     FantaySpec v3.0 Complete Installer    ║"
echo "║  Claude Code + Codex CLI Configuration    ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─── Prerequisites ───
echo "Checking prerequisites..."
check() { command -v "$1" &>/dev/null && echo "  ✓ $1" || echo "  ✗ $1 (install: $2)"; }
check "claude" "https://claude.ai/code"
check "codex" "npm i -g @openai/codex"
check "gemini" "https://github.com/google-gemini/gemini-cli"
echo ""

# ─── Backup ───
backup() {
  local dir="$1" name="$2"
  if [ -f "$dir/CLAUDE.md" ] || [ -f "$dir/AGENTS.md" ]; then
    local bak="$dir/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$bak"
    for f in CLAUDE.md AGENTS.md; do [ -f "$dir/$f" ] && cp "$dir/$f" "$bak/"; done
    for d in commands specs prompts agents hooks scripts skills; do
      [ -d "$dir/$d" ] && cp -r "$dir/$d" "$bak/"
    done
    echo "  ✓ $name backup → $bak"
  fi
}

echo "Backing up existing configs..."
backup "$CLAUDE_DIR" "Claude Code"
backup "$CODEX_DIR" "Codex"
echo ""

# ─── Install Claude Code ───
echo "Installing Claude Code configuration..."
SRC="$SCRIPT_DIR/claude-code"

cp "$SRC/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
cp "$SRC/AGENTS.md" "$CLAUDE_DIR/AGENTS.md"
echo "  ✓ CLAUDE.md + AGENTS.md"

mkdir -p "$CLAUDE_DIR/specs" && cp "$SRC/specs/"*.md "$CLAUDE_DIR/specs/"
echo "  ✓ specs/"

mkdir -p "$CLAUDE_DIR/commands" && cp "$SRC/commands/"*.md "$CLAUDE_DIR/commands/"
echo "  ✓ commands/"

mkdir -p "$CLAUDE_DIR/prompts/codex" "$CLAUDE_DIR/prompts/gemini" "$CLAUDE_DIR/prompts/claude"
cp "$SRC/prompts/codex/"*.md "$CLAUDE_DIR/prompts/codex/"
cp "$SRC/prompts/gemini/"*.md "$CLAUDE_DIR/prompts/gemini/"
cp "$SRC/prompts/claude/"*.md "$CLAUDE_DIR/prompts/claude/"
echo "  ✓ prompts/ (16 role templates)"

mkdir -p "$CLAUDE_DIR/agents" && cp "$SRC/agents/"*.md "$CLAUDE_DIR/agents/"
echo "  ✓ agents/"

mkdir -p "$CLAUDE_DIR/hooks" && cp "$SRC/hooks/hooks.json" "$CLAUDE_DIR/hooks/"
echo "  ✓ hooks/"

mkdir -p "$CLAUDE_DIR/scripts" && cp "$SRC/scripts/"* "$CLAUDE_DIR/scripts/"
echo "  ✓ scripts/"

# Skills - copy all subdirectories
for skill_dir in "$SRC/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$CLAUDE_DIR/skills/$skill_name"
  cp -R "$skill_dir"* "$CLAUDE_DIR/skills/$skill_name/" 2>/dev/null || true
done
echo "  ✓ skills/ ($(ls -d "$SRC/skills"/*/ 2>/dev/null | wc -l | tr -d ' ') skills)"

# Templates (user must configure manually)
if [ -f "$SRC/settings.json.template" ] && [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  cp "$SRC/settings.json.template" "$CLAUDE_DIR/settings.json"
  echo "  ✓ settings.json (from template — customize!)"
else
  echo "  - settings.json exists, skipped (template at $SRC/settings.json.template)"
fi

if [ -f "$SRC/mcp.json.template" ] && [ ! -f "$CLAUDE_DIR/.mcp.json" ]; then
  cp "$SRC/mcp.json.template" "$CLAUDE_DIR/.mcp.json"
  echo "  ✓ .mcp.json (from template — add your API keys!)"
else
  echo "  - .mcp.json exists, skipped (template at $SRC/mcp.json.template)"
fi

echo ""

# ─── Install Codex ───
echo "Installing Codex configuration..."
SRC="$SCRIPT_DIR/codex"

if [ ! -d "$CODEX_DIR" ]; then
  mkdir -p "$CODEX_DIR"
  echo "  Created $CODEX_DIR"
fi

cp "$SRC/AGENTS.md" "$CODEX_DIR/AGENTS.md"
cp "$SRC/orchestrator.yaml" "$CODEX_DIR/orchestrator.yaml"
cp "$SRC/hooks.json" "$CODEX_DIR/hooks.json"
echo "  ✓ AGENTS.md + orchestrator.yaml + hooks.json"

for d in commands agents rules contexts templates workflows references; do
  if [ -d "$SRC/$d" ]; then
    mkdir -p "$CODEX_DIR/$d"
    cp "$SRC/$d/"* "$CODEX_DIR/$d/" 2>/dev/null || true
    echo "  ✓ $d/"
  fi
done

# Skills
for skill_dir in "$SRC/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$CODEX_DIR/skills/$skill_name"
  cp -R "$skill_dir"* "$CODEX_DIR/skills/$skill_name/" 2>/dev/null || true
done
echo "  ✓ skills/ ($(ls -d "$SRC/skills"/*/ 2>/dev/null | wc -l | tr -d ' ') skills)"

if [ -f "$SRC/config.toml.template" ] && [ ! -f "$CODEX_DIR/config.toml" ]; then
  cp "$SRC/config.toml.template" "$CODEX_DIR/config.toml"
  echo "  ✓ config.toml (from template)"
else
  echo "  - config.toml exists, skipped (template at $SRC/config.toml.template)"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║         ✅ Installation Complete           ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Claude Code:"
echo "  - Config: $CLAUDE_DIR/"
echo "  - Skills: $(ls -d "$CLAUDE_DIR/skills"/*/ 2>/dev/null | wc -l | tr -d ' ') installed"
echo "  - Agents: $(ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ') installed"
echo ""
echo "Codex CLI:"
echo "  - Config: $CODEX_DIR/"
echo "  - Skills: $(ls -d "$CODEX_DIR/skills"/*/ 2>/dev/null | wc -l | tr -d ' ') installed"
echo "  - Agents: $(ls "$CODEX_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ') installed"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/settings.json (if created from template)"
echo "  2. Edit ~/.claude/.mcp.json — add your API keys"
echo "  3. Edit ~/.codex/config.toml (if created from template)"
echo "  4. Install Codex plugin: claude plugin marketplace add openai/codex-plugin-cc"
echo "  5. Restart: claude"
