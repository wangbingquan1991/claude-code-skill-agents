# Scrapling — 自适应 Web 爬虫框架

## 模块概述

Scrapling 是一个现代化的自适应 Web 爬虫框架，位于 `crawl/Scrapling/` 目录。基于 Python 构建，当前版本 **0.4.8**，提供从数据抓取到智能解析的完整工具链。

核心定位：**即使网站结构发生变化，也能自动重新定位目标元素** — 解决传统爬虫因 DOM 变动而失效的痛点。

---

## 核心架构

```
┌─────────────────────────────────────────────┐
│            用户接口层 (User Interface)        │
│  CLI Tool  │  Python API  │  MCP Server     │
├─────────────────────────────────────────────┤
│            爬虫框架层 (Spider Framework)      │
│  Spider  │  CrawlerEngine  │  Middleware    │
├─────────────────────────────────────────────┤
│            数据抓取层 (Fetcher)               │
│  StaticFetcher │ StealthFetcher │ Playwright │
├─────────────────────────────────────────────┤
│            解析工具层 (Parser)                │
│  Adaptor  │  Selector  │  AutoMatch        │
└─────────────────────────────────────────────┘
```

---

## 关键特性

| 特性 | 说明 | 技术实现 |
|------|------|---------|
| 自适应解析 | 网站 DOM 变化后自动重定位元素 | 基于元素指纹与相似度匹配算法 |
| 反爬虫内置 | 绕过 Cloudflare Turnstile 等防护 | `StealthFetcher` + 浏览器指纹伪装 |
| MCP 服务器 | 提供 AI Agent 集成接口 | 标准 MCP 协议，工具化抓取能力 |
| Checkpoint 机制 | 长任务暂停/恢复，断点续爬 | 状态序列化 + 增量恢复 |
| 性能领先 | 比 BeautifulSoup4 快 **784 倍** | 底层基于 lxml + C 扩展优化 |
| 类型安全 | 完整的类型注解支持 | `py.typed` + 严格类型检查 |
| Scrapy 风格 | 熟悉的 Spider 编程模型 | 继承式爬虫定义、中间件管道 |

---

## 核心组件说明

### Spider（爬虫定义）

继承自基类的爬虫单元，支持：
- 请求调度与并发控制
- 中间件管道（请求/响应拦截）
- 信号系统（生命周期事件）
- 数据导出（JSON/CSV/自定义）

### CrawlerEngine（引擎）

爬虫运行时调度引擎：
- 队列管理与优先级调度
- 并发限制与速率控制
- 重试策略与错误处理
- Checkpoint 状态管理

### Fetcher（抓取器）

三种抓取器适配不同场景：

| 类型 | 适用场景 | 特点 |
|------|---------|------|
| `StaticFetcher` | 静态页面、API 接口 | 轻量快速，基于 curl_cffi |
| `StealthFetcher` | 反爬虫网站 | TLS 指纹伪装，JS 渲染 |
| `PlaywrightFetcher` | 复杂 SPA、动态交互 | 完整浏览器环境 |

### Selector（选择器）

统一的元素选择接口：
- CSS 选择器
- XPath 表达式
- 自适应匹配（AutoMatch）
- 文本/属性过滤

---

## API 使用示例

### 简单 HTTP 抓取

```python
from scrapling import StaticFetcher

fetcher = StaticFetcher()
page = fetcher.get("https://example.com")

# CSS 选择器
titles = page.css("h1.title::text")

# 自适应匹配 — 即使 class 名变化也能定位
element = page.find("div", auto_match=True, identifier="product-card")
```

### 反爬虫网站处理

```python
from scrapling import StealthFetcher

fetcher = StealthFetcher(
    headless=True,
    block_images=True
)

# 自动处理 Cloudflare Turnstile
page = fetcher.get("https://protected-site.com")
data = page.css("div.content").extract()
```

### Scrapy 式爬虫框架

```python
from scrapling.spiders import Spider, Request

class ProductSpider(Spider):
    name = "products"
    start_urls = ["https://shop.example.com"]

    def parse(self, response):
        for item in response.css("div.product"):
            yield {
                "name": item.css("h2::text").get(),
                "price": item.css("span.price::text").get(),
            }
            
        # 翻页
        next_page = response.css("a.next::attr(href)").get()
        if next_page:
            yield Request(next_page, callback=self.parse)
```

### CLI 命令行

```bash
# 快速抓取单页
scrapling fetch https://example.com --selector "h1"

# 运行爬虫
scrapling crawl my_spider --output results.json

# 启动 MCP 服务器
scrapling serve --port 8080
```

---

## AI Agent 集成

### MCP 服务器工具

Scrapling 提供标准 MCP 服务器，暴露以下工具给 AI Agent：

| 工具名 | 功能 | 参数 |
|--------|------|------|
| `fetch_page` | 抓取页面内容 | url, selector, wait_for |
| `extract_data` | 结构化数据提取 | url, schema, format |
| `search_elements` | 元素搜索 | url, query, match_type |
| `screenshot` | 页面截图 | url, viewport, full_page |
| `interact` | 页面交互 | url, actions[] |

### Agent Skill 定义

位于 `agent-skill/Scrapling-Skill/`，提供：
- Skill Prompt 定义文件
- 使用示例与最佳实践
- 集成配置模板

---

## 技术栈

| 层级 | 技术 | 用途 |
|------|------|------|
| 解析引擎 | lxml | 高性能 HTML/XML 解析 |
| HTTP 客户端 | curl_cffi | TLS 指纹模拟的 HTTP 请求 |
| 浏览器自动化 | Playwright | 动态页面渲染与交互 |
| 序列化 | orjson | 高性能 JSON 编解码 |
| CLI | Click | 命令行界面框架 |
| 类型检查 | mypy/pyright | 静态类型验证 |
| 测试框架 | pytest | 单元与集成测试 |
| 代码规范 | ruff | Linting + Formatting |

---

## 项目结构

```
crawl/Scrapling/
├── scrapling/           # 核心源码
│   ├── core/           # 核心模块（适配器、选择器、引擎）
│   ├── engines/        # 抓取引擎实现
│   ├── fetchers/       # 三种 Fetcher 实现
│   ├── spiders/        # Spider 框架
│   ├── cli.py          # CLI 入口
│   └── parser.py       # 解析器
├── tests/              # 测试套件
├── docs/               # 文档站源码
├── agent-skill/        # AI Agent 技能包
├── pyproject.toml      # 项目配置
└── server.json         # MCP 服务器配置
```

---

## 相关链接

- 源码目录：[`crawl/Scrapling/`](../../crawl/Scrapling/)
- Agent Skill：[`crawl/Scrapling/agent-skill/`](../../crawl/Scrapling/agent-skill/)
- MCP 配置：[`crawl/Scrapling/server.json`](../../crawl/Scrapling/server.json)
