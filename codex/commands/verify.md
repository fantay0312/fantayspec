---
name: FantaySpec Verify
description: 验证实现完整性、正确性和一致性。归档前必须执行
allowed-tools: Read, Bash, Glob, Grep, Skill
---

# 实现验证

## 核心原则

验证三要素：
- **完整性** (Completeness): 所有计划任务已实现
- **正确性** (Correctness): 代码逻辑正确，通过测试
- **一致性** (Coherence): 代码风格统一，与约束集一致

## 前置条件

读取状态文件：
- `.fantayspec/plan.md` - 执行计划
- `.fantayspec/constraints.md` - 约束集
- `.fantayspec/progress.md` - 进度跟踪

## 执行步骤

### 1. 完整性检查

对照计划检查所有任务：

```markdown
## 完整性检查

### 计划任务 vs 实际完成

| 任务 | 计划状态 | 实际状态 | 差异 |
|------|----------|----------|------|
| Task 1 | ✓ | ✓ | - |
| Task 2 | ✓ | ✗ | 未实现 |

### 未完成项
- [ ] Task 2: 原因/阻塞点
```

### 2. 约束一致性检查

逐项验证约束集：

```markdown
## 约束验证

### 硬约束

| 约束 | 验证方法 | 结果 |
|------|----------|------|
| 约束1 | 代码检查 | ✓ 符合 |
| 约束2 | 单元测试 | ✗ 违反 |

### 软约束

| 约束 | 验证方法 | 结果 |
|------|----------|------|
| 约束1 | 代码审查 | ✓ 符合 |
```

### 3. 自动化测试

运行项目测试（如有）：

```bash
# 检测并运行测试
pnpm test 2>/dev/null || npm test 2>/dev/null || yarn test 2>/dev/null || echo "No test runner found"
```

### 4. 多模型交叉验证

**Codex (逻辑验证)** - 使用 `/collaborating-with-codex`:
```
Skill: collaborating-with-codex
Args: |
  验证以下实现是否满足约束:

  约束集:
  [constraints.md 内容]

  变更代码:
  [git diff 内容]

  检查项:
  1. 所有硬约束是否满足
  2. 边界条件是否处理
  3. 错误处理是否完整
  4. 是否有遗漏的实现

  输出: JSON { passed: bool, violations: [], warnings: [] }
```

**Gemini (一致性验证)** - 使用 `/collaborating-with-gemini`:
```
Skill: collaborating-with-gemini
Args: |
  验证以下实现是否满足约束:

  约束集:
  [constraints.md 内容]

  变更代码:
  [git diff 内容]

  检查项:
  1. UI 约束是否满足
  2. 代码风格是否统一
  3. 命名是否一致
  4. 是否有冗余代码

  输出: JSON { passed: bool, violations: [], warnings: [] }
```

### 5. 生成验证报告

```markdown
## 验证报告

### 总体状态: ✓ 通过 / ✗ 未通过

### 完整性
- 计划任务: X/X 完成
- 未完成: [列表或"无"]

### 正确性
- 测试结果: 通过/失败/无测试
- 逻辑检查: 通过/有问题

### 一致性
- 约束符合: X/X
- 违反项: [列表或"无"]
- 警告项: [列表或"无"]

### 阻塞问题 (必须修复)
1. 问题1: 描述
   - 影响: ...
   - 修复建议: ...

### 建议改进 (可选)
1. 建议1: 描述
```

### 6. 结果处理

**若验证通过**:
```
✅ 验证通过

所有检查项已通过:
- 完整性: ✓
- 正确性: ✓
- 一致性: ✓

下一步:
1. 输入 /clear 清空上下文
2. 使用 /fantayspec:review 进行最终代码审查
   或 /fantayspec:archive 直接归档
```

**若验证未通过**:
```
⚠️ 验证未通过

阻塞问题:
1. [问题描述]
2. [问题描述]

需要修复后重新验证。

下一步:
1. 修复上述问题
2. 重新执行 /fantayspec:verify
```

## 保存状态

写入 `.fantayspec/verify.md` 保存验证报告。

**重要**: 验证通过后才能进行 review 或 archive
