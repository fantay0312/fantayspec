---
name: FantaySpec Implementation
description: 按计划执行代码实现。上下文接近 80K 时请 /clear 后继续
allowed-tools: Read, Write, Edit, Bash, Skill
---

# 代码实现

## 前置条件

读取 `.fantayspec/plan.md` 和 `.fantayspec/progress.md`。
若不存在，提示用户先执行 `/fantayspec:plan`。

## 核心原则

- 严格按计划执行，**禁止**添加计划外功能
- 外部模型输出仅作参考，**必须重构**后使用
- 代码精简高效，非必要不加注释
- 上下文接近 80K 时立即 `/clear`，从断点继续

## 执行步骤

### 1. 加载状态

```bash
Read .fantayspec/plan.md      # 执行计划
Read .fantayspec/progress.md  # 当前进度
```

识别下一个待执行任务。

### 2. 获取代码原型

根据任务类型选择 Skill：

**前端/UI 任务** → `/collaborating-with-gemini`:
```
Skill: collaborating-with-gemini
Args: |
  任务: [任务描述]
  约束: [相关约束]
  现有代码: [相关代码片段]

  要求: 返回 Unified Diff Patch，禁止直接修改文件
```

**后端/逻辑任务** → `/collaborating-with-codex`:
```
Skill: collaborating-with-codex
Args: |
  任务: [任务描述]
  约束: [相关约束]
  现有代码: [相关代码片段]

  要求: 返回 Unified Diff Patch，禁止直接修改文件
```

### 3. 重构并应用

**禁止直接应用原型！** 必须：
1. 审查原型逻辑正确性
2. 去除冗余代码和注释
3. 统一命名风格
4. 检查副作用
5. 使用 Edit 工具应用修改

### 4. 验证

按计划中的验证方法验证：
- 语法检查
- 类型检查
- 单元测试（如有）

### 5. 更新进度

更新 `.fantayspec/progress.md`:
```markdown
- [x] Task N: 已完成
- [ ] Task N+1: 进行中
```

### 6. 上下文检查

若上下文接近 80K：
```
⚠️ 上下文较大，建议 /clear

当前进度已保存，/clear 后执行:
/fantayspec:impl
将从 Task N+1 继续
```

## 循环执行

重复步骤 1-6，直到所有任务完成。

## 完成提示

```
✅ 所有任务实现完成

完成任务: X/X
修改文件: [文件列表]

下一步:
1. 输入 /clear 清空上下文
2. 使用 /fantayspec:review 进行代码审查
```

**重要**: 上下文大时随时 `/clear`，进度不会丢失
