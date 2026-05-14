---
# 核心文档索引
---

## 核心原则文档

```
/data/everything-claude-code/
├── RULES.md                    # 12 条核心规则
├── SOUL.md                     # 5 大核心原则
├── EVALUATION.md               # 评估框架
├── the-longform-guide.md       # 完整长指南
├── the-shortform-guide.md      # 简明指南
├── WORKING-CONTEXT.md          # 上下文管理
├── SECURITY.md                 # 安全防护
└── TROUBLESHOOTING.md          # 故障排除
```

## Skill 开发资源

```
/data/skills/
├── spec/
│   └── agent-skills-spec.md    # Skill 规范
├── template/
│   └── SKILL.md                # Skill 模板
└── skills/                     # 18 个内置 Skill
    ├── skill-creator/SKILL.md  # Skill 创建器
    ├── claude-api/SKILL.md     # Claude API 集成
    └── auto-skill-optimizer/SKILL.md  # Skill 自动优化器
```

## Agent 设计资源

```
/data/everything-claude-code/agents/  # 数十个预定义 Agent
├── code-reviewer.md           # 代码审查专家
├── architect.md               # 架构设计专家
├── security-reviewer.md       # 安全审查专家
├── planner.md                 # 实现计划专家
├── tdd-guide.md               # 测试驱动开发专家
└── build-error-resolver.md    # 构建错误解决专家
```

## 最佳实践与示例

```
/data/claude-code-best-practice/
└── CLAUDE.md                  # 最佳实践集合

/data/claude-cookbooks/
└── CLAUDE.md                  # 官方烹饪书
```

## Skill 开发检查清单

- [ ] Description 足够 Pushy，明确列出所有触发场景
- [ ] 包含明确的跳过条件（SKIP 子句）
- [ ] 遵循 Progressive Disclosure（主体 <500 行）
- [ ] 心智模型 3-7 个，每个都有正反示例和局限性
- [ ] 有明确的工作流步骤化描述
- [ ] 触发优化：20 个评估查询，触发率 >90%
- [ ] 过 skill-creator 和 auto-skill-optimizer 双精炼
- [ ] 诚实边界 section 清晰列局限性

## Agent 设计检查清单

- [ ] Frontmatter 4 个字段完整（name/description/tools/model）
- [ ] Description 明确说明调用时机（什么时候用这个 Agent）
- [ ] 工具遵循最小授权原则（只读任务不给 Write/Edit）
- [ ] 模型匹配任务复杂度（架构用 Opus，审查用 Sonnet）
- [ ] 包含 6 条 Prompt Defense Baseline
- [ ] 思维框架结构化（门限过滤、检查表、严重性分级）
- [ ] 输出格式标准化，结果可复用
- [ ] 误阳性排除机制，避免噪音
