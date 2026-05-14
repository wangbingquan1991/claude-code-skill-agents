# Claude Code Skill Agents

<div align="center">

**专为 Claude Code 打造的精选 AI Agent 和可复用 Skills 集合**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/wangbingquan1991/claude-code-skill-agents?style=social)](https://github.com/wangbingquan1991/claude-code-skill-agents/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/wangbingquan1991/claude-code-skill-agents?style=social)](https://github.com/wangbingquan1991/claude-code-skill-agents/network/members)

[English](README.md) | **中文**

</div>

---

## 📋 目录

- [项目简介](#项目简介)
- [核心特性](#核心特性)
- [安装方式](#安装方式)
- [使用方法](#使用方法)
- [可用 Agents](#可用-agents)
- [可用 Skills](#可用-skills)
- [项目结构](#项目结构)
- [贡献指南](#贡献指南)
- [许可证](#许可证)
- [致谢](#致谢)

## 🎯 项目简介

**Claude Code Skill Agents** 是一个模块化、可扩展的 AI agents 和 skills 集合，专为提升 Claude Code 工作流而设计。无论你是构建复杂应用、调试代码还是优化开发流程，这些 agents 和 skills 都能提供专家级指导和最佳实践。

### 为什么使用本项目？

- 🚀 **提升效率**：预构建的 agents 处理常见开发任务
- 📚 **最佳实践**：学习经过验证的模式和工作流
- 🔧 **模块化设计**：按需使用，灵活扩展
- 🌍 **社区驱动**：开源项目，欢迎贡献

## ✨ 核心特性

- **专业 Agents**：针对不同场景的任务专用 AI 助手
- **可复用 Skills**：可组合的模块化 skill 定义
- **易于集成**：与 Claude Code 无缝协作
- **文档完善**：清晰的示例和使用指南
- **MIT 许可**：个人和商业用途均可免费使用

## 📦 安装方式

### 方式一：直接克隆

直接克隆仓库：

```bash
git clone https://github.com/wangbingquan1991/claude-code-skill-agents.git
cd claude-code-skill-agents
```

### 方式二：下载 ZIP

从 [Releases 页面](https://github.com/wangbingquan1991/claude-code-skill-agents/releases) 下载最新版本。

## 💡 使用方法

### 基础配置

1. **复制 agents 到 Claude Code 目录**：
   ```bash
   cp -r skill-agents/agents/* ~/.claude/agents/
   cp -r skill-agents/skills/* ~/.claude/skills/
   ```

2. **或在项目中直接引用**：
   ```bash
   # 创建符号链接
   ln -s /path/to/skill-agents/agents ~/.claude/agents/custom-agents
   ln -s /path/to/skill-agents/skills ~/.claude/skills/custom-skills
   ```

### 在 Claude Code 中使用

安装后，你可以在 Claude Code 会话中调用 agents 和 skills：

```
@claudecode-expert 帮我优化这段代码
/skill claudecode-assistant-perspective
```

## 🤖 可用 Agents

### claudecode-expert

**用途**：Claude Code 操作的专家级助手

**核心能力**：
- 代码审查和优化
- 最佳实践指导
- 调试策略
- 性能调优
- 架构建议

**使用场景**：
```
- "审查我的代码，找出潜在问题"
- "如何优化这个函数？"
- "这里处理错误的最佳实践是什么？"
```

**位置**：[`agents/claudecode-expert.md`](agents/claudecode-expert.md)

## 🎨 可用 Skills

### claudecode-assistant-perspective

**用途**：高效的 Claude Code 辅助综合指南

**组成部分**：
- 核心原则和方法论
- 需要避免的反模式
- 工作流模板
- 基于研究的最佳实践
- 故障排除指南

**主要主题**：
- ✅ 核心开发原则
- ✅ Skill 开发框架
- ✅ Agent 设计模式
- ✅ 最佳实践汇编
- ✅ 常用工作流
- ✅ 故障排除策略

**位置**：[`skills/claudecode-assistant-perspective/`](skills/claudecode-assistant-perspective/)

#### 文档结构

```
skills/claudecode-assistant-perspective/
├── SKILL.md                    # 主 skill 定义
├── references/
│   ├── anti-patterns.md        # 常见错误避免
│   ├── document-index.md       # 导航指南
│   ├── workflows.md            # 标准工作流
│   └── research/
│       ├── 01-core-principles.md
│       ├── 02-skill-dev-framework.md
│       ├── 03-agent-design-patterns.md
│       ├── 04-best-practices.md
│       ├── 05-workflows.md
│       └── 06-troubleshooting.md
```

## 📁 项目结构

```
claude-code-skill-agents/
├── agents/                     # AI agent 定义
│   └── claudecode-expert.md   # 专家助手 agent
├── skills/                     # 可复用 skills
│   └── claudecode-assistant-perspective/
│       ├── SKILL.md           # Skill 定义
│       └── references/        # 支持文档
├── .gitignore                 # Git 忽略规则
├── LICENSE                    # MIT 许可证
├── README.md                  # 英文文档
└── README.zh-CN.md            # 中文文档（本文件）
```

## 🤝 贡献指南

我们欢迎各种形式的贡献！以下是参与方式：

### 贡献方式

1. **报告问题**：发现 Bug？[提交 Issue](https://github.com/wangbingquan1991/claude-code-skill-agents/issues)
2. **建议功能**：有好想法？在 [Discussions](https://github.com/wangbingquan1991/claude-code-skill-agents/discussions) 中分享
3. **提交 PR**：想添加新的 agents 或 skills？Fork 后创建 Pull Request
4. **改进文档**：帮助我们完善文档

### 开发工作流

```bash
# 1. Fork 本仓库
# 2. 克隆你的 fork
git clone https://github.com/YOUR_USERNAME/claude-code-skill-agents.git

# 3. 创建功能分支
git checkout -b feature/amazing-new-agent

# 4. 进行修改
# 添加新的 agent 或 skill...

# 5. 提交并推送
git add .
git commit -m "feat: 添加超棒的新 agent"
git push origin feature/amazing-new-agent

# 6. 在 GitHub 上创建 Pull Request
```

### 贡献规范

- 遵循现有的结构和命名约定
- 包含清晰的文档和示例
- 在真实场景中测试你的 agents/skills
- 如果添加新功能，请更新 README

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

### 这意味着什么

✅ 你可以用于个人项目  
✅ 你可以用于商业项目  
✅ 你可以修改和分发  
✅ 你可以创建衍生作品  

❗ 只需包含原始许可证和版权声明

## 🙏 致谢

- **[Claude Code](https://github.com/anthropics/claude-code)** - 让这一切成为可能的基础
- **[Anthropic](https://www.anthropic.com/)** - 创造 Claude 的团队
- **社区贡献者** - 所有贡献想法和反馈的朋友们

## 📞 支持与联系

- 📧 **问题反馈**：[GitHub Issues](https://github.com/wangbingquan1991/claude-code-skill-agents/issues)
- 💬 **讨论交流**：[GitHub Discussions](https://github.com/wangbingquan1991/claude-code-skill-agents/discussions)
- 📖 **详细文档**：查看各个 agent/skill 文件获取详细使用说明

## 🔗 相关项目

### 官方资源
- [Claude Code](https://github.com/anthropics/claude-code) - Claude Code 官方仓库
- [Claude Skills](https://github.com/anthropics/skills) - Anthropic 官方 skills
- [Claude Cookbooks](https://github.com/anthropics/claude-cookbooks) - 实用示例和模式
- [Prompt Engineering Tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial) - 交互式提示工程指南

### 社区集合
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) - Claude Code 资源精选列表
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) - 全面的 Claude Code 指南
- [Free Claude Code](https://github.com/Alishahryar1/free-claude-code) - 免费资源和工具
- [Learn Claude Code](https://github.com/shareAI-lab/learn-claude-code) - 学习材料和教程

### 最佳实践与指南
- [Claude Howto](https://github.com/luongnv89/claude-howto) - 实用操作指南
- [Claude Code Best Practice](https://github.com/shanraisshan/claude-code-best-practice) - 最佳实践集合
- [Claude Code Sourcemap](https://github.com/ChinaSiro/claude-code-sourcemap) - 源代码分析
- [Claude Code Source Code](https://github.com/777genius/claude-code-source-code-full) - 完整源代码参考

---

<div align="center">

**由 Claude Code 社区用 ❤️ 打造**

如果觉得有用，请 [⭐ 给个星标](https://github.com/wangbingquan1991/claude-code-skill-agents)！

</div>
