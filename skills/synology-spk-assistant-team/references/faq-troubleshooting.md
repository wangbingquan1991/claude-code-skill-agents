# 常见问题和故障排查 (faq-troubleshooting.md)

## 环境问题

### Q: Docker在macOS上非常慢，构建需要好几小时

**A**: 这是Docker Desktop在macOS上的已知问题。解决方案：

1. **改用OrbStack** (推荐，快3-5倍)
   ```bash
   brew install orbstack
   ```

2. **优化Docker性能**：
   - Docker Desktop设置: 增加CPU和内存分配
   - 关闭unnecessary Docker features
   - 用 `--platform=linux/amd64` 标志确保correct architecture

3. **使用构建缓存**：
   ```bash
   # 保持toolchain目录，避免重复下载
   make distclean  # 只清除project，不清除toolchain
   ```

---

### Q: 磁盘空间不足，无法继续构建

**A**: SPK构建需要大量磁盘空间 (50GB+)。

1. **检查占用**：
   ```bash
   du -sh ~/synology-spk-workspace/*
   ```

2. **清理方案**：
   ```bash
   # 清理docker镜像
   docker image prune -a

   # 清理项目old builds (但保留toolchain)
   make distclean

   # 清理下载的源代码 (会重新下载)
   rm -rf distrib/*
   ```

3. **转移workspace到大磁盘**：
   ```bash
   mv ~/synology-spk-workspace /Volumes/ExternalDrive/
   ln -s /Volumes/ExternalDrive/synology-spk-workspace ~/
   ```

---

### Q: Git submodule更新失败

**A**: 可能是网络问题或权限问题。

```bash
# 完整重新初始化
git submodule deinit -f .
git submodule update --init --recursive

# 或用SSH而不是HTTPS (需要SSH key)
git config submodule.spksrc.url git@github.com:SynoCommunity/spksrc.git
git submodule update
```

---

## 编译问题

### Q: `gcc: command not found` 或 `make: command not found`

**A**: 需要进入Docker容器。

```bash
# 确认Docker容器已启动
docker ps

# 如果没有，启动一个
docker run -it -v $(pwd):/workspace ghcr.io/synocommunity/spksrc:latest bash

# 在容器内
cd /workspace
make setup
make arch-x64
```

---

### Q: 编译失败，错误: `error: No such file or directory`

**常见原因和解决方案**：

1. **Header文件找不到**:
   ```
   error: openssl/ssl.h: No such file or directory
   ```
   
   解决：确保依赖已声明
   ```makefile
   DEPENDS = openssl
   ```

2. **源代码未下载**:
   ```
   error: vscode-1.90.0/Makefile: No such file
   ```
   
   解决：check digests和源代码URL
   ```bash
   cat spk/vscode/digests  # 确认hash值
   make setup  # 重新下载
   ```

3. **Patch应用失败**:
   ```
   patch: **** malformed patch at line 5
   ```
   
   解决：检查patch文件格式
   ```bash
   # 验证patch可用
   cd spksrc && patch -p1 --dry-run < patches/001-headless.patch
   ```

---

### Q: 编译成功，但包大小超过2GB，无法在DSM上安装

**A**: 需要大幅优化包大小。

1. **检查包内容**：
   ```bash
   tar tzf packages/vscode-*.spk | head -50
   file packages/vscode-*.spk
   ```

2. **删除不必要的文件**：
   ```makefile
   # 在spk/vscode/Makefile中添加
   post-install:
       rm -rf $(STAGING_INSTALL_PREFIX)/usr/share/doc/*
       rm -rf $(STAGING_INSTALL_PREFIX)/usr/share/man/*
       $(STRIP) $(STAGING_INSTALL_PREFIX)/bin/* 2>/dev/null
       find $(STAGING_INSTALL_PREFIX) -name "*.a" -delete
   ```

3. **删除不必要的依赖**：
   - 评估是否所有npm modules都需要
   - 删除dev dependencies
   - 找轻量级的替代品

4. **终极方案**：重新设计架构
   - 是否能分离成多个小包？
   - 是否能去掉某些功能模块？

---

### Q: 多架构构建失败，x64成功但ARM64失败

**A**: 可能是架构特定的问题。

1. **禁用架构特定的优化**：
   ```makefile
   CONFIGURE_ARGS = --disable-asm --disable-neon
   ```

2. **检查endianness**：
   大部分问题不是endianness (都是little-endian)，但某些old code可能有假设

3. **查看详细错误**：
   ```bash
   make arch-aarch64 V=1 2>&1 | tail -50
   ```

---

## SPK和安装问题

### Q: SPK包成功生成，但在DSM上安装失败，错误: `Invalid file format`

**A**: 这通常表示使用了错误的DSM版本或architecture。

1. **检查PLIST metadata**：
   ```json
   {
     "arch": "x64,aarch64,x86"  // 确认包含当前架构
   }
   ```

2. **检查DSM版本**：
   - DSM 7.x SPK无法在DSM 6.x上安装
   - 需要分别编译或使用兼容构建

3. **检查文件格式**：
   ```bash
   file packages/vscode-*.spk
   # 应该输出: gzip compressed data
   ```

---

### Q: SPK安装成功，但应用无法启动，日志显示 `permission denied`

**A**: 文件权限问题。

1. **检查PLIST中的权限配置**：
   ```json
   {
     "service": {
       "enabled": true
     }
   }
   ```

2. **在构建脚本中设置正确权限**：
   ```makefile
   post-install:
       chmod +x $(STAGING_INSTALL_PREFIX)/bin/vscode-server
   ```

