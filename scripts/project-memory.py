#!/usr/bin/env python3
"""Project Memory for FantaySpec v3.0

Runs on PostToolUse. Captures significant tool results and stores them
in .fantayspec/memory.json for cross-session continuity.

Inspired by oh-my-claudecode's project-memory-posttool.mjs.
"""

import hashlib
import json
import os
import sys
import time
from pathlib import Path

MAX_MEMORIES = 100
MAX_CONTENT_LENGTH = 500
DEDUP_WINDOW_SEC = 30


def get_memory_path(cwd: str) -> Path:
    """Get or create memory file path."""
    fantayspec = Path(cwd) / ".fantayspec"
    if not fantayspec.is_dir():
        return Path("")  # No .fantayspec project, skip
    return fantayspec / "memory.json"


def load_memories(path: Path) -> list[dict]:
    """Load existing memories."""
    if not path.exists():
        return []
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return []


def save_memories(path: Path, memories: list[dict]) -> None:
    """Save memories to file, keeping only the latest MAX_MEMORIES."""
    memories = memories[-MAX_MEMORIES:]
    path.write_text(json.dumps(memories, ensure_ascii=False, indent=2), encoding="utf-8")


def content_hash(content: str) -> str:
    """Generate a short hash for deduplication."""
    return hashlib.sha256(content.encode()).hexdigest()[:12]


def is_significant_tool(tool_name: str) -> bool:
    """Determine if a tool result is worth remembering."""
    # Skip low-value tools
    skip_tools = {
        "Read", "Glob", "Grep", "Bash",  # Discovery tools - too noisy
        "TaskCreate", "TaskUpdate", "TaskGet", "TaskList",  # Task management
    }
    return tool_name not in skip_tools


def extract_summary(tool_name: str, result: str) -> str | None:
    """Extract a meaningful summary from tool result."""
    if not result or len(result) < 20:
        return None

    # Truncate long results
    if len(result) > MAX_CONTENT_LENGTH:
        result = result[:MAX_CONTENT_LENGTH] + "..."

    return result


def main():
    cwd = os.getcwd()
    memory_path = get_memory_path(cwd)
    if not memory_path.name:
        print(json.dumps({"result": ""}))
        return

    # Read hook input
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, EOFError):
        print(json.dumps({"result": ""}))
        return

    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})
    tool_result = hook_input.get("tool_result", "")

    # Only capture significant tools
    if not is_significant_tool(tool_name):
        print(json.dumps({"result": ""}))
        return

    # Extract summary
    summary = extract_summary(tool_name, str(tool_result)[:1000])
    if not summary:
        print(json.dumps({"result": ""}))
        return

    # Build memory entry
    now = time.time()
    entry = {
        "timestamp": now,
        "tool": tool_name,
        "summary": summary,
        "hash": content_hash(f"{tool_name}:{summary}"),
    }

    # Add file context if available
    if isinstance(tool_input, dict):
        file_path = tool_input.get("file_path", "")
        if file_path:
            entry["file"] = file_path

    # Load, deduplicate, save
    memories = load_memories(memory_path)

    # Check for duplicate within dedup window
    for existing in reversed(memories):
        if now - existing.get("timestamp", 0) > DEDUP_WINDOW_SEC:
            break
        if existing.get("hash") == entry["hash"]:
            print(json.dumps({"result": ""}))
            return

    memories.append(entry)
    save_memories(memory_path, memories)

    print(json.dumps({"result": ""}))


if __name__ == "__main__":
    main()
