# 项目架构设计

> Claude Code Skill Agents 的整体架构、设计原则与技术决策

---

## 架构概述

项目整体采用 **"核心 + 扩展 + 应用"** 三层架构，实现从基础能力到领域应用的渐进式构建：

### 核心层 (Core)

自有开发的核心组件，提供项目的基础 AI 能力：

- **Agent**: `claudecode-expert` — Claude Code 终极专家，支持代码审查、优化、调试、架构建议
- **Skill**: `claudecode-assistant-perspective` — 综合指导 Skill，包含 7 大心智模型、反模式库、工作流模板

### 扩展层 (Extensions)

通过 Git Submodule 集成的外部优秀项目，扩展项目的能力边界：

- **Skills 扩展**: Karpathy 编程准则、Claude-Mem 记忆管理、Matt Pocock Skills
- **工具扩展**: Scrapling 爬虫框架、Rudder 团队协作

### 应用层 (Applications)

按场景分类的领域应用，展示核心能力在实际业务中的落地：

- **金融**: ValueCell AI 金融平台、FinceptTerminal、TrendRadar
- **数据采集**: Scrapling 高性能爬虫
- **团队协作**: Rudder 多 Agent 调度
- **设计**: awesome-design-md 设计文档集合

---

## 架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          应用层 (Applications)                           │
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │  ValueCell   │  │  TrendRadar  │  │   Fincept    │  │  awesome-  │ │
│  │  金融分析    │  │  趋势预警    │  │   Terminal   │  │  design-md │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └─────┬──────┘ │
└─────────┼──────────────────┼──────────────────┼───────────────┼────────┘
          │                  │                  │               │
┌─────────┼──────────────────┼──────────────────┼───────────────┼────────┐
│         ▼                  ▼                  ▼               ▼        │
│                          扩展层 (Extensions)                            │
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │  Karpathy    │  │  Claude-Mem  │  │  Scrapling   │  │   Rudder   │ │
│  │  Skills      │  │  记忆管理    │  │  爬虫框架    │  │  团队协作  │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └─────┬──────┘ │
└─────────┼──────────────────┼──────────────────┼───────────────┼────────┘
          │                  │                  │               │
┌─────────┼──────────────────┼──────────────────┼───────────────┼────────┐
│         ▼                  ▼                  ▼               ▼        │
│                           核心层 (Core)                                  │
│                                                                         │
│  ┌─────────────────────────────┐  ┌─────────────────────────────────┐  │
│  │     claudecode-expert       │  │  claudecode-assistant-perspective│  │
│  │     (终极专家 Agent)         │  │  (综合指导 Skill)                │  │
│  │                             │  │                                  │  │
│  │  • 代码审查 & 优化          │  │  • 7 大心智模型                  │  │
│  │  • 调试策略                 │  │  • 反模式库                      │  │
│  │  • 架构建议                 │  │  • 工作流模板                    │  │
│  │  • 性能调优                 │  │  • 最佳实践指南                  │  │
│  └─────────────────────────────┘  └─────────────────────────────────┘  │
│                                                                         │
│                    ┌─────────────────────────┐                          │
│                    │   AI 协议层 (MCP)        │                          │
│                    │   Model Context Protocol │                          │
│                    └─────────────────────────┘                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 数据流向

```
用户请求 → Claude Code → Agent 路由 → 专业 Agent 处理
                ↓                            ↓
           Skill 加载 ←── 心智模型过滤 ←── 决策引擎
                ↓
        外部工具调用 (Scrapling / ValueCell / Rudder)
                ↓
           结果聚合 → 质量检查点 → 输出交付
```

---

## Git Submodule 架构

### 为什么使用 Submodule？

| 优势 | 说明 |
|------|------|
| **版本控制** | 每个子模块锁定特定 commit，确保稳定性 |
| **独立更新** | 各模块可独立拉取上游更新，不影响其他模块 |
| **代码隔离** | 避免代码混杂，保持项目边界清晰 |
| **社区协作** | 方便追踪上游项目，贡献回馈社区 |
| **按需加载** | 用户可选择性初始化需要的子模块 |

### 子模块清单

