---
name: init
description: 初始化 FantaySpec 项目环境
allowed-tools: Read, Write, Bash, Glob
---

# FantaySpec 初始化

## 执行步骤

### 1. 创建目录结构

```bash
mkdir -p .fantayspec/archive
mkdir -p .ai_state/experience/learned
mkdir -p .ai_state/checkpoints
mkdir -p .knowledge/{project,standards,tech}
```

### 2. 检测工具可用性

检测 Codex 和 Gemini：

```bash
# Codex CLI
which codex && codex --version

# Gemini CLI
which gemini && gemini --version
```

### 3. 生成配置文件

读取模板 `templates/config.toml.template`，生成 `.fantayspec/config.toml`：

```toml
# FantaySpec 配置

[models]
frontend = "gemini"
backend = "codex"

[routing]
codex = "skill"    # 或 "unavailable"
gemini = "skill"   # 或 "unavailable"

[workflow]
auto_clear = true
```

### 4. 初始化状态文件

读取模板 `templates/ai-state.md`，生成 `.fantayspec/context.md`：

```markdown
# 项目上下文

## 项目信息
- 名称: [项目目录名]
- 初始化: [时间戳]
- 路径: [当前目录]

## 当前状态
- 阶段: 初始化完成
- 任务: 无

## 下一步
执行 /research <需求> 开始开发
```

### 5. 创建归档索引

```markdown
# 归档索引

| 日期 | 任务 | 状态 | 目录 |
|:---|:---|:---|:---|
```

### 6. 生成知识库 README

为 `.knowledge/` 各目录生成 README：

- `project/README.md` - 项目背景说明
- `standards/README.md` - 开发规范说明
- `tech/README.md` - 技术文档说明

## 完成提示

```
✅ FantaySpec 初始化完成

工具状态:
  Codex: ✓ 可用 (skill)
  Gemini: ✓ 可用 (skill)

目录结构:
  .fantayspec/     项目状态
  .ai_state/       AI 状态
  .knowledge/      知识库

工作流:
  init → research → plan → impl → verify → archive

下一步:
1. /clear 清空上下文
2. /research <需求> 开始开发
   或 /explore <场景> 先探索
```
