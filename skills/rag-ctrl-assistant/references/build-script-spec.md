# 构建脚本完整规范 (build.py)

## 技术选型

| 组件 | 推荐 | 备选 |
|------|------|------|
| MD渲染 | Python-Markdown | Mistune, Markdown2 |
| 模板引擎 | Jinja2 | string.Template |
| HTML模板 | 单文件 base.html | 多模板继承 |
| 前端搜索 | Lunr.js | MiniSearch, Fuse.js |
| 图谱可视化 | vis.js | D3.js, Cytoscape.js |
| 语法高亮 | Pygments (服务端) | highlight.js (客户端) |

## build.py 完整流程

### 1. 扫描阶段
```python
def scan_files(base_dir):
    """扫描所有 .md 文件，解析 YAML frontmatter"""
    cards = []
    for md_file in Path(base_dir).rglob("*.md"):
        if "08-system" in str(md_file):
            continue  # 跳过系统文件
        with open(md_file) as f:
            content = f.read()
        frontmatter, body = parse_frontmatter(content)
        cards.append({
            "path": md_file,
            "relative_path": str(md_file.relative_to(base_dir)),
            "frontmatter": frontmatter,
            "body": body,
            "links": extract_wikilinks(body),      # 出链
            "tags": extract_tags(body),             # #标签
            "html_filename": md_file.stem + ".html"
        })
    return cards
```

### 2. 反链计算
```python
def compute_backlinks(cards):
    """为每张卡片计算谁引用了它"""
    # 建立 slug → card 映射
    slug_map = {}
    for card in cards:
        slug = card["frontmatter"].get("title", card["path"].stem)
        slug_map[slug.lower()] = card["path"]
    
    # 计算反链
    for card in cards:
        card["backlinks"] = []
        for other in cards:
            if other["path"] == card["path"]:
                continue
            for link in other["links"]:
                if link.lower() in slug_map and slug_map[link.lower()] == card["path"]:
                    card["backlinks"].append({
                        "from": other["relative_path"],
                        "from_title": other["frontmatter"].get("title", "")
                    })
```

### 3. HTML 渲染
```python
def render_card(card, template, all_cards):
    """将单张卡片渲染为 HTML"""
    # 渲染 Markdown 正文
    md = markdown.Markdown(extensions=['fenced_code', 'tables', 'footnotes'])
    html_body = md.convert(card["body"])
    
    # 处理 [[Wiki链接]]
    html_body = convert_wikilinks(html_body, card["links"])
    
    # 套用模板
    return template.render(
        title=card["frontmatter"].get("title", card["path"].stem),
        domain=card["frontmatter"].get("domain", "未分类"),
        authority=card["frontmatter"].get("authority", 3),
        status=card["frontmatter"].get("status", "draft"),
        source=card["frontmatter"].get("source", ""),
        updated=card["frontmatter"].get("updated", ""),
        body=html_body,
        links_out=card["links"],
        links_in=card["backlinks"],
        tags=card["tags"],
    )
```

### 4. 索引生成
```python
def generate_index(cards, output_dir):
    """生成 index.html 总目录"""
    # 按领域分组
    domains = {}
    for card in cards:
        domain = card["frontmatter"].get("domain", "未分类")
        domains.setdefault(domain, []).append(card)
    
    # 渲染索引页
    index_html = index_template.render(
        domains=domains,
        total_cards=len(cards),
        by_status=group_by_status(cards),
        by_authority=group_by_authority(cards),
    )
    write_file(output_dir / "index.html", index_html)
```

### 5. 图谱数据生成
```python
def generate_graph(cards, output_dir):
    """生成 graph.json 供前端可视化"""
    nodes = []
    edges = []
    node_ids = set()
    
    for card in cards:
        card_id = card["relative_path"]
        if card_id not in node_ids:
            nodes.append({
                "id": card_id,
                "label": card["frontmatter"].get("title", card["path"].stem),
                "group": card["frontmatter"].get("domain", "未分类"),
                "value": card["frontmatter"].get("authority", 3),
            })
            node_ids.add(card_id)
        
        for link in card["links"]:
            edges.append({"from": card_id, "to": link})
    
    write_json(output_dir / "graph.json", {"nodes": nodes, "edges": edges})
```

