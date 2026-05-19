# 用户知识库设计方案（完整版）

> 来源：用户直接提供 | 可信度：一手 | 日期：2026-05-19

## 核心设计理念

从"软件库"到"静态编译的知识库"，不依赖任何后端数据库或笔记应用。

三大支柱：
- **Markdown 写卡片**（人类可读、可版本管理）
- **轻量构建脚本**（Markdown → HTML，生成索引/图谱数据）
- **本地 HTTP 服务器**（python -m http.server / npx serve）

## 融合方法论

| 方法论 | 作用层 |
|--------|--------|
| PARA | 管顶层文件夹结构 |
| Zettelkasten | 管卡片内部双向链接 |
| 渐进式总结 | 管内容压缩与层级展示 |
| Johnny Decimal | 精确编号系统 |
| LLM Wiki | index/log/lint 三操作 |
| RAG-Anything | 多模态嵌入 |

## 本地目录结构

~~~
knowledge-base/
├── index.html                # 动态内容总目录
├── log.html                  # 操作日志
├── assets/                   # CSS、JS、图片
├── 00-inbox/                 # 收件箱
├── 01-sources/               # 源文档存档（只读）
├── 02-cards/                 # 原子卡片库（Zettelkasten）
├── 03-mocs/                  # 综述页（Map of Content）
├── 04-projects/              # PARA Projects
├── 05-areas/                 # PARA Areas
├── 06-resources/             # PARA Resources
├── 07-archives/              # PARA Archives
└── 08-system/                # 模板、脚本、约定
    ├── templates/
    ├── build.py
    └── README.md
~~~

## 核心工作流

### Ingest（摄入资料）
1. 原始资料 → 00-inbox / 01-sources
2. 新建 .md 卡片 + YAML 元数据 + [[链接]]
3. 写日志到 log.md
4. 运行 build.py 编译全站
5. 启动本地服务器查看

### Query（检索问答）
- 目录式查找（index.html 多级过滤）
- 全文搜索（Lunr.js/MiniSearch）
- 知识图谱导航（vis.js）
- AI 问答（可选，本地 Ollama）

### Lint（健康检查）
- 孤立卡片 / 过期页面 / 低权威警告 / 可能重复
- Git 版本管理

## 本地知识库目录
~/RAG
