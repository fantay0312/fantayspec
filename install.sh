#!/bin/bash
# FantaySpec v3.0 Installer
# Multi-Model Orchestration Framework for Claude Code
# Requires: Claude Code, Codex CLI, Gemini CLI

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "╔══════════════════════════════════════╗"
echo "║     FantaySpec v3.0 Installer        ║"
echo "║  Multi-Model Orchestration Framework ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Check prerequisites
check_command() {
  if command -v "$1" &>/dev/null; then
    echo "  ✓ $1 found"
    return 0
  else
    echo "  ✗ $1 not found (optional: $2)"
    return 1
  fi
}

echo "Checking prerequisites..."
check_command "claude" "Required - install from https://claude.ai/code" || exit 1
check_command "codex" "Optional - install with: npm i -g @openai/codex" || true
check_command "gemini" "Optional - install from https://github.com/google-gemini/gemini-cli" || true
echo ""

# Backup existing config
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"
  echo "Backing up existing config to $BACKUP_DIR..."
  mkdir -p "$BACKUP_DIR"
  cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/" 2>/dev/null || true
  cp "$CLAUDE_DIR/AGENTS.md" "$BACKUP_DIR/" 2>/dev/null || true
  cp -r "$CLAUDE_DIR/commands" "$BACKUP_DIR/" 2>/dev/null || true
  cp -r "$CLAUDE_DIR/specs" "$BACKUP_DIR/" 2>/dev/null || true
  cp -r "$CLAUDE_DIR/prompts" "$BACKUP_DIR/" 2>/dev/null || true
  echo "  ✓ Backup saved"
fi

# Install core files
echo ""
echo "Installing FantaySpec v3.0..."

cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
cp "$SCRIPT_DIR/AGENTS.md" "$CLAUDE_DIR/AGENTS.md"
echo "  ✓ CLAUDE.md + AGENTS.md"

# Specs
mkdir -p "$CLAUDE_DIR/specs"
cp "$SCRIPT_DIR/specs/"*.md "$CLAUDE_DIR/specs/"
echo "  ✓ specs/ ($(ls "$SCRIPT_DIR/specs/"*.md | wc -l | tr -d ' ') files)"

# Commands
mkdir -p "$CLAUDE_DIR/commands"
cp "$SCRIPT_DIR/commands/"*.md "$CLAUDE_DIR/commands/"
echo "  ✓ commands/ ($(ls "$SCRIPT_DIR/commands/"*.md | wc -l | tr -d ' ') files)"

# Role prompts
mkdir -p "$CLAUDE_DIR/prompts/codex" "$CLAUDE_DIR/prompts/gemini" "$CLAUDE_DIR/prompts/claude"
cp "$SCRIPT_DIR/prompts/codex/"*.md "$CLAUDE_DIR/prompts/codex/"
cp "$SCRIPT_DIR/prompts/gemini/"*.md "$CLAUDE_DIR/prompts/gemini/"
cp "$SCRIPT_DIR/prompts/claude/"*.md "$CLAUDE_DIR/prompts/claude/"
echo "  ✓ prompts/ (codex/6 + gemini/7 + claude/3)"

# Agents
mkdir -p "$CLAUDE_DIR/agents"
cp "$SCRIPT_DIR/agents/"*.md "$CLAUDE_DIR/agents/"
echo "  ✓ agents/ ($(ls "$SCRIPT_DIR/agents/"*.md | wc -l | tr -d ' ') files)"

# Hooks
mkdir -p "$CLAUDE_DIR/hooks"
cp "$SCRIPT_DIR/hooks/hooks.json" "$CLAUDE_DIR/hooks/"
echo "  ✓ hooks/hooks.json"

# Scripts
mkdir -p "$CLAUDE_DIR/scripts"
cp "$SCRIPT_DIR/scripts/"* "$CLAUDE_DIR/scripts/"
echo "  ✓ scripts/"

# Skills
mkdir -p "$CLAUDE_DIR/skills/multi-ai"
cp "$SCRIPT_DIR/skills/multi-ai/SKILL.md" "$CLAUDE_DIR/skills/multi-ai/"
echo "  ✓ skills/multi-ai"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║     ✅ Installation Complete          ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Installed: 49 files"
echo "  - 2 core configs (CLAUDE.md, AGENTS.md)"
echo "  - 8 specs"
echo "  - 5 commands (/research /ideate /plan /impl /verify)"
echo "  - 16 role prompts (codex/6 + gemini/7 + claude/3)"
echo "  - 15 agents"
echo "  - 1 hook config + 1 script"
echo "  - 1 skill (multi-ai)"
echo ""
echo "Next steps:"
echo "  1. Configure MCP servers for Codex and Gemini"
echo "  2. Restart Claude Code: claude"
echo "  3. Try: /research <your task>"
echo ""
echo "Docs: https://github.com/anthropics/fantayspec"
