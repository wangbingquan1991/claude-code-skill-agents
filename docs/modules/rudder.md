# Rudder — Agent 团队编排平台

## 模块概述

Rudder 是 Agent 工作的操作层平台，位于 `team/rudder/` 目录。它将人类组织结构映射为 Agent 团队，提供从任务分配到协作执行的完整基础设施。

核心定位：**像管理一家公司一样管理 Agent 团队** — 每个 Agent 是一名员工，有角色、权限和汇报关系。

---

## 核心概念

### 人类公司 ↔ Rudder 映射

| 人类公司概念 | Rudder 对应 | 说明 |
|-------------|-------------|------|
| 员工 | Agent | 具备特定技能的执行单元 |
| 组织架构 | 报告结构 (Reporting) | Agent 间的层级与汇报关系 |
| 岗位职责 | Agent 能力定义 | 每个 Agent 的技能与工具集 |
| 部门 | Agent 组 (Group) | 按职能分组的 Agent 集合 |
| 工作流程 | 任务流 (Task Flow) | 结构化的执行流程 |
| 会议 | 聊天会话 (Chat) | Agent 间的交互通道 |
| 绩效考核 | 运行智能分析 | Agent 执行质量评估 |
| 公司制度 | 组织策略 (Policy) | 行为约束与安全规则 |

---

## 前端 Context 系统

Rudder 前端采用 React Context 架构，核心 Context 组件如下：

### ChatGenerationContext

聊天流式生成管理，处理 AI Agent 的实时响应流：

```typescript
interface ChatGenerationState {
  isGenerating: boolean;        // 当前是否正在生成
  currentMessageId: string;     // 当前消息 ID
  streamTokens: string[];       // 流式 token 缓冲
  abortController: AbortController; // 取消控制器
}

// 核心方法
startGeneration(chatId: string): void;
stopGeneration(): void;
appendToken(token: string): void;
finalizeMessage(): void;
```

### DialogContext

模态对话管理，统一控制所有弹窗与确认框：

| 对话类型 | 用途 | 触发场景 |
|---------|------|---------|
| `confirm` | 确认操作 | 删除 Agent、重置配置 |
| `prompt` | 输入收集 | 命名、描述编辑 |
| `alert` | 信息通知 | 操作成功/失败 |
| `custom` | 自定义内容 | 复杂表单、预览 |

### I18nContext

国际化支持，提供多语言切换能力：

```typescript
interface I18nContextValue {
  t: (key: string, params?: Record<string, string>) => string;
  locale: string;
  setLocale: (locale: string) => void;
  supportedLocales: string[];  // ['en', 'zh', 'ja', 'de', ...]
}
```

### PluginBridge

插件桥接系统，允许外部功能动态注入：

**全局注册机制：**

```typescript
// 插件注册
PluginBridge.register({
  name: "custom-tool",
  version: "1.0.0",
  hooks: { ... }
});
```

**5 个核心 Hook：**

| Hook | 触发时机 | 用途 |
|------|---------|------|
| `onAgentCreate` | Agent 创建后 | 注入默认配置、关联资源 |
| `onTaskStart` | 任务启动前 | 预处理、权限校验 |
| `onMessageReceive` | 收到消息时 | 消息过滤、格式转换 |
| `onToolCall` | 工具调用前 | 参数注入、审计日志 |
| `onError` | 错误发生时 | 自定义错误处理、告警 |

### 其他 Context

| Context | 职责 | 关键能力 |
|---------|------|---------|
| `LiveUpdatesContext` | 实时更新 | WebSocket 连接管理、事件分发 |
| `ThemeContext` | 主题管理 | 暗色/亮色切换、自定义主题 |
| `ToastContext` | 消息提示 | 成功/错误/警告通知、自动消失 |
| `AuthContext` | 认证状态 | 登录态管理、权限判断、token 刷新 |
| `NavigationContext` | 导航状态 | 侧边栏控制、面包屑、路由守卫 |
| `SelectionContext` | 多选管理 | 批量操作、全选/反选 |