---

### Q: 应用启动后立即崩溃，错误: `Segmentation fault`

**A**: 可能是库版本不匹配或依赖缺失。

1. **检查依赖链**：
   ```bash
   # 在DSM上运行
   ldd /var/packages/vscode/target/bin/vscode-server
   # 查看是否有缺失的library
   ```

2. **调试**：
   ```bash
   # 用gdb调试
   gdb /var/packages/vscode/target/bin/vscode-server
   (gdb) run
   (gdb) backtrace  # 查看crash stack
   ```

---

### Q: 应用运行一段时间后内存占用不断增长（内存泄漏）

**A**: 可能有内存泄漏。

1. **检查日志**：
   ```bash
   # 在DSM上
   tail -f /var/log/synolog
   ```

2. **性能分析**：
   ```bash
   # 使用profiling工具
   valgrind /var/packages/vscode/target/bin/vscode-server
   ```

3. **修复**：
   - 通常是event listener没有正确清理
   - 或database connection没有关闭
   - 查看相关代码并修复

---

## 多架构问题

### Q: 为什么需要多架构支持？不能只支持x64？

**A**: Synology用户的机器多样性很高：

- **x64** (DS918+等): 新旗舰机型，20%用户
- **ARM64** (DS723等): 新中端，50%用户
- **x86** (老机型): 10%用户
- **ARM32** (极老机型): 10%用户

只支持x64会失去大部分用户。

---

### Q: 同一个源代码，在ARM64上构建会崩溃，但x64正常

**A**: 可能有以下问题：

1. **大小相关bug**: `int` vs `long` (32-bit vs 64-bit)
   ```c
   // ❌ 不安全
   int x = sizeof(void*);  // 在32-bit ARM上=4，在64-bit=8
   
   // ✅ 安全
   size_t x = sizeof(void*);
   ```

2. **对齐相关bug**: ARM对对齐的要求比x86严格

3. **字节序假设**: 某些old code假设little-endian (通常安全，但检查)

---

### Q: 编译时间太长，能否跳过某些架构？

**A**: 可以。

1. **只构建特定架构**：
   ```bash
   make arch-x64 arch-aarch64  # 只构建x64和ARM64
   ```

2. **在Makefile中跳过某个架构**：
   ```makefile
   # spk/vscode/Makefile
   ifeq ($(ARCH),arm)
     # ARM32不支持
     $(error ARM 32-bit is not supported)
   endif
   ```

但建议至少支持x64 + ARM64 (新用户主要用ARM64)。

---

## CI/CD和自动化问题

### Q: GitHub Actions构建超时或内存不足

**A**: GitHub Actions runners资源有限。

1. **并行构建限制**：
   ```bash
   make arch-x64 -j2  # 只用2线程，不要-j4
   ```

2. **分离构建**：
   ```yaml
   # .github/workflows/build.yml
   - name: Build x64
     run: make arch-x64
   
   - name: Build ARM64
     run: make arch-aarch64
   ```

3. **使用cache**：
   ```yaml
   - uses: actions/cache@v3
     with:
       path: toolchain/
       key: toolchain-${{ runner.os }}
   ```

---

### Q: 发布流程中，SPK签名失败

**A**: 可能是签名证书或密钥问题。

1. **检查证书**：
   ```bash
   openssl x509 -in cert.pem -noout -text
   ```

2. **检查私钥**：
   ```bash
   openssl pkey -in key.pem -check
   ```

3. **在GitHub Secrets中安全存储**：
   ```bash
   # 不要在代码中hardcode
   # 用GitHub Secrets存储cert和key
   echo "${{ secrets.SPK_CERT }}" > cert.pem
   ```

---

## 性能和优化问题

### Q: vscode启动时间>30秒，超过了10秒目标

**A**: 启动慢通常是依赖加载问题。

1. **分析启动路径**：
   ```bash
   time vscode-server --startup-debug
   ```

2. **优化Node.js启动**：
   ```bash
   # 减少require的模块数
   node --max-old-space-size=256 vscode-server
   ```

3. **缓存优化**：
   - 使用webpack或esbuild打包，而不是require逐个文件

---

### Q: 在低端NAS上运行，CPU占用100%

**A**: 可能有busy-wait循环。

1. **查看CPU profile**：
   ```bash
   top  # 看哪个进程占用CPU高
   ```

2. **修复busy-wait**：
   ```javascript
   // ❌ Busy-wait (CPU 100%)
   while(!ready) {}
   
   // ✅ Event-driven
   on('ready', () => {})
   ```

---

## 文档和其他问题

### Q: 用户反馈说"某个功能在官方vscode上工作，但在SPK上不工作"

**A**: 这可能是headless改造导致的功能删减。

**解决方案**：
1. 检查这个功能是否在known limitations清单中
2. 如果不在，可能是真的bug，需要修复
3. 添加到文档的Known Issues中

---

### Q: 如何为项目贡献代码？

**A**: 标准的GitHub workflow：

```bash
# Fork项目
# Clone你的fork
git clone https://github.com/yourname/vscode-spk.git
cd vscode-spk

# 创建feature分支
git checkout -b feature/my-feature

# 做改动和test
# Commit并push
git push origin feature/my-feature

# 在GitHub上提PR
```

---

## 联系和升级支持

如果问题未被以上FAQ覆盖：

1. 查看项目的GitHub Issues
2. 查看spksrc官方文档
3. 提交新Issue (提供：错误信息、日志、重现步骤)

---

**版本**: 1.0  
**最后更新**: 2026-05-16
