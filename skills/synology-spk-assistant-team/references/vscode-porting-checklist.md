# VS Code SPK移植检查清单 (vscode-porting-checklist.md)

这是专门为大型项目(如VS Code)设计的分阶段检查清单，帮助团队确保没有遗漏关键步骤。

## Phase 1: 可行性评估 (Feasibility) - 第1-3天

### 技术评估
- [ ] 分析vscode的代码规模 (行数、模块数)
- [ ] 确认GUI能否删除或改造为headless模式
- [ ] 列出所有外部依赖 (npm dependencies)
- [ ] 评估主要依赖的可获得性 (能否在spksrc找到或容易编译)
- [ ] 估算最终包大小 (目标<800MB)
- [ ] 评估内存占用 (运行时)

### 团队评估
- [ ] 确定项目复杂度评分 (1-5)
- [ ] 根据复杂度确定人员配置 (开发者数量, deadline)
- [ ] 确认架构师时间投入
- [ ] 确认QA测试环境准备时间

### 可行性检查清单
- [ ] 技术方案评估完成
- [ ] 风险清单已生成 (红旗项<5个)
- [ ] PM和stakeholders已同意方向
- [ ] **Gating**: 如果技术风险过高(>3个红旗), 重新评估或降低scope

**Deliverable**: 可行性评估报告 + 同意书

---

## Phase 2: 架构设计 (Architecture) - 第2-4周

### Headless改造设计
- [ ] 确定vscode的UI/GUI删除策略
- [ ] 设计基于HTTP API的server架构
- [ ] 定义client与server的通信协议 (WebSocket/HTTP)
- [ ] 确定是否保留插件系统
- [ ] 列出会被删除的功能 (GUI, debug deep features等)

### 依赖规划
- [ ] 列出所有npm dependencies (npm ls)
- [ ] 对每个依赖评估可编译性
  - 容易: 纯JavaScript或有现成编译配方
  - 中等: C/C++ binding, 可能需要调整编译选项
  - 困难: 特殊依赖，如GPU库、Windows-only等
- [ ] 确定是否需要自建某些依赖的spksrc recipes
- [ ] 建立依赖的优先级 (must-have vs nice-to-have)

### 模块分解设计
- [ ] 分解为可并行开发的模块
- [ ] 定义模块之间的依赖关系
- [ ] 明确每个模块的owner和deadline
- [ ] 识别关键路径 (哪些任务必须先完成)
- [ ] 估算每个模块的工作量 (hours)

### 构建规则设计
- [ ] 设计spk/vscode/Makefile结构
- [ ] 确定DEPENDS和BUILD_DEPENDS
- [ ] 规划patch strategy (对vscode源代码的修改)
- [ ] 设计multi-architecture构建规则

### 约束定义
- [ ] 明确支持的DSM版本 (7.2+)
- [ ] 明确支持的architecture (x64, ARM64, x86)
- [ ] 定义包大小目标 (<800MB)
- [ ] 定义运行时内存上限 (<200MB)
- [ ] 定义性能指标 (启动时间<10s)

### 架构评审
- [ ] 架构师与开发者深度review设计
- [ ] 所有开发者能理解整体设计吗? (5分钟elevator pitch test)
- [ ] 识别剩余的技术风险 (新增)

**Deliverable**: 完整的架构设计文档 + 分解任务清单

---

## Phase 3: 依赖编译基础设施 (Dependency Compilation) - 第3-6周

### Node.js runtime
- [ ] 为spksrc编写native/nodejs recipes
- [ ] 编译native版本 (macOS/Linux开发工具)
- [ ] 编译cross版本 (x64, ARM64, x86)
- [ ] 测试node和npm的可用性
- [ ] 包大小检查 (<150MB)

### 关键库编译
- [ ] 编译openssl (TLS/SSL)
- [ ] 编译zlib (压缩)
- [ ] 编译libffi (C binding)
- [ ] 编译python (某些build tools需要)

### Electron headless runtime (如果需要)
- [ ] 确定electron是否能改为headless模式
- [ ] 或改用纯Node.js + HTTP server
- [ ] 编译必要的graphics库 (Mesa等, 可选)

### NPM dependencies编译
- [ ] 为困难的npm modules写custom编译脚本
- [ ] 处理native modules (sqlite3, node-gyp等)
- [ ] 建立prebuilt binary缓存 (加快构建)

### 包大小优化
- [ ] 删除不必要的依赖 (dev dependencies)
- [ ] 压缩和strip二进制文件
- [ ] 删除源代码和文档
- [ ] 监控总包大小

**Gating**: 能否在所有三个架构(x64, ARM64, x86)成功编译? 如否，解决或降低scope。

**Deliverable**: 可工作的依赖编译框架 + 大小报告

---

## Phase 4: Headless改造 (Headless Transformation) - 第4-9周

