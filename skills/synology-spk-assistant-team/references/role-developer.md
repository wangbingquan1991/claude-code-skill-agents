# 开发者编码规范 (role-developer.md)

## 开发者的职责

L1开发者: 按照架构设计编码，完成分配的功能模块  
L2开发者: 处理复杂依赖、系统集成、性能优化，提出架构改进建议

## 开发环境搭建

### 前置条件
- macOS用户: 安装OrbStack，执行 `scripts/setup-orbstack-vm.sh`
- Linux用户: 直接Docker，执行 `scripts/init-workspace.sh`
- 获得项目repo的访问权限 (Git SSH key配置)

### 本地构建验证
```bash
# 初始化workspace
cd ~/synology-spk-workspace
git clone <项目repo>
cd <项目>

# 拉取spksrc框架(如果项目没包含)
git submodule add https://github.com/SynoCommunity/spksrc.git spksrc

# 本地构建(x64架构)
cd spksrc
make setup
make arch-x64

# 构建输出在 packages/ 目录
ls packages/
```

## 编码工作流

### 1️⃣ 接收任务

架构师分配具体任务，包含：
- 任务名称和描述
- 输出物(代码、配置、脚本)
- 接受标准(定量):
  ```
  ✅ 能在x64/ARM64上构建成功
  ✅ 单元测试覆盖>=80%
  ✅ 符合项目编码规范
  ✅ PR中包含test case和文档更新
  ```
- Deadline

如果接受标准不清楚，立即问架构师，而不是自己猜。

### 2️⃣ 创建feature分支
```bash
git checkout main
git pull
git checkout -b feature/<task-name>

# 例子
git checkout -b feature/headless-server-api
```

### 3️⃣ 编码和本地测试

**编码原则**：
- **可读性优先**：清晰的变量名、简洁的函数、有意义的注释
- **错误处理**：每个可能失败的操作都要处理错误，不要忽视return code
- **日志记录**：添加debug日志，方便后期排查问题
- **不重复**：如果你写的代码和已有的代码有重复，重构成共享函数

**单元测试**：
```bash
# 写测试用例
# 对关键函数的输入输出进行测试
# 覆盖normal case和edge case

# 运行测试，确保通过
pytest test_xxx.py  # Python项目例子
npm test            # Node.js项目例子
```

**本地构建验证**：
```bash
# 在feature分支上构建
make arch-x64

# 构建不成功 → 修改代码 → 再构建
# 反复直到构建成功

# 如果本地构建成功了，下一步才是commit和push
```

### 4️⃣ 代码审查前检查

推送PR前，自己做一遍code review，问自己：
- ✅ 代码符合架构设计吗？(有没有自作聪明改架构？)
- ✅ 编码规范(命名、缩进、注释)对吗？
- ✅ 有没有console.log之类的debug代码没删？
- ✅ 有没有hardcoded的密钥、路径等？
- ✅ 测试覆盖了核心逻辑吗？
- ✅ 有没有遗留的merge conflict标记？

### 5️⃣ 提交PR (Pull Request)

```bash
# 提交前确保分支是最新的
git fetch origin
git rebase origin/main

# 推送到远程
git push origin feature/<task-name>

# 在GitHub/GitLab上创建PR，填写PR描述：
```

**PR模板** (例子):
```markdown
## 描述
[简单描述这个PR做了什么]

## 相关任务
Closes #123  (关联的issue)

## 测试
[描述你做的测试]
- [ ] 在x64本地构建成功
- [ ] 在ARM64上交叉编译成功
- [ ] 单元测试全部通过
- [ ] 手动测试了核心功能

## 检查清单
- [ ] 代码符合架构设计
- [ ] 没有debug代码遗留
- [ ] 单元测试覆盖>=80%
- [ ] 更新了相关文档
```

**PR被review后的回复**：
- reviewer的建议 → 有意见就改，没意见就approve
- 改完代码后，不要rebase (保持commit history清晰)
- 通知reviewer "已按建议修改，请re-review"

### 6️⃣ Merge and Deploy

PR review通过后，架构师或PM负责merge到main分支。

Merge后：
- CI自动触发，构建所有架构
- 构建成功后，artifact自动上传
- 如果构建失败，PM通知你修复

## 遇到问题的处理流程

### 🚨 编译错误
```
错误信息 → Google + 相关文档 → 问其他开发者 → 问L2开发者 → 问架构师

如果超过4小时还没解决 → 立即上报给PM
```

