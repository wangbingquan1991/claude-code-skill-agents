# ValueCell — 多智能体金融平台

## 模块概述

ValueCell 是一个社区驱动的多智能体金融应用平台，位于 `project/valuecell/` 目录。通过编排多个专业化 AI Agent 协作完成金融研究、策略分析和新闻检索等复杂任务。

核心定位：**将 AI Agent 能力与金融数据源深度整合**，为用户提供从数据采集到投资洞察的一站式平台。

---

## 核心架构

```
┌──────────────────────────────────────────────────┐
│                  用户界面 (React)                  │
└──────────────────┬───────────────────────────────┘
                   │ HTTP/WebSocket
┌──────────────────▼───────────────────────────────┐
│              Orchestrator (编排器)                 │
│    请求路由 → Agent 选择 → 任务分解 → 结果聚合    │
├──────────────────────────────────────────────────┤
│              SuperAgent (超级代理)                 │
│    多 Agent 协调 │ 上下文管理 │ 冲突仲裁          │
├──────────────────────────────────────────────────┤
│              PlanService (规划服务)                │
│    任务分解 │ 依赖分析 │ 执行计划生成              │
├──────────────────────────────────────────────────┤
│              TaskExecutor (任务执行器)             │
│    并发调度 │ 重试策略 │ 超时管理                  │
├──────────────────────────────────────────────────┤
│              A2A (Agent-to-Agent)                 │
│    Agent 间通信 │ 数据传递 │ 状态同步              │
└──────────────────────────────────────────────────┘
```

---

## 核心 Agent

| Agent | 职责 | 能力 |
|-------|------|------|
| **DeepResearch** | 深度研究分析 | 多源数据交叉验证、长文报告生成、趋势推理 |
| **Strategy** | 投资策略生成 | 量化指标计算、风险评估、组合优化建议 |
| **News Retrieval** | 新闻检索与摘要 | 实时新闻抓取、情感分析、事件影响评估 |

### Agent 协作模式

```
用户提问: "分析特斯拉Q3财报对股价影响"
    │
    ├─→ News Retrieval: 获取Q3财报相关新闻
    ├─→ DeepResearch: 分析财务数据与行业对比
    └─→ Strategy: 生成投资建议与风险提示
    │
    ▼
Orchestrator: 聚合三个 Agent 结果，生成综合报告
```

---

## 技术栈

### 后端

| 技术 | 版本 | 用途 |
|------|------|------|
| Python | 3.12+ | 运行时环境 |
| FastAPI | latest | Web 框架与 API 服务 |
| Agno | latest | Agent 编排框架 |
| Pydantic | v2 | 数据验证与序列化 |
| asyncio | 内置 | 异步并发执行 |

### 前端

| 技术 | 版本 | 用途 |
|------|------|------|
| React | 19 | UI 框架 |
| Vite | 7 | 构建工具与开发服务器 |
| Tauri | 2.9 | 桌面应用封装 |
| TypeScript | 5.x | 类型安全 |
| TailwindCSS | 4 | 样式系统 |

---

## 前端结构

```
frontend/
├── src/
│   ├── api/            # API 请求封装
│   ├── app/            # 应用入口与路由
│   ├── components/     # UI 组件库
│   │   ├── chat/       # 聊天界面组件
│   │   ├── research/   # 研究报告展示
│   │   └── common/     # 通用组件
│   ├── hooks/          # 自定义 React Hooks
│   ├── i18n/           # 国际化资源
│   │   ├── en/         # 英文
│   │   ├── ja/         # 日文
│   │   ├── zh/         # 简体中文
│   │   └── zh_Hant/    # 繁体中文
│   ├── store/          # 状态管理 (Zustand)
│   ├── types/          # TypeScript 类型定义
│   └── utils/          # 工具函数
├── public/             # 静态资源
├── index.html          # 入口 HTML
├── vite.config.ts      # Vite 配置
└── package.json        # 依赖管理
```

---

## 数据源

ValueCell 集成 15+ 金融数据源，覆盖全球主要市场：

| 数据源 | 覆盖范围 | 数据类型 |
|--------|---------|---------|
| yfinance | 全球股票、ETF | 行情、财务、期权 |
| akshare | A 股、港股 | 行情、基本面、宏观 |
| ccxt | 加密货币交易所 | 行情、订单簿、交易 |
| eodhd | 全球 60+ 交易所 | 历史行情、基本面 |
| SEC EDGAR | 美股上市公司 | 财务报表、公告 |
| FRED | 美国联邦储备 | 宏观经济指标 |
| Alpha Vantage | 全球市场 | 技术指标、外汇 |
| Finnhub | 全球市场 | 实时行情、新闻 |
| Polygon.io | 美股 | Tick 级行情数据 |
| OpenBB | 综合金融 | 研究终端接口 |
| Tushare | A 股 | 行情、财务、资金 |
| 新浪财经 | 中国市场 | 实时行情、新闻 |
| 东方财富 | 中国市场 | 行情、资金流向 |
| CoinGecko | 加密货币 | 行情、市值、趋势 |
| World Bank | 全球 | 宏观经济、发展指标 |

---

## 部署启动

### 快速启动

```bash
# 一键启动（前后端）
./start.sh

# Windows 用户
./start.ps1
```

### 环境变量配置

参考 `.env.example` 创建 `.env` 文件：

```bash
# AI 模型配置
OPENAI_API_KEY=sk-xxx
ANTHROPIC_API_KEY=xxx

# 数据源 API Keys
ALPHA_VANTAGE_KEY=xxx
FINNHUB_KEY=xxx
POLYGON_KEY=xxx

# 服务配置
BACKEND_PORT=8000
FRONTEND_PORT=5173
```

### 数据目录

```
~/.valuecell/
├── cache/          # 数据缓存
├── reports/        # 生成的研究报告
├── logs/           # 运行日志
└── config.json     # 用户配置
```

---

## 开发指引

| 命令 | 用途 |
|------|------|
| `make dev` | 启动开发环境（前后端热重载） |
| `make test` | 运行测试套件 |
| `make lint` | 代码规范检查 |
| `make build` | 生产环境构建 |

---

## 相关链接

- 源码目录：[`project/valuecell/`](../../project/valuecell/)
- 前端代码：[`project/valuecell/frontend/`](../../project/valuecell/frontend/)
- 后端代码：[`project/valuecell/python/`](../../project/valuecell/python/)
- Agent 定义：[`project/valuecell/AGENTS.md`](../../project/valuecell/AGENTS.md)
