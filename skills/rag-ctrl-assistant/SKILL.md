---
name: rag-ctrl-assistant
description: |
  本地知识库搭建与维护全栈助手。涵盖知识库目录设计、Markdown卡片规范、
  静态站构建、全文检索配置、知识图谱可视化、AI问答集成、健康检查(Lint)全流程。

  触发词：「搭建知识库」「建RAG」「知识库怎么建」「帮我组织笔记」「静态知识库」
  「更新知识库」「检查知识库」「知识库健康度」「新建卡片」「迁移到本地知识库」
  「怎么用Markdown做知识库」「双向链接怎么设」「反链怎么搞」

  跳过条件：非知识管理类问题、已使用Obsidian/Notion等商业笔记软件且不打算迁移、
  纯代码开发问题（除非明确关联知识库）。
---

# RAG Control Assistant · 本地知识库搭建维护

> 「知识库不是你存了多少，是你找到了多少。」——静态编译的知识，永不过期。

## ⚡ 环境状态：已就绪

知识库已初始化，运行在 `~/RAG/`。以下是当前状态：

- **主知识库**：`~/RAG`（Zettelkasten + 静态站）—— 所有卡片编辑在此进行
- **备份副本**：思源笔记 —— 纯被动备份，不主动操作。每两周从 ~/RAG 同步一次
- **10 张卡片**分布在 4 个领域：代码开发(2)、金融策略(2)、小说创作(1)、Hermes(5)
- **build.py** 已就绪：`python ~/RAG/08-system/build.py`（含 Git 自动提交）
- **Git 版本控制**：已初始化（2 commits），每次修改后 build.py 自动 commit。remote 未配置，push 由用户自行决定时机
- **本地预览**：`cd ~/RAG && python -m http.server 8080 --bind 127.0.0.1`
- ⚠️ **Python 3.13 + macOS**：`localhost` 解析为 IPv6 `::1`，而 http.server 默认只绑 IPv4。必须加 `--bind 127.0.0.1`，否则 `localhost:8080` 返回 "Connection Closed"
- **卡片遵循 Zettelkasten 格式**，含 YAML frontmatter + [[双向链接]]

详见 `references/kb-inventory.md`（当前卡片清单与链接拓扑）。

## 核心理念

本Skill指导你从零搭建一个**纯本地、可版本管理、支持AI对话**的静态知识库。不依赖任何笔记应用、后端数据库或云服务。

三大支柱：
- **Markdown 写卡片** → 人类可读，Git可版本管理
- **构建脚本** → Markdown → 带模板的HTML，自动生成索引/图谱/反链
- **浏览器访问** → 一键 `python -m http.server`，跨平台零安装

第四支柱：
- **Git 强制版本控制** → 每次修改必须 commit，不允许无版本变更。Remote push 由用户自行决定时机，不做自动推送。

---

## 启动前必读

### 决策树：哪种方案适合你？

```
你现在的状态：
├─ 已有大量笔记在Obsidian/Logseq
│  └─ 想保持编辑体验 + 添加静态发布 → 方案A：Quartz 或 Hugo
├─ 从零开始，追求极致可控
│  └─ 不怕写脚本 → 方案B：自定义 build.py（本Skill默认推荐）
├─ 已有 MkDocs/Hugo/VitePress 经验
│  └─ 想复用现有工具链 → 方案C：基于现有SSG扩展
└─ 只要快速可用，不在意工具
   └─ 数据量 <1000 篇 → 方案B；>1000 篇 → 方案A
```

### 知识库目录：`~/RAG`

本Skill默认知识库根目录为 `~/RAG/`。所有操作基于此路径。

---

## 标准工作流

### 工作流A：从零搭建知识库（7步）

