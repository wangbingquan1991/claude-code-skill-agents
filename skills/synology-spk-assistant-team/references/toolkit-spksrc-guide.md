# spksrc 工具链完整指南 (toolkit-spksrc-guide.md)

spksrc (Synology Package Kit Source) 是社区开发的SPK构建框架，包含了所有cross-compilation工具和已有的package recipes。

## spksrc核心概念

### 文件夹结构

```
spksrc/
├── cross/              # cross-compilation recipes (工具链)
│   ├── gcc/
│   ├── glibc/
│   ├── binutils/
│   └── ...
├── native/             # native build recipes (native tools)
├── spk/                # 应用SPK recipes
│   ├── vscode/         # vscode项目的构建规则
│   ├── docker/
│   └── ...
├── toolchain/          # 编译好的toolchain二进制 (cache)
├── packages/           # 输出的SPK包
├── distrib/            # 下载的源代码和patches
├── Makefile            # 主Makefile
└── mk/                 # Make rules库
```

### 关键概念

1. **Architecture** (CPU架构):
   - `x64`: Intel x86_64 (64-bit)
   - `x86`: Intel x86 (32-bit, 老机器)
   - `armv7`: ARM 32-bit
   - `aarch64` (ARM64): ARM 64-bit (新DS)

2. **DSM Version**: (群晖系统版本)
   - `DSM7`: DSM 7.x (推荐)
   - `DSM6`: DSM 6.x (遗留，可选)

3. **Recipe**: 一个项目的构建规则 (Makefile + patches + metadata)

4. **Dependency**: 项目需要的library和tool

## 基础命令

### 列出所有支持的架构和DSM版本

```bash
cd spksrc

# 显示支持的architectures
cat mk/spksrc.architectures.mk

# 显示支持的DSM版本  
cat mk/spksrc.dsm_versions.mk
```

### 构建特定架构

```bash
# 构建x64
make arch-x64

# 构建ARM64
make arch-aarch64

# 构建所有支持的架构 (会花很长时间)
make all-supported
```

### 关于spk/vscode/ (示例项目)

假设我们要移植vscode，会在 `spk/vscode/` 创建构建规则:

```
spk/vscode/
├── Makefile              # 核心构建规则
├── PLIST                 # 元数据 (app info, icon等)
├── digests               # 源代码的hash校验
└── patches/              # 对vscode源代码的patch
    ├── 001-headless.patch      # 去掉GUI相关代码
    ├── 002-dsm-paths.patch     # 调整路径以适应DSM
    └── ...
```

## Makefile 和 PLIST 详解

### Makefile 结构

```makefile
# spk/vscode/Makefile

# 基础信息
SPK_NAME = vscode
SPK_VERS = 1.90.0         # vscode版本
SPK_REV = 1               # SPK修订号
BUILD_DEPENDS = native/node:native
DEPENDS = nodejs openssl  # vscode依赖的库

# 源代码下载
DIST_NAME = code-stable
DIST_FILE = $(DIST_NAME)-$(SPK_VERS).tar.gz
DIST_SITE = https://github.com/microsoft/vscode/archive

# 构建规则
# ...定义checksum、解压、编译、打包等步骤

include ../../mk/spksrc.spk.mk
```

### PLIST 结构 (元数据)

```json
{
  "package": {
    "name": "vscode",
    "version": "1.90.0-1",
    "arch": "x64,x86,arm,armv7,aarch64",
    "exclude_arch": "",
    "start": true,
    "beta": false,
    "maintainer": "community",
    "description": "Visual Studio Code on Synology",
    "description_enu": "Code editor",
    "icon": "{ICON_URL}"
  },
  "service": {
    "enabled": true,
    "start_dep_services": ["nginx"],
    "stop_dep_services": [],
    "prestop": "/var/packages/vscode/scripts/preStop.sh",
    "prestop_timeout": 30
  }
}
```

## 依赖管理 (DEPENDS)

### 声明依赖

在Makefile中，有三种依赖:

1. **BUILD_DEPENDS**: 构建时需要 (如编译器)
   ```makefile
   BUILD_DEPENDS = native/gcc:native native/autoconf:native
   ```

2. **DEPENDS**: 运行时需要 (如lib库)
   ```makefile
   DEPENDS = libc openssl zlib
   ```

3. **Make dependencies**: 构建顺序依赖
   ```makefile
   vscode: libfoo libbar  # 先构建libfoo和libbar
   ```

### 常用依赖包

| 依赖 | 用途 | 例子 |
|------|------|------|
| nodejs | Node.js运行时 | vscode需要node |
| openssl | SSL/TLS库 | HTTPS支持 |
| zlib | 压缩库 | 通用 |
| libjpeg | JPEG支持 | 图片处理 |
| libpng | PNG支持 | 图片处理 |
| python3 | Python运行时 | 某些build tools |

