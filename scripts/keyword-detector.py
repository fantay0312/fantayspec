#!/usr/bin/env python3
"""Keyword Detector for FantaySpec v3.0

Runs on UserPromptSubmit. Detects workflow keywords in user input
and injects corresponding spec/command context automatically.

Inspired by oh-my-claudecode's keyword-detector.mjs.
"""

import json
import os
import sys
from pathlib import Path

SPECS_DIR = Path.home() / ".claude" / "specs"

# Keyword → (action_type, payload)
# action_type: "spec" loads a spec file, "hint" injects a text hint
KEYWORD_MAP = {
    # Chinese keywords
    "研究": ("command", "research"),
    "调研": ("command", "research"),
    "计划": ("command", "plan"),
    "规划": ("command", "plan"),
    "实现": ("command", "impl"),
    "开发": ("command", "impl"),
    "编码": ("command", "impl"),
    "验证": ("command", "verify"),
    "测试": ("spec", "testing.md"),
    "审查": ("hint", "建议使用 Codex 进行代码审查。Read ~/.claude/specs/multi-model.md 了解协作协议。"),
    "安全": ("spec", "security.md"),
    "性能": ("spec", "performance.md"),
    "部署": ("spec", "git-workflow.md"),
    "提交": ("spec", "git-workflow.md"),
    "搜索": ("spec", "search.md"),
    # English keywords
    "research": ("command", "research"),
    "plan": ("command", "plan"),
    "implement": ("command", "impl"),
    "verify": ("command", "verify"),
    "test": ("spec", "testing.md"),
    "review": ("hint", "Consider using Codex for code review. Read ~/.claude/specs/multi-model.md for collaboration protocol."),
    "security": ("spec", "security.md"),
    "performance": ("spec", "performance.md"),
    "deploy": ("spec", "git-workflow.md"),
    # Multi-model triggers
    "gemini": ("spec", "multi-model.md"),
    "codex": ("spec", "multi-model.md"),
    "前端": ("spec", "multi-model.md"),
    "后端": ("spec", "multi-model.md"),
    "ui": ("spec", "multi-model.md"),
}

# P.A.C.E. routing keywords
PACE_KEYWORDS = {
    "快速修复": "A",
    "quick fix": "A",
    "简单": "A",
    "重构": "C",
    "refactor": "C",
    "架构": "C",
    "architecture": "C",
}


def detect_keywords(user_input: str) -> list[dict]:
    """Detect keywords and return injection actions."""
    actions = []
    seen_specs = set()
    lower_input = user_input.lower()

    # Check P.A.C.E. routing first
    for keyword, path in PACE_KEYWORDS.items():
        if keyword in lower_input:
            actions.append({
                "type": "hint",
                "content": f"[P.A.C.E.] 建议使用路径 {path}。",
            })
            break

    # Check workflow keywords
    for keyword, (action_type, payload) in KEYWORD_MAP.items():
        if keyword in lower_input:
            if action_type == "spec":
                if payload not in seen_specs:
                    spec_path = SPECS_DIR / payload
                    if spec_path.exists():
                        actions.append({
                            "type": "spec_hint",
                            "content": f"[Auto] 检测到相关任务，建议加载规范: ~/.claude/specs/{payload}",
                        })
                        seen_specs.add(payload)
            elif action_type == "hint":
                actions.append({"type": "hint", "content": payload})
            elif action_type == "command":
                actions.append({
                    "type": "command_hint",
                    "content": f"[Auto] 检测到工作流关键词，建议使用 /{payload} 命令。",
                })

    return actions


def main():
    # Read hook input from stdin
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, EOFError):
        print(json.dumps({"result": ""}))
        return

    user_input = hook_input.get("prompt", "") or hook_input.get("message", "")
    if not user_input:
        print(json.dumps({"result": ""}))
        return

    actions = detect_keywords(user_input)

    if actions:
        lines = [a["content"] for a in actions[:3]]  # Max 3 hints
        output = "\n".join(lines)
        print(json.dumps({"result": output}))
    else:
        print(json.dumps({"result": ""}))


if __name__ == "__main__":
    main()