```
Step 1: 创建目录结构
  ├─ 执行下方「目录结构」创建所有文件夹
  ├─ 复制模板文件到 08-system/templates/
  └─ 检查：目录是否存在且完整

Step 2: 初始化资源
  ├─ 创建 assets/style.css（基础样式）
  ├─ 创建 assets/search.js（全文搜索，基于 Lunr.js/MiniSearch）
  ├─ 创建 assets/graph.js（知识图谱，基于 vis.js）
  └─ 检查：三个JS文件内容有效

Step 3: 编写构建脚本
  ├─ 创建 08-system/build.py
  ├─ 功能清单：MD→HTML渲染、[[链接]]解析、反链计算、
  │   index.html生成、graph.json生成、Lint报告生成
  └─ 运行一次：python build.py → 检查是否生成HTML

Step 4: 迁移首批卡片（10张）
  ├─ 从现有笔记中选择10个最重要的原子观点
  ├─ 按规范在 02-cards/ 下创建 .md 文件
  ├─ 手动添加 [[双向链接]]
  └─ 运行 build.py 并浏览器验证

Step 5: 配置搜索和图谱
  ├─ 确认 search.js 能正确加载搜索索引
  ├─ 确认 graph.js 能正确展示节点网络
  └─ 测试搜索：输入已知卡片内容验证命中

Step 6: 设置版本控制
  ├─ git init && git add -A && git commit -m "知识库初始化"
  ├─ 设置 .gitignore（排除 .DS_Store 等）
  └─ Remote push 不在此步骤 —— 用户自行决定何时推到远程仓库

Step 7: 建立日常习惯
  ├─ 确定每日摄入时间（建议早晚各10分钟）
  ├─ 确定每周检查日（建议周日）
  └─ 创建快捷启动命令（alias kb="cd ~/RAG && python -m http.server 8080 --bind 127.0.0.1"）
```

### 工作流B：日常摄入（5步）

```
Step 1: 素材收集
  └─ 将新资料放入 00-inbox/

Step 2: 提取原子观点
  ├─ 阅读素材，用一个文件承载一个核心观点
  ├─ 用自己的话重写（不要复制粘贴）
  └─ 一个卡片 50-300 字

Step 3: 编写卡片（见下方卡片规范）
  └─ 在 ~/RAG/02-cards/[领域]/ 下创建 .md 文件
  └─ 现有领域：dev/（代码开发）、finance/（金融策略）、fiction/（小说创作）、hermes/（Hermes 工具链）

Step 4: 添加链接
  ├─ 至少添加1个 [[出链]]
  ├─ 思考：这个观点和哪些已有卡片相关？
  └─ 检查 kb-inventory.md 中的孤悬链接清单，优先填补

Step 5: 构建 + 提交
  ├─ 运行 python ~/RAG/08-system/build.py（自动执行 Git commit）
  ├─ 检查 git log 确认提交已生成
  └─ cd ~/RAG && python -m http.server 8080 --bind 127.0.0.1  → 浏览器验证
  └─ push 时机由用户自行决定（非自动）
```

### 工作流C：健康检查 Lint + 修复提交（6步）

```
Step 1: 深度自检
  ├─ python ~/RAG/08-system/build.py --lint   → 基础 Lint（孤立卡片/过期/低权威）
  └─ python scripts/self-check.py ~/RAG       → 深度自检（孤悬链接/命名不匹配/健康度评分）

Step 2: 处理孤立卡片
  ├─ 零出链 × 零入链 → 要么删除要么建立链接
  └─ 零出链但被引用 → 添加出链使其与知识网连接

Step 3: 处理孤悬链接
  ├─ 孤悬链接 = 引用了不存在的卡片（通常由文件名与链接名不匹配导致）
  ├─ 检查 kb-inventory.md 中的孤悬链接清单，逐条决策：
  │   ├─ 文件名拼写不匹配 → 统一命名（见 references/naming-conventions.md）
  │   ├─ 确实缺少卡片 → 创建新卡片填补
  │   └─ 链接已过时 → 修正或删除链接
  └─ 优先修复双向互链的主干卡片断链

Step 4: 处理过期内容
  ├─ status: outdated 超过3个月 → 考虑更新或归档
  └─ 信息有误 → 更新 corrected 日期并修正

Step 5: 处理低权威警告
  ├─ authority < 2 但被大量引用 → 升级来源或降级引用
  └─ 无来源标注 → 补充来源信息

Step 6: 提交修复
  ├─ python ~/RAG/08-system/build.py（重建 + Git commit）
  └─ push 时机由用户自行决定
```

---

## 目录结构

