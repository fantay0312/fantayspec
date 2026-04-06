# Performance Rules

## 通用原则

1. **先测量** - 优化前先性能分析
2. **避免过早优化** - 仅在需要时优化
3. **了解数据** - 理解访问模式
4. **智慧缓存** - 缓存昂贵计算

## 模型选择策略

选择正确的模型可以显著降低成本并提高效率。

### 模型矩阵

| 模型 | 特点 | 成本 | 适用场景 |
|:---|:---|:---|:---|
| **Haiku 4.5** | 90% Sonnet 能力，极快 | ~$0.8/MTok | 轻量任务 |
| **Sonnet 4.5** | 最佳编码平衡 | ~$3/MTok | 日常开发 |
| **Opus 4.5** | 最深推理能力 | ~$15/MTok | 复杂决策 |

### 详细路由规则

#### Haiku 4.5 (首选轻量任务)
- ✅ 轻量代理频繁调用
- ✅ 后台分析任务 (观察学习)
- ✅ 简单代码生成
- ✅ 文件搜索和导航
- ✅ 格式化和重命名
- ❌ 复杂架构决策
- ❌ 跨文件重构

#### Sonnet 4.5 (默认开发)
- ✅ 主要开发工作
- ✅ 多代理工作流编排
- ✅ 代码审查
- ✅ 调试复杂问题
- ❌ 简单搜索任务
- ❌ 需要最深推理的任务

#### Opus 4.5 (仅必要时)
- ✅ 复杂架构决策
- ✅ 最高推理要求
- ✅ 安全漏洞深度分析
- ❌ 日常编码任务
- ❌ 简单修复

### 代理模型分配

```yaml
# 轻量代理 (Haiku)
build-error-resolver: haiku
e2e-runner: haiku

# 标准代理 (Sonnet)
code-reviewer: sonnet
tdd-guide: sonnet
impl-executor: sonnet

# 重度代理 (Opus)
planner: opus
init-architect: opus
security-reviewer: opus  # 深度分析时
```

## 上下文窗口管理

### 上下文使用区间

```
0%─────────50%─────────80%─────────100%
│   安全区   │   谨慎区   │   危险区   │
│  正常工作  │  考虑压缩  │  必须压缩  │
```

### 避免在上下文后 20% 进行
- 大规模重构
- 跨多文件功能实现
- 复杂交互调试
- 架构设计讨论

### 上下文后 20% 可进行
- 单文件编辑
- 独立工具函数
- 文档更新
- 简单 bug 修复

### 压缩时机
- 完成一个功能阶段后
- 上下文超过 80%
- 切换到不相关任务
- 开始新功能开发

## 前端性能

### Critical Metrics
| 指标 | 目标 | 说明 |
|:---|:---|:---|
| LCP | < 2.5s | Largest Contentful Paint |
| FID | < 100ms | First Input Delay |
| CLS | < 0.1 | Cumulative Layout Shift |

### Best Practices
- Code splitting and lazy loading
- Optimize images (WebP, lazy load)
- Minimize bundle size
- Use production builds
- Enable compression (gzip/brotli)

### React Specific
```typescript
// React.memo 优化昂贵渲染
const ExpensiveComponent = React.memo(({ data }) => { ... });

// 适当使用 useMemo/useCallback
const memoizedValue = useMemo(() => compute(a, b), [a, b]);

// 长列表虚拟化
import { FixedSizeList } from 'react-window';
```

## 后端性能

### Database
- Index frequently queried columns
- Avoid N+1 queries
- Use pagination for large datasets
- Cache query results when appropriate

```typescript
// BAD: N+1 查询
for (const user of users) {
  const posts = await db.posts.find({ userId: user.id });
}

// GOOD: 批量查询
const posts = await db.posts.find({ userId: { $in: userIds } });
```

### API
- Implement response caching
- Use compression
- Paginate responses
- Consider GraphQL for complex queries

## 构建故障排除

1. **使用 build-error-resolver 代理**
2. **分析错误消息** - 识别类型、定位源文件
3. **增量修复** - 一次修复一个错误
4. **验证循环** - 每次修复后验证

```bash
npm run build
npx tsc --noEmit
npm test
```

## 监控命令

```bash
# Bundle analysis
npm run build -- --analyze

# Lighthouse audit
npx lighthouse <url> --output html

# Database query analysis
EXPLAIN ANALYZE <query>

# Memory profiling
node --inspect app.js
```

## 性能红旗

检测到以下模式时需要优化：

- [ ] 嵌套循环内的数据库查询
- [ ] 将整个数据集加载到内存
- [ ] 同步执行重型计算
- [ ] 频繁查询列缺少索引
- [ ] 无边界的查询 (无 limit)
- [ ] 主线程阻塞操作
- [ ] 未压缩的大型资源
- [ ] 重复渲染相同组件
