---
name: research
description: 需求研究，生成约束集。完成后请 /clear
allowed-tools: Read, Glob, Grep, Skill, mcp__auggie-mcp__codebase-retrieval
---

# 需求研究

**任务**: $ARGUMENTS

## 核心原则

- 产出**约束集**，而非信息堆砌
- 每个约束缩小解空间，让后续阶段零决策
- 有歧义必须用 `AskUserQuestion` 澄清

## 执行步骤

### 1. 加载项目知识

检查并读取 `.knowledge/project/` 目录下的文件：
- 项目背景
- 业务规则
- 术语定义

### 2. 代码检索

使用 `mcp__auggie-mcp__codebase-retrieval` 检索相关代码。
若不可用，回退到 Glob + Grep。

### 3. 需求分析

根据 $ARGUMENTS 和项目知识，分析：
- 技术约束
- 业务约束
- 依赖关系
- 潜在风险

### 4. 生成约束集

```markdown
# 约束集

## 硬约束 (不可违反)
- [ ] 约束描述

## 软约束 (建议遵守)
- [ ] 约束描述

## 依赖关系
- A → B

## 开放问题
- 问题?
```

### 5. 用户确认

使用 `AskUserQuestion` 确认开放问题。

### 6. 保存状态

- `.fantayspec/constraints.md` - 约束集
- `.fantayspec/context.md` - 上下文摘要

## 完成提示

```
✅ 需求研究完成

约束集: .fantayspec/constraints.md
硬约束: X 项 | 软约束: X 项

下一步:
1. /clear 清空上下文
2. /plan 生成执行计划
```