```
~/RAG/                        # 知识库根目录
├── index.html                # 总目录（构建生成）
├── log.html                  # 操作日志
├── lint-report.html          # 健康检查报告（构建生成）
├── graph.json                # 图谱数据（构建生成）
├── search-index.json         # 搜索索引（构建生成）
├── assets/
│   ├── style.css             # 全局样式
│   ├── search.js             # 客户端全文搜索
│   └── graph.js              # 知识图谱可视化
├── 00-inbox/                 # 收件箱
├── 01-sources/               # 源文档（只读存档）
│   ├── papers/
│   ├── articles/
│   └── books/
├── 02-cards/                 # 原子卡片（Zettelkasten核心）
│   ├── fiction/              # 示例：小说创作领域
│   ├── dev/                  # 示例：代码开发领域
│   ├── finance/              # 示例：金融策略领域
│   └── content-factory/      # 示例：内容工厂
├── 03-mocs/                  # 综述页（Map of Content）
├── 04-projects/              # PARA - 进行中的项目
├── 05-areas/                 # PARA - 持续领域
├── 06-resources/             # PARA - 参考资源
├── 07-archives/              # PARA - 归档
└── 08-system/                # 系统文件
    ├── templates/
    │   ├── card-template.md  # 卡片模板
    │   └── moc-template.md   # 综述模板
    ├── build.py              # 构建脚本
    └── README.md             # 知识库Schema说明
```

## 卡片编写规范

每张卡片一个 `.md` 文件，必须以 YAML frontmatter 开头：

```markdown
---
domain: 金融策略          # 领域分类（必填）
type: strategy           # 卡片类型（必填）
authority: 4             # 权威度 1-5（必填）
status: evergreen        # draft/evergreen/outdated
source: "[[量化交易手册]]" # 来源引用
public: true             # 是否公开
created: 2026-05-19
updated: 2026-05-19
---

# 标题（一句话概括观点）

## 原文引用
> "...关键段落..."

## 核心观点
**一句话总结**

## 关键标签
#标签1 #标签2

## 关联
[[相关卡片1]]  [[相关卡片2]]

## 我的应用
这段知识如何被使用...
```

### 领域专属卡片模板

**小说创作 - 人物卡**：
```markdown
---
domain: 小说创作
type: character
story: "[[小说项目A]]"
authority: 1
---
# 角色名
- **核心欲望**：XXX
- **致命缺陷**：XXX
- **关系**：[[角色B]]（导师）
- **弧光**：从A到B的转变
```

**代码开发 - 模式卡**：
```markdown
---
domain: 代码开发
type: pattern
language: Python
authority: 4
source: "[[设计模式-可复用]]"
---
# 模式名
## 问题
XXXX
## 解决方案
```python
...
\```
## 应用场景
XXXX
```

## 方法论融合说明

| 方法论 | 作用层 | 落地位置 |
|--------|--------|---------|
| **PARA** | 顶层文件夹 | 04-projects / 05-areas / 06-resources / 07-archives |
| **Zettelkasten** | 卡片层 | 02-cards：原子笔记、双向链接、唯一ID |
| **渐进式总结** | 内容层 | 卡片正文：引用→摘要→标签→综合→应用 |
| **Johnny Decimal** | 编号层 | 文件名前缀：`22.04-动量策略.md` |
| **LLM Wiki** | 操作层 | index/log/lint 三操作，构建脚本实现 |
| **RAG-Anything** | 多模态层 | HTML内嵌图片/表格/公式，附LLM可读描述 |

### 选择指南

| 如果你需要... | 重点使用方法论 | 跳过 |
|-------------|--------------|------|
| 项目管理为主 | PARA + LLM Wiki | Johnny Decimal |
| 知识深度连接 | Zettelkasten + 渐进式总结 | PARA |
| 金融/合规场景 | Johnny Decimal + 渐进式总结 | — |
| 内容创作输出 | Zettelkasten + PARA | Johnny Decimal |
| 极简入门 | 仅LLM Wiki三操作 | 其余后续添加 |

---

## 构建脚本核心能力

`build.py` 必须实现（完整代码见 `references/build-script-spec.md`）：

1. **MD→HTML渲染**：扫描所有 `.md`，用 Python-Markdown 库渲染为 HTML，套用统一模板
2. **链接解析**：识别 `[[Wiki链接]]`，转换为相对 `<a>` 标签
3. **反链计算**：全局扫描后，为每个文件生成「被以下卡片引用」区块
4. **索引生成**：按领域/标签/状态/权威度生成 `index.html` 多级过滤视图
5. **图谱数据**：从链接关系生成 `graph.json`，供 vis.js 前端渲染
6. **搜索索引**：生成 `search-index.json`，供 Lunr.js/MiniSearch 前端加载
7. **Lint报告**：检测孤立卡片、过期页面、低权威警告、可能重复

