#!/usr/bin/env python3
"""Stop Persistence for FantaySpec v3.0

Runs on Stop hook. Checks if there's an active plan with incomplete tasks.
If so, injects a "continue" message to prevent premature halting.

Inspired by oh-my-claudecode's persistent-mode.cjs.
"""

import json
import os
import re
import sys
from pathlib import Path


def check_incomplete_plan(cwd: str) -> str | None:
    """Check if .fantayspec/plan.md has incomplete tasks."""
    plan_path = Path(cwd) / ".fantayspec" / "plan.md"
    if not plan_path.exists():
        return None

    content = plan_path.read_text(encoding="utf-8")

    # Count incomplete vs complete tasks
    incomplete = len(re.findall(r"^- \[ \]", content, re.MULTILINE))
    complete = len(re.findall(r"^- \[x\]", content, re.MULTILINE))
    total = incomplete + complete

    if total == 0 or incomplete == 0:
        return None

    progress_pct = round(complete / total * 100)
    return (
        f"[FantaySpec] 计划尚未完成: {complete}/{total} ({progress_pct}%)。"
        f"还有 {incomplete} 个任务未完成。请继续执行计划中的下一个任务。"
        f"如果确实需要停止，请告知用户当前进度。"
    )


def check_incomplete_progress(cwd: str) -> str | None:
    """Check if .fantayspec/progress.md indicates ongoing work."""
    progress_path = Path(cwd) / ".fantayspec" / "progress.md"
    if not progress_path.exists():
        return None

    content = progress_path.read_text(encoding="utf-8")
    if "in_progress" in content.lower() or "进行中" in content:
        return "[FantaySpec] 检测到进行中的任务。请完成当前任务后再停止。"

    return None


def main():
    cwd = os.getcwd()

    messages = []

    plan_msg = check_incomplete_plan(cwd)
    if plan_msg:
        messages.append(plan_msg)

    progress_msg = check_incomplete_progress(cwd)
    if progress_msg:
        messages.append(progress_msg)

    if messages:
        output = "\n".join(messages)
        print(json.dumps({"result": output}))
    else:
        print(json.dumps({"result": ""}))


if __name__ == "__main__":
    main()
