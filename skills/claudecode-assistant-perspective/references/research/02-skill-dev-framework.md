---
# 02 - Skill 开发框架
---

## 一、Skill 标准结构规范

### 1.1 文件系统结构

**必选文件：**
- `SKILL.md` - 核心指令文件，包含 YAML frontmatter 和 Markdown 内容

**可选资源目录：**
- `scripts/` - 可执行代码，用于确定性或重复性任务
- `references/` - 文档，按需加载到上下文中
- `assets/` - 输出中使用的文件（模板、图标、字体）
- `evals/` - 测试用例和评估数据
- `agents/` - 子代理指令

**多领域组织模式：**
当 Skill 支持多个领域/框架时，按变体组织：
```
skill-name/
├── SKILL.md (工作流 + 选择逻辑)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
Claude 只会读取相关的参考文件。

### 1.2 SKILL.md Frontmatter 规范

**必填字段：**
- `name` - Skill 标识符（短横线命名）
- `description` - 触发条件和功能描述（核心触发机制）

**可选字段：**
- `license` - 许可证信息
- `compatibility` - 所需工具、依赖项

**描述字段最佳实践（Pushy Description 模式）：**
描述是 Skill 触发的主要机制，应包含：
1. Skill 做什么
2. 具体的使用场景（用户可能说的话）
3. 触发条件的明确枚举
4. 跳过条件的明确枚举

**好的描述示例（来自 claude-api Skill）：**
```yaml
description: "Build, debug, and optimize Claude API / Anthropic SDK apps. Apps built with this skill should include prompt caching. Also handles migrating existing Claude API code between Claude model versions (4.5 → 4.6, 4.6 → 4.7, retired-model replacements). TRIGGER when: code imports `anthropic`/`@anthropic-ai/sdk`; user asks for the Claude API, Anthropic SDK, or Managed Agents; user adds/modifies/tunes a Claude feature (caching, thinking, compaction, tool use, batch, files, citations, memory) or model (Opus/Sonnet/Haiku) in a file; questions about prompt caching / cache hit rate in an Anthropic SDK project. SKIP: file imports `openai`/other-provider SDK, filename like `*-openai.py`/`*-generic.py`, provider-neutral code, general programming/ML."
```

### 1.3 Progressive Disclosure 三级加载原则

Skill 使用三级加载系统，确保上下文效率：

| 级别 | 内容 | 加载时机 | 大小建议 |
|-----|------|---------|---------|
| **Level 1** | name + description | 始终在上下文中 | ~100 词 |
| **Level 2** | SKILL.md 正文 | Skill 触发时加载 | < 500 行 |
| **Level 3** | 捆绑资源（scripts/references/assets） | 按需读取/执行 | 无限制 |

**关键模式：**
- 保持 SKILL.md 在 500 行以下；接近上限时，增加层级结构并明确指引
- 从 SKILL.md 清晰引用外部文件，并说明何时读取
- 大型参考文件（> 300 行）应包含目录

### 1.4 内容组织最佳实践

**写作原则：**
1. **解释 "为什么"** - 尽量解释要求背后的原因，而不是生硬的 MUST/NEVER
2. **使用祈使语气** - 指令中优先使用祈使形式
3. **避免过度拟合** - 从具体反馈中泛化，不要针对单个案例添加过于具体的规则
4. **保持精简** - 移除不起作用的内容，阅读完整的转录本而不仅仅是最终输出

**内容模式：**
- **定义输出格式** - 使用 "ALWAYS use this exact template:" 形式
- **示例模式** - 包含输入输出对，使用具体例子说明
- **子命令表** - 支持 `/skill-name <subcommand>` 形式的直接调用
- **阅读指南** - 明确告诉模型在不同场景下应该读取哪些文件

**无意外原则：**
- Skill 不得包含恶意代码、利用代码或任何可能危及系统安全的内容
- Skill 的内容在描述时不应让用户对其意图感到意外

---

## 二、触发条件设计方法论

### 2.1 Pushy Description 模式

由于 Claude 倾向于"少触发" Skill（即使有用也不使用），描述应该稍微"强势"一些：

**不好的描述：**
> "How to build a simple fast dashboard to display internal Anthropic data."

**好的描述（Pushy 模式）：**
> "How to build a simple fast dashboard to display internal Anthropic data. Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of company data, even if they don't explicitly ask for a 'dashboard'."

### 2.2 触发/跳过条件枚举模式

在描述中明确使用 `TRIGGER when:` 和 `SKIP:` 关键字，列出具体的条件：

**TRIGGER when 应包含：**
- 代码特征（import 语句、文件名模式）
- 用户关键词（功能名称、技术术语）
- 操作类型（修改、优化、调试）
- 上下文信号（项目类型、文件位置）

**SKIP 应包含：**
- 明确的不触发场景
- 与其他 Skill 的边界
- 通用请求的排除条件

### 2.3 关键词覆盖策略

对于 should-trigger 查询（8-10 个），考虑覆盖度：
- 同一意图的不同表述（正式、随意）
- 用户不明确命名 Skill 或文件类型但明显需要的情况
- 不常见的用例
- 与其他 Skill 竞争但应胜出的情况

对于 should-not-trigger 查询（8-10 个）：
- 最有价值的是"近失"案例——共享关键词或概念但实际需要不同的东西
- 相邻领域、模糊表述
- 查询触及 Skill 做的事情但在另一个工具更合适的上下文中

**避免：** 明显不相关的负例（如用"写斐波那契函数"测试 PDF Skill），这没有测试任何东西。负例应该是真正棘手的。

### 2.4 自动化优化循环步骤

**Step 1: 生成触发评估查询**
- 创建 20 个评估查询——should-trigger 和 should-not-trigger 的混合
- 查询必须是现实的、Claude 用户实际会输入的内容
- 具体而非抽象，包含细节（文件路径、工作背景、列名、公司名、URL）
- 混合不同长度，关注边缘情况而不是明确的情况
- 包含小写、缩写、拼写错误、口语化表达

**Step 2: 用户审查**
- 使用 HTML 模板展示评估集供用户审查
- 用户可以编辑查询、切换 should-trigger、添加/删除条目
- 这一步很重要——差的评估查询会导致差的描述

**Step 3: 运行优化循环**
- 将评估集分为 60% 训练集和 40% 保留测试集
- 评估当前描述（每个查询运行 3 次以获得可靠的触发率）
- 调用 Claude 根据失败案例提出改进
- 在训练集和测试集上重新评估每个新描述
- 最多迭代 5 次
- 通过测试分数选择最佳描述，避免过拟合

**Step 4: 应用结果**
- 从 JSON 输出中获取 best_description
- 更新 Skill 的 SKILL.md frontmatter
- 向用户展示前后对比并报告分数

---

## 三、好 Skill vs 坏 Skill 对比表

| 维度 | 好 Skill 特征 | 坏 Skill 特征 |
|-----|-------------|-------------|
| **描述设计** | - Pushy 模式，主动推荐使用<br>- 明确 TRIGGER/SKIP 条件<br>- 包含具体用户短语和代码特征<br>- 覆盖边缘用例<br>- 与其他 Skill 有清晰边界 | - 被动、过于简洁<br>- 只有功能描述，没有触发场景<br>- 抽象模糊，不具体<br>- 边界模糊，与其他 Skill 重叠<br>- 没有跳过条件 |
| **内容组织** | - < 500 行，分层清晰<br>- Progressive Disclosure 三级加载<br>- 有明确的阅读指南<br>- 参考文件按需加载<br>- 解释"为什么"，而不仅仅是"做什么" | - 过长，一次性加载所有内容<br>- 没有分层，扁平化<br>- 没有指引模型何时读什么<br>- 所有内容都塞进 SKILL.md<br>- 大量 ALL CAPS 的 MUST/NEVER |
| **可测试性** | - 有 2-3 个真实测试用例<br>- 断言客观可验证<br>- 有基线对比（无 Skill / 旧版本）<br>- 覆盖常见和边缘场景<br>- 评估流程自动化 | - 没有测试用例<br>- 断言主观模糊<br>- 没有对比基准<br>- 只测试最明显的情况<br>- 完全依赖人工主观判断 |
| **安全设计** | - 无意外原则<br>- 明确的权限边界<br>- 不对抗系统保护机制<br>- 用户输入验证说明<br>- 错误处理指导 | - 包含恶意或利用代码<br>- 意图与描述不符<br>- 试图绕过安全限制<br>- 不验证输入<br>- 静默吞掉错误 |
| **资源利用** | - 重复工作提取到 scripts/<br>- 大型文档放在 references/<br>- 模板资源放在 assets/<br>- 脚本一次编写，所有调用复用 | - 每个调用都重新发明轮子<br>- 所有内容都在 SKILL.md 里<br>- 没有可复用的脚本<br>- 跨测试用例重复相同工作 |
| **迭代优化** | - 有量化的改进循环<br>- 用户反馈驱动迭代<br>- 避免过拟合单个案例<br>- 每次迭代都有基准对比<br>- 描述自动化优化 | - 一次性写完不再改进<br>- 凭直觉修改，没有数据<br>- 针对单个反馈过度特化<br>- 没有前后对比<br>- 描述从不优化 |
| **写作风格** | - 使用祈使语气<br>- 解释背后的原理<br>- 使用心智模型和比喻<br>- 灵活而非僵化<br>- 给模型留出智能发挥空间 | - 命令式、生硬<br>- 只说做什么不说为什么<br>- 过于具体的步骤枚举<br>- 僵化的 MUST/NEVER 规则<br>- 把模型当傻瓜，不信任其推理能力 |

---

## 四、Skill 开发检查清单

### 阶段 1: 需求捕获 ✅

- [ ] 明确 Skill 应该做什么
- [ ] 列出 3-5 个典型用户短语（何时触发）
- [ ] 定义预期输出格式
- [ ] 判断是否需要测试用例（客观输出需要，主观输出不需要）
- [ ] 识别边界条件和特殊情况
- [ ] 检查是否已有类似 Skill（避免重复）
- [ ] 确认与其他 Skill 的边界

### 阶段 2: 设计与草稿 ✅

- [ ] SKILL.md frontmatter 包含 name 和 description
- [ ] description 使用 Pushy 模式
- [ ] description 包含 TRIGGER when 和 SKIP 条件
- [ ] SKILL.md 正文 < 500 行
- [ ] 使用了 Progressive Disclosure 分层
- [ ] 大型参考文件有目录
- [ ] 解释了指令背后的"为什么"
- [ ] 没有 ALL CAPS 的过度 MUST/NEVER
- [ ] 输出格式有明确模板
- [ ] 包含输入输出示例
- [ ] 重复工作已提取到 scripts/
- [ ] 符合无意外原则

### 阶段 3: 测试用例设计 ✅

- [ ] 创建了 2-3 个现实的测试提示
- [ ] 测试用例是用户实际会说的话
- [ ] 包含边缘情况
- [ ] 断言是客观可验证的
- [ ] 保存到 evals/evals.json
- [ ] 设计了基线对比（无 Skill / 旧版本）

### 阶段 4: 运行与评估 ✅

- [ ] 所有测试用例并行运行（with-skill + baseline）
- [ ] 结果组织在 iteration-N/ 目录
- [ ] 每个测试用例有独立目录
- [ ] 捕获了 timing 数据（tokens + duration）
- [ ] 运行了定量断言评估
- [ ] 生成了 benchmark.json
- [ ] 启动了 eval viewer 供用户审查
- [ ] 在 Cowork 环境使用了 --static 模式

### 阶段 5: 迭代优化 ✅

- [ ] 阅读了用户的 feedback.json
- [ ] 从反馈中泛化，而不是过拟合
- [ ] 移除了不必要的内容
- [ ] 改进了指令解释
- [ ] 提取了新发现的重复工作
- [ ] 重新运行所有测试到新 iteration 目录
- [ ] 对比了前后结果
- [ ] 直到用户满意或没有实质进展才停止

### 阶段 6: 描述优化 ✅

- [ ] 生成了 20 个触发评估查询
- [ ] 8-10 个 should-trigger（不同表述覆盖）
- [ ] 8-10 个 should-not-trigger（真正棘手的近失）
- [ ] 查询是具体现实的（有细节、背景、口语化）
- [ ] 用户审查并调整了评估集
- [ ] 运行了自动化优化循环（最多 5 次）
- [ ] 使用测试分数选择最佳描述（避免过拟合）
- [ ] 更新了 SKILL.md frontmatter
- [ ] 向用户展示了前后对比和分数

### 阶段 7: 打包与交付 ✅

- [ ] 运行了 package_skill.py
- [ ] 生成了 .skill 文件
- [ ] 告知用户安装路径
- [ ] 文档记录了使用方法

---

## 五、评估查询集设计指南

### 5.1 查询质量标准

**好的查询特征：**
- ✅ 具体而现实 - 像真实用户会输入的
- ✅ 包含细节 - 文件路径、列名、上下文背景
- ✅ 有一定故事性 - "我的老板刚发我这个文件..."
- ✅ 口语化表达 - 小写、缩写、拼写错误
- ✅ 混合不同长度
- ✅ 关注边缘情况而非明确情况

**不好的查询（避免）：**
- ❌ 过于抽象 - "格式化数据"
- ❌ 过于简单 - "从 PDF 提取文本"
- ❌ 明显不相关的负例 - "写斐波那契函数"（测试 PDF Skill）

### 5.2 Should-Trigger 查询设计（8-10 个）

**覆盖维度：**
1. **不同表述** - 正式、随意、口语化
2. **隐式需求** - 用户不明确命名 Skill 但明显需要
3. **不常见用例** - 边缘但有效的使用场景
4. **竞争边界** - 与其他 Skill 竞争但应胜出的情况
5. **代码触发** - import 语句、文件名模式
6. **关键词变化** - 同义词、相关术语

### 5.3 Should-Not-Trigger 查询设计（8-10 个）

**最有价值的是"近失"案例：**
1. **相邻领域** - 共享关键词但属于不同领域
2. **模糊表述** - 天真的关键词匹配会触发但不应该
3. **上下文错位** - 查询触及 Skill 功能但另一个工具更合适
4. **部分重叠** - 只需要 Skill 的一小部分功能，基础工具足够
5. **泛化请求** - 太通用，不触发任何特定 Skill

**关键原则：** 负例应该是真正棘手的，不是明显不相关的。

### 5.4 查询示例对比

**不好的查询：**
```json
{"query": "Extract text from PDF", "should_trigger": true}
{"query": "Write a function", "should_trigger": false}
```

**好的查询：**
```json
{
  "query": "ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column that shows the profit margin as a percentage. The revenue is in column C and costs are in column D i think",
  "should_trigger": true
},
{
  "query": "I need to parse these server logs to find error rates. They're in JSON format, each line has a timestamp, level, and message field. Can you help me write a script that counts ERROR and WARNING entries per hour?",
  "should_trigger": false
}
```

---

## 六、来源引用清单

本框架提炼自以下文档：

1. **Agent Skills Specification** - https://agentskills.io/specification
   - Skill 标准格式和结构规范

2. **skill-creator Skill** - `/Users/wangbingquan/GitHubRepos/ClaudeCodeAssistant/data/skills/skills/skill-creator/SKILL.md`
   - Skill 开发完整工作流
   - Progressive Disclosure 三级加载原则
   - Pushy Description 模式
   - 触发条件自动化优化循环
   - 测试与评估方法论
   - 迭代改进最佳实践

3. **claude-api Skill** - `/Users/wangbingquan/GitHubRepos/ClaudeCodeAssistant/data/skills/skills/claude-api/SKILL.md`
   - 优秀 Skill 描述示例
   - TRIGGER when / SKIP 条件模式
   - 子命令表设计
   - 阅读指南组织方式
   - 多语言分层参考模式

4. **Skill Template** - `/Users/wangbingquan/GitHubRepos/ClaudeCodeAssistant/data/skills/template/SKILL.md`
   - 基础 SKILL.md 模板结构
