# 知识库自检脚本

用于分析 `~/RAG` 的链接健康状况，发现 build.py 内置 Lint 未覆盖的问题。

## 检测维度

| 维度 | 说明 | build.py 覆盖？ |
|------|------|----------------|
| 卡片总数 | 扫描 02-cards/ 下所有 .md | ✅ |
| 孤立卡片 | 零出链 + 零入链 | ✅ |
| 孤悬链接 | `[[目标]]` 指向不存在的文件 | ❌ 需此脚本 |
| 命名不匹配 | 文件名 slug ≠ 链接 slug | ❌ 需此脚本 |
| 高权威缺来源 | authority≥3 且无 source | ✅ |
| 过期卡片 | status: outdated | ✅ |
| 有效链接数 | 实际解析成功的出链 | ❌ 需此脚本 |

## 执行方式

在 Hermes 中使用 `execute_code` 运行，或直接在终端：

```bash
python3 << 'PYEOF'
import re
from pathlib import Path

cards_dir = Path.home() / 'RAG' / '02-cards'
md_files = list(cards_dir.rglob('*.md'))
all_stems = {f.stem.lower() for f in md_files}

out_links = {}
missing_source = []

for f in md_files:
    content = f.read_text()
    fm = {}
    body = content
    if content.startswith('---'):
        parts = content.split('---', 2)
        if len(parts) >= 3:
            for line in parts[1].strip().split('\n'):
                if ':' in line:
                    k, _, v = line.partition(':')
                    fm[k.strip()] = v.strip().strip('"').strip("'")
            body = parts[2]
    
    links = re.findall(r'\[\[([^\]]+)\]\]', body)
    out_links[f.stem] = links
    
    auth = int(fm.get('authority', 3))
    if auth >= 3 and not fm.get('source'):
        missing_source.append(f.stem)

# 反链
in_links = {stem: [] for stem in all_stems}
for stem, links in out_links.items():
    for link in links:
        target = link.lower().replace(' ', '-')
        if target in in_links:
            in_links[target].append(stem)

# 孤立卡片
orphans = [s for s in all_stems if len(out_links.get(s, [])) == 0 and len(in_links.get(s, [])) == 0]

# 孤悬链接
all_targets = set()
for links in out_links.values():
    for l in links:
        all_targets.add(l.lower().replace(' ', '-'))
orphaned_links = all_targets - all_stems

# 有效链接
valid = sum(1 for links in out_links.values() for l in links if l.lower().replace(' ', '-') in all_stems)
total = sum(len(links) for links in out_links.values())

print(f'卡片: {len(md_files)} 张')
print(f'有效链接: {valid}/{total}')
print(f'孤立卡片: {len(orphans)}')
print(f'孤悬链接: {len(orphaned_links)}')
print(f'缺来源: {len(missing_source)}')

if orphaned_links:
    print(f'\n孤悬详情:')
    for ol in sorted(orphaned_links):
        refs = [s for s, links in out_links.items() for l in links if l.lower().replace(' ', '-') == ol]
        print(f'  → {ol} （{", ".join(refs)}）')

score = 100
if len(orphaned_links) > 5: score -= 15
elif len(orphaned_links) > 0: score -= 5
if missing_source: score -= 10
if orphans: score -= 20
print(f'\n健康度: {score}/100')
PYEOF
```

## 输出示例

```
卡片: 5 张
有效链接: 3/15
孤立卡片: 0
孤悬链接: 12
缺来源: 0
健康度: 85/100
```
