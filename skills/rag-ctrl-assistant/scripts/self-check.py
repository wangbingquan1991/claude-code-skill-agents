#!/usr/bin/env python3
"""知识库深度自检 — 覆盖 build.py lint 遗漏的检查项。

用法: python scripts/self-check.py [~/RAG]

检查项:
  1. 孤悬链接 — [[目标]] 的文件不存在（含命名不匹配导致的假孤悬）
  2. 孤立卡片 — 零出链且零入链
  3. 高权威缺来源 — authority >= 3 但无 source 字段
  4. 过期卡片 — status: outdated
  5. 健康度评分

输出: 终端表格 + 退出码（0=全部通过, 1=有问题）
"""
import re
import sys
from pathlib import Path


BASE = Path(sys.argv[1]).expanduser().resolve() if len(sys.argv) > 1 else Path.home() / "RAG"
CARDS_DIR = BASE / "02-cards"


def parse_card(path: Path):
    """解析卡片：返回 frontmatter dict + body"""
    text = path.read_text(encoding="utf-8")
    fm, body = {}, text
    if text.startswith("---"):
        parts = text.split("---", 2)
        if len(parts) >= 3:
            for line in parts[1].strip().split("\n"):
                if ":" in line:
                    k, _, v = line.partition(":")
                    fm[k.strip()] = v.strip().strip('"').strip("'")
            body = parts[2]
    return fm, body


def slugify(title: str) -> str:
    return title.lower().replace(" ", "-")


def main():
    md_files = list(CARDS_DIR.rglob("*.md"))
    if not md_files:
        print(f"❌ 未找到卡片文件于 {CARDS_DIR}")
        sys.exit(1)

    # ── 扫描所有卡片 ──
    all_stems = {}          # stem → relpath
    all_titles = {}         # stem → title
    out_links = {}          # stem → [link_slugs]
    fm_data = {}            # stem → frontmatter dict
    missing_source = []
    expired = []

    for f in md_files:
        fm, body = parse_card(f)
        stem = f.stem
        all_stems[stem] = f.relative_to(BASE)
        all_titles[stem] = fm.get("title", stem)
        fm_data[stem] = fm

        links = re.findall(r"\[\[([^\]]+)\]\]", body)
        out_links[stem] = [slugify(l) for l in links]

        auth = int(fm.get("authority", 3))
        if auth >= 3 and not fm.get("source"):
            missing_source.append(stem)
        if fm.get("status") == "outdated":
            expired.append(stem)

    total_cards = len(md_files)
    total_links = sum(len(v) for v in out_links.values())

    # ── 反链计算 ──
    in_links = {s: [] for s in all_stems}
    for stem, links in out_links.items():
        for link in links:
            if link in in_links:
                in_links[link].append(stem)

    # ── 1. 孤悬链接 ──
    orphaned = {}
    for stem, links in out_links.items():
        for link in links:
            if link not in all_stems:
                orphaned.setdefault(link, []).append(stem)

    # ── 2. 命名不匹配孤悬（文件名 ≠ slug(标题)）──
    naming_mismatch = {}
    for link_slug, refs in orphaned.items():
        for stem in all_stems:
            if slugify(all_titles.get(stem, stem)) == link_slug:
                naming_mismatch[link_slug] = (list(refs), stem)
                break

    # ── 3. 孤立卡片 ──
    orphans = [s for s in all_stems if not out_links.get(s) and not in_links.get(s)]

    # ── 有效链接统计 ──
    valid = sum(1 for links in out_links.values() for l in links if l in all_stems)

    # ── 输出 ──
    print(f"📄 卡片: {total_cards} 张    🔗 链接: {total_links} 出 / {valid} 有效")
    print()

    issues = 0

    # 孤悬链接
    print("🟡 孤悬链接（引用不存在的卡片）:")
    if orphaned:
        pure_orphaned = {k: v for k, v in orphaned.items() if k not in naming_mismatch}
        for link, refs in sorted(pure_orphaned.items()):
            print(f"   → {link}  ← 引用者: {', '.join(refs)}")
            issues += 1
        print(f"   共 {len(pure_orphaned)} 个（卡片未创建）")
    else:
        print("   ✅ 无")
    print()

    # 命名不匹配
    print("🔴 命名不匹配（文件名 ≠ slug(标题) 导致断链）:")
    if naming_mismatch:
        for link, (refs, actual_stem) in naming_mismatch.items():
            print(f"   → [[{link}]] ← {', '.join(refs)}")
            print(f"     实际文件: {actual_stem}.md（标题={all_titles[actual_stem]}）")
            print(f"     修复: git mv {actual_stem}.md {link}.md")
            issues += 1
    else:
        print("   ✅ 无")
    print()

    # 孤立卡片
    print("🔴 孤立卡片（零出链+零入链）:")
    if orphans:
        for o in orphans:
            print(f"   ⚠️ {all_stems[o]}")
            issues += 1
    else:
        print("   ✅ 无")
    print()

    # 缺来源
    print("🟡 高权威缺来源:")
    if missing_source:
        for m in missing_source:
            print(f"   ⚠️ {all_stems[m]}")
            issues += 1
    else:
        print("   ✅ 无")
    print()

    # 过期
    print("🔵 过期卡片:")
    if expired:
        for e in expired:
            print(f"   ⚠️ {all_stems[e]}")
            issues += 1
    else:
        print("   ✅ 无")
    print()

    # ── 健康度评分 ──
    score = 100
    pure = sum(1 for k, v in orphaned.items() if k not in naming_mismatch)
    if pure > 5: score -= 15
    elif pure > 0: score -= 5
    if naming_mismatch: score -= 10
    if missing_source: score -= 10
    if orphans: score -= 20

    bar = "🟢 健康" if score >= 90 else "🟡 关注" if score >= 70 else "🔴 需修复"
    print(f"━━━ 健康度: {score}/100  {bar} ━━━")
    print(f"(孤悬{pure} + 命名{len(naming_mismatch)} + 缺源{len(missing_source)} + 孤立{len(orphans)} + 过期{len(expired)})")

    sys.exit(1 if issues > 0 else 0)


if __name__ == "__main__":
    main()
