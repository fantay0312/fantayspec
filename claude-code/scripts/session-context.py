#!/usr/bin/env python3
"""Session Context Injector for FantaySpec v3.0

Runs on SessionStart hook. Automatically detects and injects:
1. Project task status (from .fantayspec/)
2. Project memory (from .fantayspec/memory.json)
3. Git context (branch, recent commits, uncommitted changes)
4. Smart P.A.C.E. routing suggestion
5. Relevant specs hint (based on detected file types)

Output goes to stdout and is injected as system context.
"""

import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path


def run_cmd(cmd: list[str], cwd: str | None = None) -> str:
    """Run a command and return stdout, empty string on failure."""
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=5, cwd=cwd
        )
        return result.stdout.strip()
    except Exception:
        return ""


def get_git_context(cwd: str) -> str:
    """Get compact git context."""
    parts = []

    branch = run_cmd(["git", "branch", "--show-current"], cwd)
    if branch:
        parts.append(f"Branch: {branch}")

    log = run_cmd(["git", "log", "--oneline", "-3", "--no-decorate"], cwd)
    if log:
        parts.append(f"Recent commits:\n{log}")

    status = run_cmd(["git", "diff", "--stat", "--cached", "HEAD"], cwd)
    unstaged = run_cmd(["git", "diff", "--stat"], cwd)
    if status:
        parts.append(f"Staged:\n{status}")
    if unstaged:
        parts.append(f"Unstaged:\n{unstaged}")

    return "\n".join(parts) if parts else ""


def get_task_status(cwd: str) -> str:
    """Read .fantayspec/ task status with completion tracking."""
    fantayspec = Path(cwd) / ".fantayspec"
    if not fantayspec.is_dir():
        return ""

    parts = ["[FantaySpec Project Detected]"]

    # Check plan with completion stats
    plan = fantayspec / "plan.md"
    if plan.exists():
        content = plan.read_text(encoding="utf-8")
        incomplete = len(re.findall(r"^- \[ \]", content, re.MULTILINE))
        complete = len(re.findall(r"^- \[x\]", content, re.MULTILINE))
        total = incomplete + complete

        if total > 0:
            pct = round(complete / total * 100)
            parts.append(f"Plan: {complete}/{total} tasks done ({pct}%)")
            if incomplete > 0:
                # Show next incomplete tasks
                lines = content.splitlines()
                next_tasks = []
                for line in lines:
                    if line.strip().startswith("- [ ]") and len(next_tasks) < 3:
                        next_tasks.append(line.strip())
                if next_tasks:
                    parts.append("Next tasks:\n" + "\n".join(next_tasks))
        else:
            lines = content.splitlines()[:15]
            parts.append(f"Plan:\n" + "\n".join(lines))

    # Check progress
    progress = fantayspec / "progress.md"
    if progress.exists():
        lines = progress.read_text(encoding="utf-8").splitlines()[:10]
        parts.append(f"Progress:\n" + "\n".join(lines))

    # Check constraints (pointer only)
    constraints = fantayspec / "constraints.md"
    if constraints.exists():
        parts.append(f"Constraints available: {constraints}")

    return "\n".join(parts) if len(parts) > 1 else ""


def get_project_memory(cwd: str) -> str:
    """Load recent project memories for context injection."""
    memory_path = Path(cwd) / ".fantayspec" / "memory.json"
    if not memory_path.exists():
        return ""

    try:
        memories = json.loads(memory_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return ""

    if not memories:
        return ""

    # Get last 5 memories within 24 hours
    now = time.time()
    recent = [m for m in memories if now - m.get("timestamp", 0) < 86400]
    recent = recent[-5:]

    if not recent:
        return ""

    lines = ["[Project Memory - Recent]"]
    for m in recent:
        tool = m.get("tool", "?")
        summary = m.get("summary", "")[:200]
        file_ctx = m.get("file", "")
        line = f"- [{tool}]"
        if file_ctx:
            line += f" {file_ctx}:"
        line += f" {summary}"
        lines.append(line)

    return "\n".join(lines)


def suggest_pace_route(cwd: str) -> str:
    """Suggest P.A.C.E. routing based on project state."""
    fantayspec = Path(cwd) / ".fantayspec"

    # Count changed files from git
    diff_stat = run_cmd(["git", "diff", "--name-only"], cwd)
    staged_stat = run_cmd(["git", "diff", "--cached", "--name-only"], cwd)
    changed_files = set()
    if diff_stat:
        changed_files.update(diff_stat.splitlines())
    if staged_stat:
        changed_files.update(staged_stat.splitlines())

    # Check if plan exists with many tasks
    plan = fantayspec / "plan.md" if fantayspec.is_dir() else None
    if plan and plan.exists():
        content = plan.read_text(encoding="utf-8")
        task_count = len(re.findall(r"^- \[", content, re.MULTILINE))
        if task_count > 10:
            return "[P.A.C.E.] 检测到复杂计划 (>10 tasks)，建议路径 C"

    if len(changed_files) > 10:
        return f"[P.A.C.E.] 检测到 {len(changed_files)} 个变更文件，建议路径 C (复杂)"
    elif len(changed_files) > 1:
        return f"[P.A.C.E.] 检测到 {len(changed_files)} 个变更文件，建议路径 B (标准)"

    return ""


def detect_relevant_specs(cwd: str) -> str:
    """Suggest which specs to load based on project file types."""
    specs_dir = Path.home() / ".claude" / "specs"
    if not specs_dir.is_dir():
        return ""

    hints = []
    cwd_path = Path(cwd)

    # Quick checks (don't rglob the whole tree - just top 2 levels)
    try:
        top_files = list(cwd_path.glob("*")) + list(cwd_path.glob("*/*"))
        extensions = {f.suffix for f in top_files if f.is_file()}
    except OSError:
        return ""

    if ".ts" in extensions or ".tsx" in extensions or ".py" in extensions:
        hints.append("coding-style.md")
    if any(f.name.startswith("test") or ".test." in f.name or ".spec." in f.name
           for f in top_files if f.is_file()):
        hints.append("testing.md")
    if (cwd_path / ".git").exists():
        hints.append("git-workflow.md")

    if hints:
        spec_list = ", ".join(f"~/.claude/specs/{h}" for h in hints)
        return f"Suggested specs: {spec_list}"

    return ""


def main():
    cwd = os.getcwd()
    sections = []

    # 1. Task status with completion tracking
    task_status = get_task_status(cwd)
    if task_status:
        sections.append(task_status)

    # 2. Project memory (recent discoveries)
    memory = get_project_memory(cwd)
    if memory:
        sections.append(memory)

    # 3. Git context
    git_ctx = get_git_context(cwd)
    if git_ctx:
        sections.append(f"[Git Context]\n{git_ctx}")

    # 4. Smart P.A.C.E. routing
    pace = suggest_pace_route(cwd)
    if pace:
        sections.append(pace)

    # 5. Spec hints
    spec_hints = detect_relevant_specs(cwd)
    if spec_hints:
        sections.append(spec_hints)

    if sections:
        output = "\n\n".join(sections)
        print(json.dumps({"result": output}))
    else:
        print(json.dumps({"result": ""}))


if __name__ == "__main__":
    main()
