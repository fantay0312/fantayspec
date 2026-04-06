---
name: kb
description: 知识库管理 - 查看、加载、搜索项目知识
allowed-tools: ["Read", "Glob", "Grep", "Write"]
---

# /kb - 知识库管理

## 用法

```bash
/kb                       # 列出知识库内容
/kb load <类别>           # 加载特定类别到上下文
/kb search <关键词>       # 搜索知识库
/kb add <类别> <内容>     # 添加知识条目
```

## 知识库结构

```
.knowledge/
├── project/      # 项目背景、业务领域、需求文档
├── standards/    # 代码规范、Git规范、审查清单
├── tech/         # 技术栈文档、API文档、架构说明
└── templates/    # 文档模板
```

## 功能

### 1. 列出知识库

```bash
/kb
```

输出示例：
```
📚 知识库概览

project/ (3 files)
  - README.md - 项目简介
  - business-rules.md - 业务规则
  - glossary.md - 术语表

standards/ (2 files)
  - coding-style.md - 代码规范
  - review-checklist.md - 审查清单

tech/ (4 files)
  - api-spec.md - API 规范
  - database-schema.md - 数据库设计
  - deployment.md - 部署文档
  - architecture.md - 架构说明
```

### 2. 加载知识

```bash
/kb load project          # 加载项目背景
/kb load standards        # 加载开发规范
/kb load tech             # 加载技术文档
/kb load all              # 加载全部（谨慎使用）
```

**自动加载时机**：
- `/research` 时自动加载 `project/`
- `/plan` 时自动加载 `tech/`
- `/review` 时自动加载 `standards/`

### 3. 搜索知识

```bash
/kb search 认证            # 搜索包含"认证"的内容
/kb search --file auth    # 搜索文件名包含"auth"的文件
```

### 4. 添加知识

```bash
/kb add project "业务规则: 用户注册需要手机号验证"
/kb add tech "API: /api/users 返回用户列表"
/kb add standards "规范: 函数最大50行"
```

## 使用建议

### 项目初始化时

1. 在 `.knowledge/project/` 放入：
   - 项目简介 (README.md)
   - 业务规则文档
   - 产品需求文档

2. 在 `.knowledge/standards/` 放入：
   - 代码规范
   - Git 提交规范
   - 代码审查清单

3. 在 `.knowledge/tech/` 放入：
   - 技术栈说明
   - API 文档
   - 数据库设计

### 推荐文件格式

```markdown
# 标题

## 概述
简要说明

## 详细内容
...

## 注意事项
- 注意点1
- 注意点2
```

## 与工作流集成

```
/research → 自动读取 project/
/plan     → 自动读取 tech/
/impl     → 按需读取 standards/
/review   → 自动读取 standards/review-checklist.md
```

## 完成提示

```
✅ 知识加载完成

已加载: project/ (3 files, 2.5KB)
内容摘要:
- 项目名称: XXX
- 业务领域: XXX
- 关键术语: XXX

提示: 知识已加入上下文，可开始 /research
```
