---
name: review
description: 代码审查。完成后请 /clear
allowed-tools: Read, Bash, Glob, Grep
---

# 代码审查

## 前置条件

读取 `.fantayspec/plan.md` 确认实现范围。
若无参数，审查 `git diff HEAD`。

## 执行步骤

### 1. 加载审查规范

检查并读取 `.knowledge/standards/` 目录：
- `review-checklist.md` - 审查清单
- `coding-style.md` - 代码规范

### 2. 获取变更

```bash
git diff HEAD --stat
git diff HEAD
```

### 3. 执行审查

对照审查清单和代码规范检查：

**必检项**：
- [ ] 无硬编码密钥
- [ ] 有错误处理
- [ ] 有输入验证
- [ ] 无调试代码

**代码质量**：
- [ ] 函数长度合理
- [ ] 命名清晰
- [ ] 逻辑简洁

### 4. 生成报告

```markdown
# 审查报告

## 变更概览
- 文件数: X
- 新增: +X 行
- 删除: -X 行

## Critical (必须修复)
1. 问题描述
   - 位置: file:line
   - 建议: ...

## Major (建议修复)
...

## Minor (可选优化)
...

## 总评
- 质量: 优秀/良好/需改进
- 可合并: 是/否/需修复
```

### 5. 修复（如需）

若有 Critical 问题：
1. 列出问题
2. 确认修复
3. 执行修复
4. 重新审查

## 完成提示

```
✅ 审查完成

结果: 通过
- Critical: 0
- Major: X
- Minor: X

可以 /archive 归档了
```
