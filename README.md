# Claude Code Skill Agents

<div align="center">

**A curated collection of specialized agents and reusable skills for Claude Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/wangbingquan1991/claude-code-skill-agents?style=social)](https://github.com/wangbingquan1991/claude-code-skill-agents/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/wangbingquan1991/claude-code-skill-agents?style=social)](https://github.com/wangbingquan1991/claude-code-skill-agents/network/members)

**English** | [中文](README.zh-CN.md)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Available Agents](#available-agents)
- [Available Skills](#available-skills)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## 🎯 Overview

**Claude Code Skill Agents** is a modular, extensible collection of AI agents and skills designed to supercharge your Claude Code workflow. Whether you're building complex applications, debugging code, or optimizing development processes, these agents and skills provide expert guidance and best practices.

### Why Use This?

- 🚀 **Boost Productivity**: Pre-built agents handle common development tasks
- 📚 **Best Practices**: Learn from proven patterns and workflows
- 🔧 **Modular Design**: Use only what you need, extend as required
- 🌍 **Community-Driven**: Open source and welcoming contributions

## ✨ Features

- **Specialized Agents**: Task-specific AI assistants for different scenarios
- **Reusable Skills**: Modular skill definitions that can be combined
- **Easy Integration**: Works seamlessly with Claude Code
- **Well-Documented**: Clear examples and usage guidelines
- **MIT Licensed**: Free for personal and commercial use

## 📦 Installation

### Option 1: Direct Clone

Clone the repository directly:

```bash
git clone https://github.com/wangbingquan1991/claude-code-skill-agents.git
cd claude-code-skill-agents
```

### Option 2: Download ZIP

Download the latest release from the [Releases page](https://github.com/wangbingquan1991/claude-code-skill-agents/releases).

## 💡 Usage

### Basic Setup

1. **Copy agents to your Claude Code directory**:
   ```bash
   cp -r skill-agents/agents/* ~/.claude/agents/
   cp -r skill-agents/skills/* ~/.claude/skills/
   ```

2. **Or reference directly in your project**:
   ```bash
   # Create symbolic links
   ln -s /path/to/skill-agents/agents ~/.claude/agents/custom-agents
   ln -s /path/to/skill-agents/skills ~/.claude/skills/custom-skills
   ```

### Using in Claude Code

Once installed, you can invoke agents and skills in your Claude Code sessions:

```
@claudecode-expert Help me optimize this code
/skill claudecode-assistant-perspective
```

## 🤖 Available Agents

### claudecode-expert

**Purpose**: Expert-level assistance for Claude Code operations

**Capabilities**:
- Code review and optimization
- Best practices guidance
- Debugging strategies
- Performance tuning
- Architecture recommendations

**Use Cases**:
```
- "Review my code for potential issues"
- "How can I optimize this function?"
- "What's the best practice for handling errors here?"
```

**Location**: [`agents/claudecode-expert.md`](agents/claudecode-expert.md)

## 🎨 Available Skills

### claudecode-assistant-perspective

**Purpose**: Comprehensive guidelines for effective Claude Code assistance

**Components**:
- Core principles and methodologies
- Anti-patterns to avoid
- Workflow templates
- Research-backed best practices
- Troubleshooting guides

**Key Topics**:
- ✅ Core development principles
- ✅ Skill development framework
- ✅ Agent design patterns
- ✅ Best practices compilation
- ✅ Common workflows
- ✅ Troubleshooting strategies

**Location**: [`skills/claudecode-assistant-perspective/`](skills/claudecode-assistant-perspective/)

#### Documentation Structure

```
skills/claudecode-assistant-perspective/
├── SKILL.md                    # Main skill definition
├── references/
│   ├── anti-patterns.md        # Common mistakes to avoid
│   ├── document-index.md       # Navigation guide
│   ├── workflows.md            # Standard workflows
│   └── research/
│       ├── 01-core-principles.md
│       ├── 02-skill-dev-framework.md
│       ├── 03-agent-design-patterns.md
│       ├── 04-best-practices.md
│       ├── 05-workflows.md
│       └── 06-troubleshooting.md
```

## 📁 Project Structure

```
claude-code-skill-agents/
├── agents/                     # AI agent definitions
│   └── claudecode-expert.md   # Expert assistant agent
├── skills/                     # Reusable skills
│   └── claudecode-assistant-perspective/
│       ├── SKILL.md           # Skill definition
│       └── references/        # Supporting documentation
├── .gitignore                 # Git ignore rules
├── LICENSE                    # MIT License
└── README.md                  # This file
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Ways to Contribute

1. **Report Issues**: Found a bug? [Open an issue](https://github.com/wangbingquan1991/claude-code-skill-agents/issues)
2. **Suggest Features**: Have an idea? Share it in [Discussions](https://github.com/wangbingquan1991/claude-code-skill-agents/discussions)
3. **Submit PRs**: Want to add new agents or skills? Fork and create a pull request
4. **Improve Docs**: Help us make documentation better

### Development Workflow

```bash
# 1. Fork the repository
# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/claude-code-skill-agents.git

# 3. Create a feature branch
git checkout -b feature/amazing-new-agent

# 4. Make your changes
# Add new agent or skill...

# 5. Commit and push
git add .
git commit -m "feat: Add amazing new agent"
git push origin feature/amazing-new-agent

# 6. Open a Pull Request
```

### Contribution Guidelines

- Follow the existing structure and naming conventions
- Include clear documentation and examples
- Test your agents/skills in real scenarios
- Update the README if adding new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### What This Means

✅ You can use this for personal projects  
✅ You can use this for commercial projects  
✅ You can modify and distribute  
✅ You can create derivative works  

❗ Just include the original license and copyright notice

## 🙏 Acknowledgments

- **[Claude Code](https://github.com/anthropics/claude-code)** - The foundation that makes this possible
- **[Anthropic](https://www.anthropic.com/)** - For creating Claude
- **Community Contributors** - Everyone who contributes ideas and feedback

## 📞 Support

- 📧 **Issues**: [GitHub Issues](https://github.com/wangbingquan1991/claude-code-skill-agents/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/wangbingquan1991/claude-code-skill-agents/discussions)
- 📖 **Documentation**: Check individual agent/skill files for detailed usage

## 🔗 Related Projects

### Official Resources
- [Claude Code](https://github.com/anthropics/claude-code) - Official Claude Code repository
- [Claude Skills](https://github.com/anthropics/skills) - Official Anthropic skills
- [Claude Cookbooks](https://github.com/anthropics/claude-cookbooks) - Practical examples and patterns
- [Prompt Engineering Tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial) - Interactive prompt engineering guide

### Community Collections
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) - Curated list of Claude Code resources
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) - Comprehensive Claude Code guide
- [Free Claude Code](https://github.com/Alishahryar1/free-claude-code) - Free resources and tools
- [Learn Claude Code](https://github.com/shareAI-lab/learn-claude-code) - Learning materials and tutorials

### Best Practices & Guides
- [Claude Howto](https://github.com/luongnv89/claude-howto) - Practical how-to guides
- [Claude Code Best Practice](https://github.com/shanraisshan/claude-code-best-practice) - Best practices collection
- [Claude Code Sourcemap](https://github.com/ChinaSiro/claude-code-sourcemap) - Source code analysis
- [Claude Code Source Code](https://github.com/777genius/claude-code-source-code-full) - Full source code reference

---

<div align="center">

**Built with ❤️ for the Claude Code Community**

[⭐ Star this repo](https://github.com/wangbingquan1991/claude-code-skill-agents) if you find it helpful!

</div>
