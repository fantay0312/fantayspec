---
name: plan
description: 生成零决策执行计划。完成后请 /clear
allowed-tools: Read, Write, Glob, Grep
---

# 执行计划

## 前置条件

读取 `.fantayspec/constraints.md`。
若不存在，提示先执行 `/research`。

## 核心原则

- 计划必须**零决策**：执行阶段纯机械操作
- 每个步骤包含：文件路径、具体修改、验证方法
- 消除所有"待定"、"视情况而定"等模糊表述

## 执行步骤

### 1. 加载状态

```
Read .fantayspec/constraints.md
Read .fantayspec/context.md
```

### 2. 加载技术知识

检查并读取 `.knowledge/tech/` 目录：
- 技术栈说明
- 架构文档
- API 规范

### 3. 设计方案

基于约束集和技术知识，设计实现方案：
- 确定技术选型（具体版本）
- 确定文件修改清单
- 确定执行顺序

### 4. 生成计划

```markdown
# 执行计划

## 任务清单

- [ ] Task 1: 描述
  - 文件: path/to/file.ts:L10-L50
  - 修改: 具体修改内容
  - 验证: 如何验证

## 执行顺序
Task 1 → Task 2 → Task 3

## 风险点
- 风险: 缓解措施
```

### 5. 用户确认

展示计划，使用 `AskUserQuestion` 确认。

### 6. 保存计划

- `.fantayspec/plan.md` - 执行计划
- `.fantayspec/progress.md` - 进度跟踪

## 完成提示

```
✅ 计划生成完成

计划: .fantayspec/plan.md
任务数: X | 文件数: X

下一步:
1. /clear 清空上下文
2. /impl 开始实现
```
