---
name: FantaySpec Explore
description: 需求探索，适用于需求不明确或需要技术调研的场景。完成后请 /clear
allowed-tools: Read, Glob, Grep, WebSearch, WebFetch, Skill, mcp__auggie-mcp__codebase-retrieval
---

# 需求探索

**场景**: $ARGUMENTS

## 适用情况

- 需求模糊，需要澄清
- 需要技术调研和可行性分析
- 现有代码库复杂，需要深入理解
- 多种实现方案需要评估

## 核心原则

- 探索阶段**不做决定**，只收集信息
- 输出**问题清单**和**方案对比**
- 探索完成后转入 research 阶段明确需求

## 执行步骤

### 1. 需求分析

识别需求中的不确定因素：

```markdown
## 需求拆解

### 明确部分
- [ ] 已知1: 描述
- [ ] 已知2: 描述

### 不确定部分
- [ ] 不确定1: 描述 → 需要调研
- [ ] 不确定2: 描述 → 需要用户澄清
```

### 2. 代码库探索

使用 `mcp__auggie-mcp__codebase-retrieval` 或 Glob/Grep 深入理解现有代码：

```
探索目标:
- 相关模块结构
- 现有实现模式
- 技术栈和依赖
- 可复用的代码
```

### 3. 多模型调研

**Codex (技术可行性)** - 使用 `/collaborating-with-codex`:
```
Skill: collaborating-with-codex
Args: |
  调研需求: $ARGUMENTS

  分析:
  1. 技术可行性评估
  2. 潜在方案 (A/B/C)
  3. 各方案优缺点
  4. 推荐方案及原因

  输出格式: JSON { feasibility, solutions[], recommendation }
```

**Gemini (用户体验)** - 使用 `/collaborating-with-gemini`:
```
Skill: collaborating-with-gemini
Args: |
  调研需求: $ARGUMENTS

  分析:
  1. 用户体验影响
  2. UI/UX 可选方案
  3. 各方案优缺点
  4. 业界最佳实践

  输出格式: JSON { ux_impact, solutions[], best_practices[] }
```

### 4. 外部资源调研（可选）

若需要查阅文档或最新技术：
- 使用 `WebSearch` 搜索相关技术方案
- 使用 `WebFetch` 获取官方文档

### 5. 生成探索报告

整合所有信息，生成报告：

```markdown
## 探索报告

### 需求理解
[对需求的当前理解]

### 技术环境
- 现有技术栈: ...
- 相关模块: ...
- 可复用代码: ...

### 方案对比

| 方案 | 优点 | 缺点 | 工作量 | 风险 |
|------|------|------|--------|------|
| A: 描述 | ... | ... | 高/中/低 | 高/中/低 |
| B: 描述 | ... | ... | 高/中/低 | 高/中/低 |

### 开放问题

需要用户决策：
1. 问题1?
2. 问题2?

需要进一步调研：
1. 调研点1
2. 调研点2

### 推荐路径
[综合分析后的推荐方向]
```

### 6. 用户确认

使用 `AskUserQuestion` 获取用户对开放问题的决策。

### 7. 保存状态

写入 `.fantayspec/explore.md` 保存探索报告。
更新 `.fantayspec/context.md` 追加探索摘要。

## 完成提示

```
✅ 需求探索完成

探索报告: .fantayspec/explore.md
方案数: X | 开放问题: X

下一步:
1. 输入 /clear 清空上下文
2. 使用 /fantayspec:research <明确的需求> 开始需求研究
   或继续 /fantayspec:explore <新的探索点>
```

**重要**: 完成后请执行 `/clear`