### 移除GUI代码
- [ ] 删除或隔离Electron依赖
- [ ] 删除GTK/X11相关代码
- [ ] 删除WebGL/GPU相关代码
- [ ] 保留核心编辑引擎和语言支持

### Server架构实现
- [ ] 实现HTTP server (Express.js或类似)
- [ ] 实现WebSocket通信 (for real-time updates)
- [ ] 设计REST API接口
- [ ] 实现认证/授权

### 核心功能保留
- [ ] 文件编辑引擎 (正常工作)
- [ ] 代码语法高亮 (语言支持)
- [ ] 搜索和替换 (正常工作)
- [ ] 项目导航 (文件树)
- [ ] 插件系统 (VS Code extensions兼容)

### 删除或简化的功能
- [ ] 调试器 (复杂，可删除)
- [ ] Terminal集成 (可选)
- [ ] Source Control (Git集成, 可简化)
- [ ] 某些高级Language Server features

### 测试和验证
- [ ] 单元测试覆盖 (>=80%)
- [ ] 集成测试 (server + client通信)
- [ ] 性能测试 (启动时间, 内存占用)

**Deliverable**: 可工作的vscode headless server + API文档

---

## Phase 5: 核心功能实现 (Core Features) - 第6-14周 (并行)

### Feature 1: 文件编辑
- [ ] 创建/打开/保存文件 (✅)
- [ ] 编辑大文件 (>100MB)
- [ ] Undo/Redo
- [ ] 搜索和替换

### Feature 2: 代码语言支持
- [ ] JavaScript/TypeScript
- [ ] Python
- [ ] C/C++
- [ ] 其他常用语言 (根据priority)

### Feature 3: 项目管理
- [ ] 打开文件夹
- [ ] 文件树导航
- [ ] 快速打开文件 (Ctrl+P)
- [ ] 全局搜索

### Feature 4: 插件系统
- [ ] VS Code extension API兼容
- [ ] 插件加载和卸载
- [ ] 内置插件 (git, markdown等)

### Feature 5: 集成
- [ ] Git集成 (commit, push, pull)
- [ ] 构建工具集成 (npm scripts)
- [ ] Terminal集成 (运行命令)

### 性能和优化
- [ ] 启动时间<10秒
- [ ] 编辑响应<100ms
- [ ] 内存占用<200MB (empty project)
- [ ] 包大小<800MB

**Gating**: 核心功能是否可用? 性能是否可接受? 大小是否超标? 如有问题，优化或删减功能。

**Deliverable**: 功能完整的vscode headless server SPK

---

## Phase 6: 测试和发布 (Testing & Release) - 第15-20周

### 功能测试
- [ ] 所有5个feature正常工作
- [ ] 边界case测试 (大文件, 复杂项目等)
- [ ] 异常恢复测试 (崩溃后恢复)

### 多版本测试
- [ ] DSM 7.2 x64 ✅
- [ ] DSM 7.2 ARM64 ✅
- [ ] DSM 7.2 x86 ✅
- [ ] DSM 7.1 (可选)
- [ ] DSM 6.2 (不支持)

### 长期稳定性测试
- [ ] 24小时运行测试 (检查内存泄漏)
- [ ] 大量文件编辑测试
- [ ] 并发请求测试

### 文档完成
- [ ] 安装指南
- [ ] 用户使用指南
- [ ] API文档 (for plugin developers)
- [ ] 已知问题清单
- [ ] 更新日志

### 发布准备
- [ ] SPK包签名
- [ ] 元数据 (PLIST) 完整
- [ ] 版本号定义
- [ ] 发布说明

**Gating**: 所有关键测试通过? P0缺陷已修复? 文档完成? 如是，准备发布。

**Deliverable**: 可发布的SPK + 完整文档

---

## 关键风险点监控

### 红旗项 (必须跟踪)
- [ ] Headless改造成本超预期 (需要>8周)
- [ ] 核心依赖无法编译或需要大幅改造
- [ ] 包大小无法控制在1GB以下
- [ ] 性能无法满足DSM环境

### 黄旗项 (需要加强关注)
- [ ] 某个功能遇到平台限制 (无法在DSM sandbox内工作)
- [ ] 多架构支持困难
- [ ] 插件系统兼容性问题

---

## 核心成功指标 (KPI)

| 指标 | 目标 | 当前 | 状态 |
|------|------|------|------|
| 架构完整性 | 100% | | |
| 依赖编译成功率 | 95%+ | | |
| 包大小 | <800MB | | |
| 启动时间 | <10s | | |
| 内存占用 | <200MB | | |
| 测试覆盖 | >=80% | | |
| 多架构支持 | x64/ARM64/x86 | | |
| 文档完整性 | 100% | | |

---

**版本**: 1.0  
**最后更新**: 2026-05-16