## 静态站推荐方案

详细对比见 `references/static-site-comparison.md`：

| 方案 | 适合人群 | 优点 | 缺点 |
|------|---------|------|------|
| **自定义 build.py** | 追求极致可控 | 零依赖、完全定制 | 需要写脚本 |
| **Quartz** | Obsidian用户 | 开箱即用、双向链接、图谱 | 需Node.js |
| **Hugo** | 追求速度 | 毫秒级构建、主题多 | Go安装、模板学习 |
| **MkDocs Material** | 文档为主 | 搜索强、插件多 | 偏文档风格 |

---

## Git 版本控制规范

`~/RAG` 使用 Git 管理所有变更。**每次修改必须产生一个 commit**，这是硬性规则。

### 提交规则

| 规则 | 说明 |
|------|------|
| **每次修改必 commit** | build.py 默认自动执行 `git add -A && git commit`，跳过需显式 `--no-commit` |
| **提交信息自动化** | 新增卡片时生成 `feat: 新增 N 张卡片 (标题摘要)`，纯构建产出时生成 `chore: 更新 N 个文件（构建产出）` |
| **不自动 push** | Remote push 由用户自行决定时机和频率，build.py 绝不执行 `git push` |
| **无远程不报错** | 未配置 remote 时正常工作，仅在用户执行 push 时提示 |

### 用户自行管理

```
用户决定:
├─ 何时添加 remote:    git remote add origin <url>
├─ 何时 push:          git push origin main
├─ push 频率:          每日 / 每周 / 每两周 / 不定期
└─ 多机同步:           自行选择 GitHub/GitLab/私有服务器
```

### .gitignore

```
.DS_Store
__pycache__/
*.pyc
.venv/
node_modules/
*.log
```

### 常用 Git 命令

```bash
cd ~/RAG
git log --oneline -10        # 查看最近提交
git diff                     # 查看未暂存变更
git remote add origin <url>  # 添加远程仓库
git push origin main         # 推送到远程
```

---

## 隐私与安全

| 需求 | 方案 |
|------|------|
| 本地加密 | VeraCrypt加密卷挂载 `~/RAG` |
| 版本控制 | `~/RAG` 为 Git 仓库，每次修改自动 commit（`--no-commit` 可跳过）。Remote push 由用户自行决定时机 |
| 敏感内容 | YAML `public: false`，构建脚本跳过 |
| 金融合规 | 页脚自动插入「个人研究，不构成投资建议」 |
| 外部访问 | 仅本地 `python -m http.server`，不暴露外网 |

---

## 诚实边界

1. **不替代思考**：知识库是外部记忆，不是大脑。链接需要你手动建立，AI只能辅助建议。
2. **部分RAG方案为补充**：纯静态HTML方案不包含向量数据库。如需语义搜索和RAG问答，需要额外搭建向量存储层。
3. **大规模知识库需升级**：卡片数 > 5000 时，`build.py` 构建速度可能下降。建议届时迁移至 Hugo 或 Astro 等编译型SSG。
4. **AI问答需本地LLM**：页面AI对话功能依赖用户提供本地LLM（Ollama/LM Studio），本Skill不包含LLM的安装和配置。
5. **多模态有限**：图片/表格可嵌入HTML，但视频/音频的多模态检索不在纯静态方案范围内。
6. **信息截止**：本Skill基于调研截至2026年5月的最新实践，工具版本和社区推荐可能随时间变化。

---

## 参考文件（本Skill内）

- `references/kb-inventory.md` — 当前卡片清单、链接拓扑、孤悬链接
- `scripts/self-check.py` — 深度自检脚本（孤悬链接/命名不匹配/健康度评分，覆盖 build.py 未检查项）
- `references/naming-conventions.md` — 卡片文件命名规范（防断链）
- `references/build-script-spec.md` — 构建脚本完整规范
- `references/static-site-comparison.md` — 静态站详细对比
- `references/rag-local-setup.md` — 本地RAG搭建指南
- `references/sources/01-user-design-spec.md` — 用户完整设计方案

---

> 本Skill由女娲 · Skill造人术 生成，基于用户一手设计方案 + Tavily多源调研
