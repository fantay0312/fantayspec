---
name: learn
description: 经验管理 - 提取、查看、导入导出经验模式
allowed-tools: ["Read", "Write", "Glob"]
---

# /learn - 经验管理

## 用法

```bash
/learn                    # 从当前会话提取经验
/learn --status           # 查看已有经验
/learn --export           # 导出经验供分享
/learn --import <file>    # 导入外部经验
/learn --evolve           # 将相关经验聚类为技能
```

## 功能

### 1. 提取经验（默认）

从当前会话中识别可复用的模式：

```bash
/learn
/learn --type=debugging   # 仅调试类
/learn --dry-run          # 预览不保存
```

**流程**：
1. 扫描会话中的问题和解决方案
2. 筛选可复用的非平凡模式
3. 用户确认后保存

**存储位置**: `.ai_state/experience/learned/`

### 2. 查看经验

```bash
/learn --status                    # 全部
/learn --status --tags=react       # 按标签
/learn --status --min-confidence=0.8  # 高置信度
```

**输出示例**：
```
📊 经验状态

总计: 47 条 | 平均置信度: 0.78

高置信度 (>0.8):
✅ CORS handling in Next.js API routes
   置信度: 0.92 | 使用: 15 次 | 标签: [nextjs, api]

中置信度 (0.5-0.8):
⚡ Supabase RLS policies
   置信度: 0.72 | 使用: 5 次 | 标签: [supabase, security]
```

### 3. 导出经验

```bash
/learn --export                        # 导出全部
/learn --export --tags=react,nextjs    # 按标签
/learn --export --min-confidence=0.7   # 高置信度
```

**输出**: `.ai_state/experience/exports/export-{date}.json`

### 4. 导入经验

```bash
/learn --import team-patterns.json
/learn --import --preview <file>   # 预览
/learn --import --namespace=team <file>  # 带命名空间
```

**导入规则**：
- 新经验初始置信度 0.5
- 重复经验自动跳过
- 冲突经验需确认

### 5. 进化为技能

当相关经验积累足够时，聚类为可复用技能：

```bash
/learn --evolve                    # 交互式选择
/learn --evolve --tags=auth        # 指定标签聚类
/learn --evolve --preview          # 预览不创建
```

**聚类条件**：
- 同标签 ≥3 条经验
- 平均置信度 >0.7
- 未被进化过

**输出**: `.claude/skills/{skill-name}/SKILL.md`

## 经验格式

```markdown
# Pattern: [Name]
Created: [Date]
Type: [code|debugging|architecture|workflow]
Confidence: 0.85
Tags: [tag1, tag2]

## 触发条件
[何时使用]

## 问题
[解决的问题]

## 解决方案
[代码/方法]

## 注意事项
[陷阱、变体]
```

## 完成提示

```
✅ 经验提取完成

新增: 2 条
1. nextjs-hydration-fix.md (code)
2. prisma-singleton.md (debugging)

索引已更新: .ai_state/experience/index.md

提示: 使用 /learn --status 查看所有经验
```
