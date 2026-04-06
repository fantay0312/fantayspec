---
name: FantaySpec Archive
description: 归档完成的任务，保留完整历史记录供未来参考
allowed-tools: Read, Write, Bash
---

# 任务归档

## 核心原则

- 保留**完整上下文**，供未来参考
- 自动生成**变更摘要**
- 清理工作状态，准备下一任务

## 前置条件

建议先执行 `/fantayspec:verify` 确保实现完整。

## 执行步骤

### 1. 收集状态文件

读取所有状态文件：
- `.fantayspec/context.md`
- `.fantayspec/constraints.md`
- `.fantayspec/plan.md`
- `.fantayspec/progress.md`
- `.fantayspec/explore.md` (如有)
- `.fantayspec/verify.md` (如有)

### 2. 生成变更摘要

```bash
# 获取 Git 变更统计
git diff HEAD --stat
git log --oneline -5
```

### 3. 创建归档目录

```bash
# 格式: YYYYMMDD-HHMM-<简短描述>
mkdir -p .fantayspec/archive/$(date +%Y%m%d-%H%M)-feature-name
```

### 4. 生成归档元数据

创建 `ARCHIVE.md`:

```markdown
# 归档记录

## 基本信息

| 字段 | 值 |
|------|-----|
| 归档时间 | YYYY-MM-DD HH:MM |
| 任务描述 | [从 context.md 提取] |
| 状态 | ✓ 完成 / ⚠️ 部分完成 |

## 变更摘要

### Delta Specs (变更追踪)

#### ADDED (新增)
- 文件/功能1: 描述
- 文件/功能2: 描述

#### MODIFIED (修改)
- 文件/功能1: 修改描述
- 文件/功能2: 修改描述

#### REMOVED (删除)
- 文件/功能1: 删除原因

### Git 统计
- 提交数: X
- 文件变更: X
- 新增行: +X
- 删除行: -X

## 约束满足情况

| 约束 | 状态 |
|------|------|
| 硬约束1 | ✓ |
| 硬约束2 | ✓ |

## 关键决策记录

1. 决策1: 选择 A 而非 B
   - 原因: ...

2. 决策2: ...

## 未来注意事项

- 注意点1: 描述
- 注意点2: 描述

## 相关文件

- [context.md](./context.md)
- [constraints.md](./constraints.md)
- [plan.md](./plan.md)
- [progress.md](./progress.md)
```

### 5. 移动状态文件

```bash
archive_dir=".fantayspec/archive/$(date +%Y%m%d-%H%M)-feature"

# 移动状态文件到归档目录
mv .fantayspec/context.md "$archive_dir/"
mv .fantayspec/constraints.md "$archive_dir/"
mv .fantayspec/plan.md "$archive_dir/"
mv .fantayspec/progress.md "$archive_dir/"

# 可选文件
[ -f .fantayspec/explore.md ] && mv .fantayspec/explore.md "$archive_dir/"
[ -f .fantayspec/verify.md ] && mv .fantayspec/verify.md "$archive_dir/"
```

### 6. 更新归档索引

更新 `.fantayspec/archive/INDEX.md`:

```markdown
# 归档索引

| 日期 | 任务 | 状态 | 目录 |
|------|------|------|------|
| YYYY-MM-DD | 任务描述 | ✓ | `./YYYYMMDD-HHMM-feature/` |
| ... | ... | ... | ... |
```

### 7. 清理工作目录

确保 `.fantayspec/` 只保留：
- `config.md` (配置文件)
- `archive/` (归档目录)

## 完成提示

```
✅ 归档完成

归档位置: .fantayspec/archive/YYYYMMDD-HHMM-feature/
包含文件:
  - ARCHIVE.md (归档元数据)
  - context.md
  - constraints.md
  - plan.md
  - progress.md

工作目录已清理，可以开始新任务。

下一步:
1. 使用 /fantayspec:init 开始新任务
   或 /fantayspec:research <新需求>
```

## 查看历史归档

```bash
# 列出所有归档
ls -la .fantayspec/archive/

# 查看归档索引
cat .fantayspec/archive/INDEX.md

# 查看特定归档
cat .fantayspec/archive/YYYYMMDD-HHMM-feature/ARCHIVE.md
```
