# 知识库当前盘点

> 路径：~/RAG | 自检时间：2026-05-19

## 卡片清单（10 张）

### 代码开发（2 张）

| 文件 | 标题 | 类型 | 权威 | 状态 |
|------|------|------|------|------|
| `02-cards/dev/事件驱动架构.md` | 事件驱动架构 | architecture | ★★★★☆ | evergreen |
| `02-cards/dev/pattern-observer.md` | 观察者模式 | pattern | ★★★★☆ | evergreen |

**链接拓扑：**
- 事件驱动架构 → 观察者模式 ⚠️, CQRS模式, 消息队列选型
- 观察者模式 → 策略模式对比, 发布订阅模式, 事件驱动架构 ✅
- 事件驱动架构 ← 观察者模式（✅ 有效入链）
- 事件驱动架构 → 观察者模式（❌ 断链：文件名 `pattern-observer.md` ≠ 链接slug `观察者模式`）

### 金融策略（2 张）

| 文件 | 标题 | 类型 | 权威 | 状态 |
|------|------|------|------|------|
| `02-cards/finance/动量策略-均线交叉.md` | 移动平均线交叉策略 | strategy | ★★★★☆ | evergreen |
| `02-cards/finance/风险控制-止损.md` | 风险控制：止损策略 | strategy | ★★★★★ | evergreen |

**链接拓扑：**
- 均线交叉 → 风险控制-止损 ✅, 技术指标-ADX过滤, 趋势跟踪vs均值回归
- 止损策略 → 动量策略-均线交叉 ✅, 仓位管理-凯利公式, 交易心理-恐惧管理

### 小说创作（1 张）

| 文件 | 标题 | 类型 | 权威 | 状态 |
|------|------|------|------|------|
| `02-cards/fiction/character-张三.md` | 张三 - 复仇的金融天才 | character | ★☆☆☆☆ | draft |

**链接拓扑：**
- 张三 → 李四-反派, 王五-导师, 交易心理-执念（全部未创建）
- 无入链

### Hermes（5 张）🆕

| 文件 | 标题 | 类型 | 权威 | 状态 |
|------|------|------|------|------|
| `02-cards/hermes/Hermes环境全貌.md` | Hermes Agent 环境全貌 | reference | ★★★★★ | evergreen |
| `02-cards/hermes/Profiles与飞书体系.md` | Hermes Profiles 与飞书体系 | reference | ★★★★★ | evergreen |
| `02-cards/hermes/工作流与工具链偏好.md` | 工作流与工具链偏好 | reference | ★★★★★ | evergreen |
| `02-cards/hermes/WorkBuddy桥接委派.md` | WorkBuddy 桥接委派 | reference | ★★★★★ | evergreen |
| `02-cards/hermes/ClaudeCode开发环境.md` | Claude Code 与开发环境 | reference | ★★★★★ | evergreen |

**链接拓扑：**
- Hermes环境全貌 → Profiles与飞书体系, WorkBuddy桥接委派, 工作流与工具链偏好
- Profiles与飞书体系 → Hermes环境全貌
- 工作流与工具链偏好 → Hermes环境全貌, Profiles与飞书体系, WorkBuddy桥接委派
- WorkBuddy桥接委派 → Hermes环境全貌, 工作流与工具链偏好
- ClaudeCode开发环境 → Hermes环境全貌, 工作流与工具链偏好, WorkBuddy桥接委派

## 孤悬链接（12 个）

| # | 孤悬目标 | 引用者 | 原因 |
|---|---------|--------|------|
| 1 | `观察者模式` | 事件驱动架构 | ⚠️ 命名不匹配（文件是 pattern-observer.md） |
| 2 | `CQRS模式` | 事件驱动架构 | 卡片未创建 |
| 3 | `消息队列选型` | 事件驱动架构 | 卡片未创建 |
| 4 | `策略模式对比` | 观察者模式 | 卡片未创建 |
| 5 | `发布订阅模式` | 观察者模式 | 卡片未创建 |
| 6 | `技术指标-ADX过滤` | 均线交叉 | 卡片未创建 |
| 7 | `趋势跟踪vs均值回归` | 均线交叉 | 卡片未创建 |
| 8 | `仓位管理-凯利公式` | 止损策略 | 卡片未创建 |
| 9 | `交易心理-恐惧管理` | 止损策略 | 卡片未创建 |
| 10 | `李四-反派` | 张三 | 卡片未创建 |
| 11 | `王五-导师` | 张三 | 卡片未创建 |
| 12 | `交易心理-执念` | 张三 | 卡片未创建 |

## 链接有效性

```
有效出链: 3 / 15
  ✅ 观察者模式 → 事件驱动架构
  ✅ 均线交叉 → 风险控制-止损
  ✅ 止损策略 → 动量策略-均线交叉

命名不匹配断链: 1
  ❌ 事件驱动架构 → 观察者模式 (文件 pattern-observer.md ≠ slug 观察者模式)

卡片未创建: 11
```

## 构建系统

- **脚本**：`~/RAG/08-system/build.py`（552 行，纯 Python）
- **Git 自动提交**：默认执行，`--no-commit` 跳过。不自动 push
- **Git 状态**：2 commits，无 remote

## 常用命令

```bash
python ~/RAG/08-system/build.py              # 完整构建
python ~/RAG/08-system/build.py --lint       # 仅健康检查
python ~/RAG/08-system/build.py --no-commit  # 构建不提交
cd ~/RAG && python -m http.server 8080 --bind 127.0.0.1      # 本地预览
```
