# Claude Code Skill Agents 项目文档

> 为 Claude Code 打造的模块化、可扩展的 AI Agent 和可复用 Skill 集合

---

## 项目简介

**Claude Code Skill Agents** 是一个专为 Anthropic Claude Code 构建的模块化、可扩展的 AI Agent 与可复用 Skill 集合。项目旨在通过提供专业化的 Agent（如代码审查、调试、架构建议）和结构化的 Skill（如开发原则、工作流模板、最佳实践指南），显著增强开发者在 Claude Code 中的编码体验。项目采用 MIT 开源许可证，允许自由使用、修改和商业化。

---

## 文档目录

| 文档 | 说明 |
|------|------|
| [项目架构](./architecture.md) | 整体架构设计、设计原则与技术栈全景 |
| [快速入门](./getting-started.md) | 安装配置与基本使用指南 |
| [贡献指南](./contributing.md) | 如何为项目做出贡献 |

### 模块说明

| 模块文档 | 说明 |
|----------|------|
| [Agents 模块](./modules/agents.md) | AI Agent 定义与使用方法 |
| [Scrapling 爬虫框架](./modules/scrapling.md) | 高性能 Python 爬虫框架集成 |
| [ValueCell 金融平台](./modules/valuecell.md) | AI 驱动的金融数据分析平台 |
| [Rudder 团队协作](./modules/rudder.md) | 多 Agent 团队协作管理工具 |
| [Skills 技能集合](./modules/skills.md) | 可复用技能定义与扩展 |

---

## 项目核心特性

- **专业 Agents** — 提供任务专用的 AI Agent（如 `claudecode-expert`），支持代码审查、优化、调试和架构建议，覆盖完整开发生命周期
- **可复用 Skills** — 结构化的 Skill 定义（如 `claudecode-assistant-perspective`），包含核心原则、反模式、工作流模板和故障排除指南，可自由组合
- **多领域应用** — 横跨金融分析（ValueCell）、数据采集（Scrapling）、团队协作（Rudder）等多个专业领域，提供端到端解决方案
- **AI 协议支持** — 支持 MCP (Model Context Protocol) 等现代 AI 协议，实现 Agent 间的标准化通信与工具调用
- **社区驱动** — MIT 开源许可，通过 Git Submodule 集成优秀社区项目，鼓励贡献和二次开发
- **渐进式架构** — 采用"核心 + 扩展 + 应用"三层设计，按需使用，灵活扩展

---

## 项目结构概览

```
claude-code-skill-agents/
├── agents/                          # AI Agent 定义
│   └── claudecode-expert.md         # Claude Code 终极专家 Agent
├── skills/                          # 可复用 Skill 集合
│   ├── claudecode-assistant-perspective/  # 核心 Skill（自有）
│   ├── andrej-karpathy-skills/      # Karpathy 编程准则（Submodule）
│   ├── claude-mem/                  # 记忆管理 Skill（Submodule）
│   ├── skills/                      # Matt Pocock Skills（Submodule）
│   └── synology-spk-assistant-team/ # SPK 团队协作 Skill
├── crawl/                           # 数据采集模块
│   └── Scrapling/                   # 高性能爬虫框架（Submodule）
├── project/                         # 应用项目集成
│   ├── valuecell/                   # AI 金融平台（Submodule）
│   ├── TrendRadar/                  # 趋势雷达（Submodule）
│   ├── FinceptTerminal/             # 金融终端（Submodule）
│   └── awesome-design-md/          # 设计文档集合（Submodule）
├── team/                            # 团队协作工具
│   └── rudder/                      # 多 Agent 协作平台（Submodule）
├── docs/                            # 项目文档
│   ├── README.md                    # 文档主页（本文件）
│   ├── architecture.md              # 架构设计
│   └── modules/                     # 模块详细文档
├── LICENSE                          # MIT License
├── README.md                        # 项目主 README（英文）
└── README.zh-CN.md                  # 项目主 README（中文）
```

---

## 快速导航

### 按使用场景分类

#### 🎓 学习最佳实践

- 阅读 [Agents 模块](./modules/agents.md) 了解 Agent 设计模式
- 参考 `skills/andrej-karpathy-skills/` 获取编程准则
- 查看 `skills/claudecode-assistant-perspective/` 获取 Skill 开发框架

#### 🔧 开发 Skill / Agent

- 查阅 [项目架构](./architecture.md) 理解设计原则
- 参考现有 Agent 和 Skill 的结构与命名规范
- 阅读 [贡献指南](./contributing.md) 了解提交流程

#### 💰 金融应用

- [ValueCell 金融平台](./modules/valuecell.md) — AI 驱动的金融数据分析
- `project/FinceptTerminal/` — 金融桌面终端
- `project/TrendRadar/` — 趋势分析与预警

#### 🕷️ 数据采集

- [Scrapling 爬虫框架](./modules/scrapling.md) — 高性能 Python 爬虫
- 支持反检测、自动化浏览器、Spider 框架

#### 🤝 团队协作

- [Rudder 团队协作](./modules/rudder.md) — 多 Agent 运行调度
- 支持 AI Agent 协同工作流、智能任务分配

---

## 许可证

本项目采用 [MIT License](../LICENSE) 开源许可证。

- ✅ 可用于个人项目
- ✅ 可用于商业项目
- ✅ 可自由修改和分发
- ✅ 可创建衍生作品

唯一要求：保留原始许可证和版权声明。

---

<div align="center">

**Built with ❤️ for the Claude Code Community**

</div>
