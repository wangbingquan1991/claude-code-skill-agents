# 快速入门指南

本指南将帮助你快速搭建 Skill-Agents 开发环境并运行各个模块。

---

## 前提条件

根据你需要使用的模块，确保安装了以下工具：

| 工具 | 版本要求 | 适用模块 |
|------|----------|----------|
| Git（含 Submodule 支持） | 最新版 | 全部 |
| Python | 3.10+ | Scrapling |
| Python | 3.12+ | ValueCell |
| Node.js | 20+ | Rudder、Claude-Mem |
| pnpm | 9.15+ | Rudder |
| Bun | 1.0+ | Claude-Mem |
| uv | 最新版 | ValueCell（Python 依赖管理） |

> **提示**：你不需要安装所有工具，只需安装你要使用的模块对应的依赖即可。

---

## 安装项目

### 克隆仓库（含子模块）

```bash
git clone --recursive https://github.com/xxx/skill-agents.git
cd skill-agents
```

### 如果已经克隆但没有子模块

```bash
git submodule update --init --recursive
```

### 验证项目结构

克隆完成后，确认以下目录存在：

```
skill-agents/
├── agents/          # Agent 定义
├── crawl/           # 爬虫模块（Scrapling）
├── project/         # 项目模块（ValueCell 等）
├── skills/          # Skill 定义
└── team/            # 团队协作模块（Rudder）
```

---

## 使用核心 Agent 和 Skill

### 引入 Claude Code Expert Agent

将 `agents/claudecode-expert.md` 作为 Agent 引入到你的 Claude Code 环境中：

1. 打开 Claude Code 设置
2. 添加 Agent 文件路径：`agents/claudecode-expert.md`
3. Agent 将自动加载并提供专家级编码辅助

### 安装 Claude Code Assistant Perspective Skill

将 `skills/claudecode-assistant-perspective/` 作为 Skill 安装到 Claude Code 中：

1. 进入 Skill 管理界面
2. 指定 Skill 目录路径
3. 确认安装

### 安装 Karpathy 技能

可通过以下两种方式安装：

- **方式一**：通过 `CLAUDE.md` 加载 — 将 `skills/andrej-karpathy-skills/CLAUDE.md` 引入项目
- **方式二**：通过插件目录 — 将 `.claude-plugin/` 目录复制到项目根目录

### 安装 Claude-Mem

```bash
npx claude-mem install
```

安装完成后，Claude-Mem 将自动管理对话记忆和上下文。

---

## 启动 Scrapling

Scrapling 是一个高性能网页抓取和解析框架。

```bash
cd crawl/Scrapling

# 安装基础包
pip install -e .

# 安装含抓取器（推荐）
pip install -e ".[fetchers]"

# 安装含 AI/MCP 支持
pip install -e ".[ai]"
```

### CLI 使用

```bash
# 抓取网页并输出为 Markdown
scrapling extract get "https://example.com" output.md

# 查看更多命令
scrapling --help
```

### MCP 服务器

```bash
# 启动 MCP 服务器供 AI 助手调用
scrapling mcp
```

---

## 启动 ValueCell

ValueCell 是一个金融数据分析工具。

```bash
cd project/valuecell

# 复制环境配置文件并填写 API 密钥
cp .env.example .env

# 编辑 .env 文件，配置必要的 API 密钥
# OPENAI_API_KEY=your-key-here

# 一键启动（自动安装依赖）
bash start.sh
```

启动成功后访问：http://localhost:1420

> **注意**：首次启动会自动安装 Python 和前端依赖，可能需要几分钟。

---

## 启动 Rudder

Rudder 是一个团队协作和任务管理平台。

```bash
cd team/rudder

# 安装依赖
pnpm install

# 启动开发服务器
pnpm dev
```

启动成功后访问：http://localhost:3100

> **提示**：确保已正确配置 `.env` 文件，可参考 `.env.example`。

---

## 常见问题

### 1. 子模块克隆失败怎么办？

如果 `git clone --recursive` 失败，尝试分步操作：

```bash
git clone https://github.com/xxx/skill-agents.git
cd skill-agents
git submodule init
git submodule update --recursive
```

如果某个子模块始终失败，可以单独跳过：

```bash
git submodule update --init --recursive --jobs 4
```

### 2. Python 版本不兼容？

建议使用 `pyenv` 管理多版本 Python：

```bash
pyenv install 3.12.0
pyenv local 3.12.0
```

或使用 `conda` 创建独立环境：

```bash
conda create -n skill-agents python=3.12
conda activate skill-agents
```

### 3. 前端启动端口冲突？

如果端口已被占用，可以修改启动端口：

- **Rudder**：修改 `team/rudder/.env` 中的 `PORT` 变量
- **ValueCell**：修改 `project/valuecell/.env` 中的端口配置

或者先查找并关闭占用端口的进程：

```bash
lsof -i :3100  # 查看占用端口的进程
kill -9 <PID>  # 关闭对应进程
```

### 4. 如何只使用某个模块？

每个模块都可以独立使用，无需安装全部依赖。只需进入对应目录并按模块文档操作即可。例如只使用 Scrapling：

```bash
cd crawl/Scrapling
pip install -e ".[fetchers]"
```

### 5. 如何更新子模块到最新版？

```bash
# 更新所有子模块到远程最新提交
git submodule update --remote --merge

# 更新单个子模块
git submodule update --remote --merge crawl/Scrapling
```

### 6. pnpm install 失败？

确保 pnpm 版本 ≥ 9.15：

```bash
pnpm --version
# 如果版本过低，升级 pnpm
npm install -g pnpm@latest
```

### 7. MCP 服务器无法连接？

检查以下几点：

1. 确认已安装 AI 依赖：`pip install -e ".[ai]"`
2. 确认服务器已启动：`scrapling mcp`
3. 检查端口是否被防火墙阻止
4. 查看日志输出中的错误信息

---

## 下一步

- 查阅 [贡献指南](./contributing.md) 了解如何参与项目
- 阅读各模块的详细文档了解高级用法
- 在 Issues 中报告问题或提出建议