### 🚨 架构问题
```
发现自己的代码与架构设计有出入
→ 立即停止编码
→ 与架构师讨论 (可能是理解错误，也可能是设计有问题)
→ 决策: 改代码 vs 改设计
```

### 🚨 依赖问题
```
某个依赖无法编译或找不到
→ 问L2开发者或DevOps
→ 尝试: 用spksrc现有的包 → 编译源码 → 找workaround
```

## 编码规范

### 目录结构
```
<project>/
├── src/              # 源代码
├── spk/              # SPK打包脚本
├── cross/            # spksrc构建规则
├── test/             # 测试代码
├── doc/              # 文档
├── .gitignore        # Git忽略文件
├── Makefile          # 项目构建文件
└── README.md         # 项目说明
```

### 命名规范
- 文件名: 小写+下划线 (module_name.py, server_api.c)
- 函数/方法: camelCase或snake_case (与语言惯例一致)
- 变量: snake_case (my_variable)
- 常量: UPPER_CASE (MAX_RETRIES)
- 不要用单个字母作变量名 (除非是loop counter i/j/k)

### 注释规范
```
# 好的注释
# 处理用户认证，返回token或错误信息
def authenticate_user(username, password):
    ...

# 不好的注释
# 这是authenticate_user函数
def authenticate_user(username, password):
    ...
```

### 错误处理
```javascript
// ❌ 不要忽视错误
const result = buildSPK();

// ✅ 一定要处理
const result = buildSPK();
if (!result.success) {
  console.error("Build failed:", result.error);
  process.exit(1);
}
```

## 测试规范

### 单元测试覆盖
- 关键业务逻辑: >=80% 代码覆盖
- 边界case: 必须测 (空值、超大值、异常情况)
- 例子:
  ```python
  def parse_config(config_str):
      # 测试正常case
      assert parse_config('key=value') == {'key': 'value'}
      
      # 测试边界case
      assert parse_config('') == {}  # 空字符串
      assert parse_config('invalid') == None  # 无效格式
  ```

### 集成测试
- 整个SPK包构建 (各架构)
- 跨模块的接口测试
- DSM兼容性测试(QA负责)

## 多架构开发的注意事项

SPK需要支持x64/ARM64/x86等多个架构。作为开发者，你需要意识到：

1. **架构差异**：
   - 寄存器大小: int64 vs int32
   - 字节序: little-endian vs big-endian (罕见)
   - 浮点精度

2. **交叉编译技巧**：
   - 使用 `-march=generic` 避免CPU特定的优化
   - 不要假设特定的库路径
   - 测试多个架构 (最少x64 + ARM64)

3. **本地只能构建一个架构**，其他架构交给CI验证

## 性能优化

如果架构师定义了性能目标 (如包大小<500MB)，你需要：

1. **包大小优化**：
   ```bash
   # 检查包大小
   ls -lh packages/*.spk
   
   # 如果太大，检查包含了什么
   file packages/*.spk  # 查看文件类型
   
   # 删除不必要的文件 (docs, examples等)
   ```

2. **运行时性能**：
   - 启动时间: 测试从启动到就绪的时间
   - 内存占用: 监控RSS内存
   - CPU使用: 避免busy-wait或polling

## L2开发者的额外职责

L2开发者处理更复杂的任务：

1. **依赖编译**：
   - 为spksrc编写新的cross/<package>/Makefile
   - 处理复杂的configure和build选项
   - 交叉编译问题排查

2. **性能优化**：
   - 分析瓶颈 (profile代码)
   - 优化算法或I/O

3. **技术指导**：
   - 帮助L1开发者解决技术问题
   - 设计和审查关键代码

## 常见错误

❌ **编码前没有理解架构**: 导致实现与设计不符  
❌ **本地构建没成功就提交PR**: 浪费团队时间  
❌ **遗留debug代码**: console.log, print语句  
❌ **一个PR改太多代码**: 难以review，容易出错  
❌ **不写注释**: 后期维护者看不懂  
❌ **忽视编译警告**: 警告往往是bug的前兆  
❌ **超过deadline还没ask for help**: 越早上报风险越好  

## 工具和资源

- **IDE**: VS Code (推荐扩展: C/C++, Python, Remote - SSH)
- **编译工具**: GCC, Make, Autoconf, Automake
- **版本控制**: Git + GitHub/GitLab
- **测试框架**: pytest (Python), Jest (Node.js), gtest (C++)
- **性能工具**: perf (Linux), Instruments (macOS)

---

**版本**: 1.0  
**最后更新**: 2026-05-16
