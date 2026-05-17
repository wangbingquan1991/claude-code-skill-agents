# 群晖SPK开发助手团队 Skill 说明

欢迎使用 **群晖SPK开发助手团队** Skill！

这是一个完整的团队协作框架，帮助你快速上手SPK开发，特别是处理大型开源项目（如vscode、Siyuan Notes）的移植。

## 📋 快速导航

### 核心文档 (必读)
- **[SKILL.md](./SKILL.md)** - 团队协作的整体框架、5-phase工作流、决策启发式
- **[AGENTS.md](./AGENTS.md)** - 5个Agent角色的详细定义（PM、架构师、开发者、QA、可选角色）

### 角色参考文档
- **[role-pm.md](./references/role-pm.md)** - 项目经理的日常工作流、进度管理
- **[role-architect.md](./references/role-architect.md)** - 架构师的可行性评估、系统设计
- **[role-developer.md](./references/role-developer.md)** - 开发者的编码规范、工作流程
- **[role-qa.md](./references/role-qa.md)** - QA工程师的测试策略、多架构验证

### 工具和指南
- **[environment-setup.md](./references/environment-setup.md)** - 开发环境初始化（Docker、OrbStack、Git）
- **[toolkit-spksrc-guide.md](./references/toolkit-spksrc-guide.md)** - spksrc工具链完整参考
- **[vscode-porting-checklist.md](./references/vscode-porting-checklist.md)** - 大型项目移植的分阶段检查清单
- **[faq-troubleshooting.md](./references/faq-troubleshooting.md)** - 常见问题和故障排查

### 自动化脚本
- **[scripts/init-workspace.sh](./scripts/init-workspace.sh)** - 初始化开发环境（一键设置）
- **[scripts/setup-orbstack-vm.sh](./scripts/setup-orbstack-vm.sh)** - macOS OrbStack初始化
- **[scripts/build-all-archs.sh](./scripts/build-all-archs.sh)** - 多架构并行构建（x64/ARM64/x86）
- **[scripts/validate-spk-package.sh](./scripts/validate-spk-package.sh)** - SPK包质量检查

## 🚀 快速开始

### 第一步：环境准备 (第一天)
```bash
# 1. 如果用macOS，先安装OrbStack
brew install orbstack

# 2. 初始化workspace
bash scripts/init-workspace.sh

# 3. 进入project目录
cd ~/synology-spk-workspace/projects
```

### 第二步：启动项目 (第二天)
```bash
# 1. Clone项目repo
git clone <your-project-repo>
cd my-spk-project

# 2. 初始化Git和spksrc
git submodule update --init --recursive

# 3. 启动Docker容器
docker run -it -v $(pwd):/workspace ghcr.io/synocommunity/spksrc:latest bash

# 4. 在容器内首次构建
cd /workspace
make setup
make arch-x64  # 构建x64架构

# 5. 验证输出
ls packages/*.spk  # 应该看到输出的SPK文件
```

### 第三步：使用本框架

#### 如果你是项目经理:
1. 读 [SKILL.md](./SKILL.md) 的"项目启动"部分
2. 参考 [role-pm.md](./references/role-pm.md) 建立日常工作流
3. 使用 [vscode-porting-checklist.md](./references/vscode-porting-checklist.md) 的可行性评估部分

#### 如果你是高级架构师:
1. 读 [AGENTS.md](./AGENTS.md) 的"synology-spk-architect"部分
2. 参考 [role-architect.md](./references/role-architect.md) 的可行性评估和系统分解
3. 用 [vscode-porting-checklist.md](./references/vscode-porting-checklist.md) 为大型项目规划

#### 如果你是开发者:
1. 读 [environment-setup.md](./references/environment-setup.md) 搭建环境
2. 参考 [role-developer.md](./references/role-developer.md) 的编码规范和工作流
3. 查看 [toolkit-spksrc-guide.md](./references/toolkit-spksrc-guide.md) 学习spksrc工具链
4. 遇到问题查 [faq-troubleshooting.md](./references/faq-troubleshooting.md)

#### 如果你是QA工程师:
1. 读 [role-qa.md](./references/role-qa.md) 的测试矩阵和工作流
2. 用 [scripts/validate-spk-package.sh](./scripts/validate-spk-package.sh) 检查SPK包质量

## 📊 项目规模和团队配置

根据项目复杂度，推荐的团队配置:

| 复杂度 | 例子 | 时间 | 人员 | 关键资源 |
|--------|------|------|------|---------|
| 1-2分 | 简单CLI工具 | 4-8周 | PM + 1开发者 | 架构师可选 |
| 3分 | 中等应用 | 8-12周 | PM + 架构师 + 2-3开发者 + QA | toolkit-spksrc-guide |
| 4-5分 | vscode这样的大型项目 | 12-20周 | PM + 架构师 + 3-5开发者 + QA + DevOps | 全套文档 + 自动化脚本 |

## 🎯 核心工作流 (5-Phase Model)

1. **启动** (1-2周): PM + 架构师评估可行性
2. **设计** (2-4周): 架构师分解系统，定义约束
3. **开发** (4-12周): 开发者并行编码，PM协调进度
4. **测试** (2-4周): QA多维测试（多DSM版本、多架构）
5. **发布** (1-2周): 构建、签名、上传

每个阶段都有清晰的Gate和完成条件，见 [SKILL.md](./SKILL.md)。

## ⚠️ 关键风险点 (必须监控)

- **Headless改造成本**: 大型GUI应用的改造可能需要8-10周
- **包大小超限**: 大型项目常见，需要提前规划优化
- **多架构支持**: 最少支持x64 + ARM64，否则失去大部分用户
- **依赖编译失败**: 复杂依赖树可能有无法编译的包

都在 [SKILL.md](./SKILL.md) 的"决策启发式"部分有详细说明。

## 📚 常见问题

### Q: 我是单独开发者，需要用这个框架吗？
**A**: 可以。框架中很多东西可以简化（如不需要PM角色），但**架构师角色**仍然重要（即使是你自己兼任）。

### Q: 我的项目很小，只需要几周完成
**A**: 快速扫一遍 [SKILL.md](./SKILL.md) 的"决策启发式"，确定你的复杂度评分，然后选择相关部分。

### Q: 我们已经有CI/CD流程了，需要改吗？
**A**: 不需要。本框架与现有CI/CD兼容，脚本只是参考实现。

### Q: 我的团队使用Jira而不是GitHub Issues
**A**: 完全兼容。所有工作流的本质都是一样的，工具只是记录而已。

## 🔗 外部资源

- **spksrc官方**: https://github.com/SynoCommunity/spksrc/wiki
- **SPK工具链**: https://github.com/SynologyOpenSource/pkgscripts-ng
- **社区SPK项目**: https://github.com/SynoCommunity/spksrc/tree/master/spk

## 📝 版本信息

- **Skill版本**: 1.0.0
- **最后更新**: 2026-05-16
- **支持的DSM版本**: DSM 7.x (主要), DSM 6.x (可选)
- **支持的架构**: x64, ARM64, x86, ARM32

## ✉️ 反馈和改进

如果你有改进建议或发现问题：

1. 检查 [faq-troubleshooting.md](./references/faq-troubleshooting.md) 是否有现成解答
2. 提交Issue到项目repo
3. 分享你的经验和最佳实践

---

**祝你的SPK项目顺利！** 🎉

需要帮助？从 [SKILL.md](./SKILL.md) 开始，或根据你的角色选择相应的参考文档。