| 路径 | 源仓库 | 维护者 | 分类 |
|------|--------|--------|------|
| `skills/andrej-karpathy-skills` | [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | multica-ai | Skills 扩展 |
| `skills/claude-mem` | [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) | thedotmack | Skills 扩展 |
| `skills/skills` | [mattpocock/skills](https://github.com/mattpocock/skills) | Matt Pocock | Skills 扩展 |
| `team/rudder` | [Undertone0809/rudder](https://github.com/Undertone0809/rudder) | Undertone0809 | 团队协作 |
| `crawl/Scrapling` | [D4Vinci/Scrapling](https://github.com/D4Vinci/Scrapling) | D4Vinci | 数据采集 |
| `project/valuecell` | [ValueCell-ai/valuecell](https://github.com/ValueCell-ai/valuecell) | ValueCell-ai | 金融应用 |
| `project/TrendRadar` | [sansan0/TrendRadar](https://github.com/sansan0/TrendRadar) | sansan0 | 金融应用 |
| `project/awesome-design-md` | [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) | VoltAgent | 设计资源 |

---

## 设计原则

项目遵循 7 个核心设计原则，贯穿于 Agent 和 Skill 的每一个决策中：

### 1. 渐进式披露 (Progressive Disclosure)

> 信息按需分层展示，避免认知过载

- 文档分层：概述 → 详细 → 参考
- Agent 回复：结论先行 → 详细解释 → 代码示例
- 错误处理：用户友好提示 → 技术细节 → 调试信息

### 2. Agent-First

> 专业任务委托给专门的 Agent 处理

- 代码相关决策 → `claudecode-expert`
- 记忆管理 → `claude-mem`
- 团队调度 → `rudder`
- 每个 Agent 有明确的职责边界和能力声明

### 3. 最小授权 (Least Privilege)

> 每个组件只获取完成任务所需的最小权限

- Agent 工具声明：仅声明必要的工具（Read、Grep、Glob、Bash）
- Skill 范围限定：每个 Skill 只覆盖特定领域
- 文件访问：只读取任务相关的文件和目录

### 4. 检查点驱动 (Checkpoint-Driven)

> 关键节点设置质量门限，确保输出质量

- Skill 质量检查点：结构完整性 → 内容准确性 → 可用性验证
- Agent 决策检查点：7 层心智模型全量扫描
- 代码变更检查点：编译通过 → 测试通过 → 风格检查

### 5. 复利模式 (Compound Interest)

> 每次投入都应产生可复用的长期价值

- Skill 定义可跨项目复用
- Agent 经验沉淀为文档和最佳实践
- 工作流模板可快速适配新场景
- 反模式库持续积累，避免重复犯错

### 6. 上下文经济学 (Context Economics)

> 精打细算每一个 Token，最大化信息密度

- Agent 回复简洁精确，避免冗余
- Skill 文档结构化，便于快速定位
- 分层引用：优先使用摘要，按需展开细节
- 避免在上下文窗口中重复相同信息

### 7. 测试驱动 (Test-Driven)

> 先定义预期结果，再实现功能

- Agent 输出有明确的质量标准
- Skill 提供验证清单
- 代码变更必须伴随测试
- 文档包含可验证的示例

---

## 模块间交互关系

### Skills 层级关系

```
底层基础                     中层能力                    横向扩展
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐
│  Karpathy       │    │  Claude-Mem     │    │  claudecode-assistant-  │
│  Skills         │───▶│  记忆管理       │───▶│  perspective            │
│                 │    │                 │    │  (综合指导)              │
│  • 编程准则     │    │  • 长期记忆     │    │  • 7 大心智模型         │
│  • 代码风格     │    │  • 上下文持久化 │    │  • 工作流模板           │
│  • 工程实践     │    │  • 知识图谱     │    │  • 反模式库             │
└─────────────────┘    └─────────────────┘    └────────────┬────────────┘
                                                           │
                                              ┌────────────▼────────────┐
                                              │  专向应用                │
                                              │  synology-spk-          │
                                              │  assistant-team         │
                                              │  (SPK 团队协作 Skill)    │
                                              └─────────────────────────┘
```

- **底层 (Karpathy Skills)**: 提供通用编程准则和工程实践基础
- **中层 (Claude-Mem)**: 在底层基础上增加记忆管理和上下文持久化能力
- **横向 (Perspective)**: 综合所有能力，提供全方位指导框架
- **专向 (SPK Team)**: 针对特定场景的垂直应用

### 外部集成的功能互补

```
┌─────────────────────────────────────────────────────────────┐
│                    统一 AI 协议层 (MCP)                       │
├──────────────────┬──────────────────┬───────────────────────┤
│                  │                  │                       │
│  Scrapling       │  ValueCell       │  Rudder              │
│  数据采集        │  金融分析        │  团队管理             │
│                  │                  │                       │
│  • Web 爬虫      │  • 数据可视化    │  • Agent 调度         │
│  • 反检测        │  • AI 分析引擎   │  • 任务分配           │
│  • Spider 框架   │  • 实时行情      │  • 协同工作流         │
│  • 数据提取      │  • 投资决策      │  • 运行智能           │
│                  │                  │                       │
└──────────┬───────┴──────────┬───────┴───────────┬───────────┘
           │                  │                   │
           ▼                  ▼                   ▼
    ┌──────────────────────────────────────────────────────┐
    │              数据流水线 (Data Pipeline)                │
    │                                                      │
    │  采集 (Scrapling) → 分析 (ValueCell) → 协作 (Rudder) │
    └──────────────────────────────────────────────────────┘
```

三个外部集成项目形成完整的数据处理链：
- **Scrapling** 负责从 Web 获取原始数据
- **ValueCell** 对数据进行金融分析和可视化
- **Rudder** 协调多个 Agent 完成复杂协作任务

### 统一的 AI 协议层 (MCP)

所有模块通过 **Model Context Protocol (MCP)** 实现标准化通信：

- **工具注册**: 每个模块将自身能力注册为 MCP 工具
- **上下文共享**: 通过 MCP 协议在 Agent 间传递上下文信息
- **能力发现**: Agent 可动态发现并调用其他模块提供的服务
- **安全隔离**: MCP 提供标准化的权限控制和访问边界

---

## 技术栈全景

综合所有模块使用的技术栈：

| 层次 | 技术 | 使用模块 |
|------|------|----------|
| **前端** | React 19 + React Router 7 | ValueCell, Rudder |
| **前端构建** | Vite 7 | ValueCell, Rudder |
| **前端样式** | Tailwind CSS 4 | ValueCell, Rudder |
| **桌面应用** | Tauri 2 | Rudder, FinceptTerminal |
| **后端 Python** | FastAPI | ValueCell, TrendRadar |
| **AI 框架** | Agno + A2A SDK | ValueCell |
| **后端 Node** | Express 5 | Rudder |
| **ORM** | Drizzle ORM | Rudder |
| **数据库** | SQLite / PostgreSQL | Rudder, ValueCell |
| **向量数据库** | LanceDB / Chroma | ValueCell, Claude-Mem |
| **AI 协议** | MCP (Model Context Protocol) | TrendRadar, Rudder |
| **爬虫框架** | Scrapling (Python) | Scrapling |
| **包管理 JS** | pnpm / Bun | Rudder |
| **包管理 Python** | uv / pip | ValueCell, TrendRadar, Scrapling |
| **测试** | Vitest / pytest | Rudder, Scrapling |
| **CI/CD** | GitHub Actions | 全部模块 |
| **容器** | Docker / Docker Compose | Rudder, ValueCell, Scrapling |

---

## 质量保障体系

### Skill 通过标准（≥ 80 分）

| 维度 | 权重 | 检查项 |
|------|------|--------|
| 结构完整性 | 25% | SKILL.md 包含完整的元数据、触发条件、能力声明 |
| 内容准确性 | 25% | 技术描述准确、代码示例可运行、无过时信息 |
| 可用性 | 20% | 文档清晰、示例丰富、错误处理完善 |
| 可复用性 | 15% | 模块化设计、接口清晰、依赖最小化 |
| 维护性 | 15% | 版本标注、变更日志、升级路径 |

### Agent 通过标准（≥ 85 分）

| 维度 | 权重 | 检查项 |
|------|------|--------|
| 职责清晰度 | 20% | 边界明确、不越权、触发条件精准 |
| 决策质量 | 25% | 心智模型正确应用、决策可解释 |
| 输出质量 | 25% | 准确、简洁、可操作、格式规范 |
| 安全合规 | 15% | 遵守安全基线、权限最小化、无信息泄露 |
| 协作能力 | 15% | 正确委托、上下文传递完整、结果可追溯 |

### 三层决策过滤机制

```
┌─────────────────────────────────────────────────────┐
│          第一层：心智模型过滤（7 层全量扫描）          │
│                                                     │
│  渐进式披露 → Agent-First → 最小授权 → 检查点驱动   │
│  → 复利模式 → 上下文经济学 → 测试驱动               │
│                                                     │
│  ✓ 通过 → 进入第二层                                │
│  ✗ 不通过 → 重新评估决策                            │
└─────────────────────────┬───────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│          第二层：场景适配过滤                          │
│                                                     │
│  • 当前任务类型识别                                  │
│  • 用户偏好匹配                                     │
│  • 上下文约束检查                                   │
│  • 工具可用性验证                                   │
│                                                     │
│  ✓ 通过 → 进入第三层                                │
│  ✗ 不通过 → 降级或委托其他 Agent                    │
└─────────────────────────┬───────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│          第三层：质量门限检查                          │
│                                                     │
│  • 输出完整性验证                                   │
│  • 安全合规检查                                     │
│  • 性能指标达标                                     │
│  • 用户满意度预估                                   │
│                                                     │
│  ✓ 通过 → 输出交付                                  │
│  ✗ 不通过 → 迭代优化直到达标                        │
└─────────────────────────────────────────────────────┘
```

每个 Agent 的每次决策都必须经过这三层过滤：
1. **心智模型层**: 确保决策符合 7 大核心原则
2. **场景适配层**: 确保决策适合当前具体场景
3. **质量门限层**: 确保输出达到最低质量标准

---

## 演进路线

项目架构支持以下演进方向：

- **横向扩展**: 添加新的 Submodule 集成更多领域能力
- **纵向深化**: 强化核心 Agent 和 Skill 的智能水平
- **协议升级**: 随 MCP 协议演进，增强 Agent 间通信能力
- **生态建设**: 建立 Skill/Agent 市场，促进社区贡献

---

<div align="center">

*本文档随项目演进持续更新，最后更新：2025 年*

</div>