### 6. 搜索索引生成
```python
def generate_search_index(cards, output_dir):
    """生成 search-index.json 供 Lunr.js 加载"""
    documents = []
    for card in cards:
        documents.append({
            "id": card["relative_path"],
            "title": card["frontmatter"].get("title", ""),
            "domain": card["frontmatter"].get("domain", ""),
            "body": card["body"],
            "tags": " ".join(card["tags"]),
        })
    write_json(output_dir / "search-index.json", documents)
```

### 7. Lint 报告
```python
def generate_lint_report(cards, output_dir):
    """生成 lint-report.html"""
    issues = []
    
    for card in cards:
        # 孤立检测
        if len(card["links"]) == 0 and len(card["backlinks"]) == 0:
            issues.append({
                "card": card["relative_path"],
                "type": "orphan",
                "severity": "medium",
                "msg": "孤立卡片：无任何链接"
            })
        
        # 过期检测
        if card["frontmatter"].get("status") == "outdated":
            issues.append({
                "card": card["relative_path"],
                "type": "outdated",
                "severity": "low",
                "msg": "标记为过期"
            })
        
        # 低权威检测
        auth = card["frontmatter"].get("authority", 3)
        if auth < 2 and len(card["backlinks"]) > 3:
            issues.append({
                "card": card["relative_path"],
                "type": "low-authority",
                "severity": "high",
                "msg": f"权威度 {auth} 但被 {len(card['backlinks'])} 张卡片引用"
            })
    
    # 可能重复检测（标题相似度 > 0.8）
    duplicates = find_similar_titles(cards)
    for dup in duplicates:
        issues.append(dup)
    
    lint_html = lint_template.render(issues=issues, total=len(issues))
    write_file(output_dir / "lint-report.html", lint_html)
```

## HTML 模板结构

```html
<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8">
  <title>{{ title }} - {{ domain }}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="/assets/style.css">
</head>
<body>
  <nav class="breadcrumb">
    <a href="/index.html">目录</a>
    → <a href="/02-cards/{{ domain }}/">{{ domain }}</a>
  </nav>
  
  <main>
    <div class="meta-panel">
      <span class="domain">{{ domain }}</span>
      <span class="type">{{ type }}</span>
      <span class="status {{ status }}">{{ status }}</span>
      <span class="authority" title="权威度 {{ authority }}/5">
        {% for i in range(authority) %}★{% endfor %}
        {% for i in range(5 - authority) %}☆{% endfor %}
      </span>
      {% if source %}<span class="source">来源: {{ source }}</span>{% endif %}
      <time>更新于 {{ updated }}</time>
    </div>
    
    {{ body }}
    
    <section class="links-out">
      <h2>关联卡片</h2>
      <ul>
        {% for link in links_out %}
        <li><a href="{{ link.url }}">{{ link.title }}</a></li>
        {% endfor %}
      </ul>
    </section>
    
    <section class="links-in">
      <h2>被以下卡片引用</h2>
      <ul>
        {% for bl in backlinks %}
        <li><a href="{{ bl.from }}">{{ bl.from_title }}</a></li>
        {% endfor %}
      </ul>
    </section>
  </main>
  
  <script src="/assets/graph.js"></script>
</body>
</html>
```

## 使用命令

```bash
# 完整构建
python 08-system/build.py

# 仅构建变更内容
python 08-system/build.py --incremental

# 仅生成 Lint 报告
python 08-system/build.py --lint

# 生成后启动本地服务
python 08-system/build.py && python -m http.server 8080

# 监视模式（文件变更自动重建）
python 08-system/build.py --watch
```