### 查看已有的包

```bash
# 在spksrc中查找已有的recipes
ls spk/*/Makefile | head -20

# 查看某个包的依赖
grep "DEPENDS" spk/nodejs/Makefile

# 搜索特定的库
find spk -name Makefile | xargs grep -l "openssl"
```

## 交叉编译常见问题和解决方案

### 问题1: 编译失败，找不到特定的header文件

```
error: node.h: No such file or directory
```

**解决**:
1. 检查是否声明了依赖
2. 检查依赖是否已编译
3. 调整include路径 (在Makefile中加 `-I` 选项)

```makefile
CFLAGS = -I$(STAGING_INSTALL_PREFIX)/include
LDFLAGS = -L$(STAGING_INSTALL_PREFIX)/lib
```

### 问题2: Undefined reference to symbol

```
undefined reference to `socket'
```

**解决**:
- 需要链接额外的lib (如libsocket)
- 在DEPENDS或LDFLAGS中添加

```makefile
DEPENDS = libc libsocket
```

### 问题3: Architecture-specific assembly code不匹配

某些库包含为特定架构优化的汇编代码，交叉编译时可能失败。

**解决**:
- 用 `--disable-asm` 或类似选项禁用汇编优化
- 或者只为特定架构编译

```makefile
ifeq ($(ARCH),x64)
  CONFIGURE_ARGS = --enable-asm
else
  CONFIGURE_ARGS = --disable-asm
endif
```

### 问题4: configure脚本找不到工具

某些configure脚本会寻找特定的binary (如git, svn等)。

**解决**:
```makefile
CONFIGURE_ARGS = --with-git=/usr/bin/git
```

## 构建优化技巧

### 1. 并行构建

```bash
# 使用所有CPU核心
make arch-x64 -j4  # 4并行线程

# 查看CPU核数
nproc
```

### 2. 增量构建

spksrc默认会cache构建中间文件，省去重复工作:

```bash
# 从头开始构建 (清除所有cache)
make arch-x64 distclean

# 只清除特定项目
cd spk/vscode && make distclean
```

### 3. 包大小优化

```makefile
# 在Makefile中去掉debug symbols
STRIP = strip --strip-all

# 删除不必要的文件
rm -rf $(STAGING_INSTALL_PREFIX)/usr/share/doc/*
rm -rf $(STAGING_INSTALL_PREFIX)/usr/share/man/*
```

### 4. 缓存优化

```bash
# 查看toolchain大小
du -sh spksrc/toolchain/

# 如果磁盘紧张，可以删除旧版本的toolchain
# (但下次构建会重新下载)
```

## 调试技巧

### 查看构建日志

```bash
# 构建时输出详细日志
make arch-x64 V=1

# 或看已生成的日志文件
cat log/<project>-<arch>.log
```

### 进入Docker容器手动构建

```bash
# 启动容器
docker run -it -v $(pwd):/workspace ghcr.io/synocommunity/spksrc:latest bash

# 在容器内
cd /workspace
make setup
make arch-x64 V=1
```

### Patch调试

如果patch应用失败:

```bash
# 尝试手动应用patch
patch -p1 < patches/001-headless.patch

# 如果失败，修改patch或源代码
# 然后重新生成patch:
diff -u original/file.c modified/file.c > new-patch.patch
```

## 常见任务

### 1. 添加新的SPK项目

```bash
# 创建目录
mkdir -p spk/myapp

# 创建Makefile
cat > spk/myapp/Makefile << 'EOF'
SPK_NAME = myapp
SPK_VERS = 1.0.0
SPK_REV = 1
DIST_NAME = myapp
DIST_FILE = $(DIST_NAME)-$(SPK_VERS).tar.gz
DIST_SITE = https://example.com
BUILD_DEPENDS = 
DEPENDS = libc

include ../../mk/spksrc.spk.mk
EOF

# 创建PLIST
cat > spk/myapp/PLIST << 'EOF'
{...}
EOF

# 构建
make arch-x64
```

### 2. 更新已有项目版本

```bash
# 编辑Makefile，更新SPK_VERS和SPK_REV
vi spk/vscode/Makefile

# 更新源代码hash (如果源URL改了)
make arch-x64  # 会自动提示需要更新digests

# 构建
make arch-x64
```

### 3. 为项目添加依赖

```makefile
# 编辑Makefile，加入DEPENDS
DEPENDS = openssl zlib libpng

# 构建时会自动处理依赖的编译顺序
make arch-x64
```

## 资源和参考

- **官方文档**: https://github.com/SynoCommunity/spksrc/wiki
- **已有recipes**: https://github.com/SynoCommunity/spksrc/tree/master/spk
- **Build examples**: https://github.com/SynoCommunity/spksrc/blob/master/doc/

---

**版本**: 1.0  
**最后更新**: 2026-05-16