---

## 服务层架构

前端 `services/` 目录包含 85+ 服务文件，按职能分类：

| 分类 | 服务数 | 核心服务 | 职责 |
|------|--------|---------|------|
| 认证 | 8 | AuthService, SessionService | 登录、注册、权限、SSO |
| Agent | 12 | AgentService, AgentConfigService | CRUD、配置、版本管理 |
| 任务 | 10 | TaskService, TaskQueueService | 创建、调度、监控、日志 |
| 聊天 | 15 | ChatService, StreamService | 会话管理、流式传输、历史 |
| 插件 | 8 | PluginService, PluginRegistry | 安装、卸载、配置、沙箱 |
| 工作流 | 10 | WorkflowService, StepService | 定义、执行、条件分支 |
| 数据 | 7 | DataService, CacheService | 数据获取、缓存、同步 |
| 通知 | 5 | NotificationService | 推送、邮件、站内信 |
| 分析 | 6 | AnalyticsService, MetricsService | 使用统计、性能指标 |
| 文件 | 4 | FileService, UploadService | 文件管理、上传下载 |

---

## 技术栈

### 后端

| 技术 | 用途 |
|------|------|
| TypeScript | 服务端语言 |
| Express | HTTP 框架 |
| Drizzle ORM | 数据库访问层 |
| PostgreSQL | 主数据库 |
| Redis | 缓存与消息队列 |
| WebSocket | 实时通信 |
| Zod | 运行时类型验证 |

### 前端

| 技术 | 用途 |
|------|------|
| React 19 | UI 框架 |
| shadcn/ui | 组件库 |
| Zustand | 状态管理 |
| TanStack Query | 服务端状态 |
| Tailwind CSS | 样式系统 |
| Vite | 构建工具 |

---

## 开发规范

### 组织隔离

每个组织（Organization）拥有独立的数据空间：
- Agent、任务、聊天记录完全隔离
- 跨组织数据不可见
- 组织内支持多团队与角色

### 契约同步

前后端 API 契约管理：

```
定义 Schema (Zod)
    │
    ├─→ 后端：路由校验 + 响应类型
    └─→ 前端：请求类型 + 自动补全
```

### 数据库变更流程

```bash
# 1. 创建迁移
pnpm drizzle:generate

# 2. 检查 SQL
pnpm drizzle:check

# 3. 应用迁移
pnpm drizzle:migrate

# 4. 更新类型
pnpm drizzle:push
```

### 验证清单

- [ ] API 变更同步更新前后端类型
- [ ] 数据库迁移文件已提交
- [ ] 新 Agent 功能有对应权限控制
- [ ] WebSocket 事件有重连兜底
- [ ] 敏感操作有审计日志

---

## 部署启动

### 开发环境

```bash
# 安装依赖
pnpm install

# 启动开发服务器（前后端热重载）
pnpm dev
```

### 访问地址

| 服务 | 地址 |
|------|------|
| 前端界面 | http://localhost:5173 |
| 后端 API | http://localhost:3000 |
| API 文档 | http://localhost:3000/docs |

### 重置实例

```bash
# 重置数据库（删除所有数据）
pnpm db:reset

# 重置 Agent 配置
pnpm agents:reset

# 完全重置（数据 + 配置 + 缓存）
pnpm reset:all
```

---

## 相关链接

- 源码目录：[`team/rudder/`](../../team/rudder/)
- 前端代码：[`team/rudder/ui/`](../../team/rudder/ui/)
- 后端代码：[`team/rudder/server/`](../../team/rudder/server/)
- 部署配置：[`team/rudder/docker/`](../../team/rudder/docker/)
- 技能定义：[`team/rudder/.agents/skills/`](../../team/rudder/.agents/skills/)
