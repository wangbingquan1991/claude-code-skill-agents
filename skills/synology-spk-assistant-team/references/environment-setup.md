# 开发环境初始化指南 (environment-setup.md)

本文档是开发者的第一份文档，指导如何从零开始搭建SPK开发环境。

## 系统要求

- **macOS**: OrbStack (Docker虚拟化)  
- **Linux**: Native Docker 或 WSL2 (Windows)  
- **Windows**: WSL2 + Docker Desktop

⚠️ **警告**: Windows native cmd.exe 不支持SPK开发 (文件系统限制)

## macOS用户: OrbStack安装 (推荐)

### 步骤1: 安装OrbStack

OrbStack是比Docker Desktop更轻量的虚拟化方案，推荐用于SPK开发。

```bash
# 方式1: Homebrew (推荐)
brew install orbstack

# 方式2: 直接下载
# https://orbstack.dev/download
```

### 步骤2: 启动OrbStack并验证
```bash
orbstack start

# 验证Docker可用
docker --version
docker run hello-world
```

### 步骤3: 配置workspace目录
```bash
# 创建SPK开发的统一workspace
mkdir -p ~/synology-spk-workspace/{projects,build-cache,artifacts}

# 后续所有项目都在此目录下
cd ~/synology-spk-workspace
```

## Linux用户: Docker native安装

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# CentOS/RHEL
sudo yum install docker docker-compose

# 启动Docker service
sudo systemctl start docker
sudo systemctl enable docker

# (可选) 允许当前用户使用Docker
sudo usermod -aG docker $USER
```

## 从仓库获取项目

```bash
cd ~/synology-spk-workspace/projects

# Clone项目仓库
git clone <项目repo> my-spk-project
cd my-spk-project

# 配置Git (如果还没配)
git config user.name "Your Name"
git config user.email "your@email.com"

# 拉取submodule (spksrc框架)
git submodule update --init --recursive
```

## 初始化构建环境

### 方式A: 自动化脚本 (推荐)

项目中包含自动化脚本:

```bash
cd ~/synology-spk-workspace/projects/my-spk-project

# 自动化初始化
bash scripts/init-workspace.sh

# 脚本会:
# 1. 验证Docker/OrbStack已安装
# 2. 拉取spksrc-build Docker镜像
# 3. 创建本地目录结构
# 4. 验证编译工具链可用
```

### 方式B: 手动初始化

如果自动化脚本出问题，可以手动操作:

```bash
# 拉取官方spksrc构建镜像
docker pull synocommunity/spksrc:latest

# 或用ghcr.io的镜像 (如果Docker Hub限速)
docker pull ghcr.io/synocommunity/spksrc:latest

# 启动容器 (mount workspace)
docker run -it --rm \
  -v ~/synology-spk-workspace:/workspace \
  ghcr.io/synocommunity/spksrc:latest \
  bash

# 进入容器后:
cd /workspace/projects/my-spk-project
make setup
```

## 首次本地构建验证

```bash
cd ~/synology-spk-workspace/projects/my-spk-project

# 构建x64版本(默认)
make arch-x64

# 如果成功，输出在packages/目录:
ls packages/*.spk
```

**常见错误和解决方案**:

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `docker: command not found` | Docker未安装 | 重新安装Docker/OrbStack |
| `make: not found` | 需要进入Docker容器 | `docker run ... bash` |
| `gcc: not found` | 工具链未初始化 | 运行 `make setup` |
| 构建超级慢 | 首次需要下载工具链 | 耐心等待，或检查网络 |

## IDE/编辑器配置

### VS Code配置

推荐扩展:
- Remote - SSH (连接远程Docker)
- C/C++ (if C项目)
- Python (if Python项目)
- Makefile Tools

**配置**:
```json
{
  "files.exclude": {
    "*.o": true,
    "*.a": true,
    "**/__pycache__": true
  },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "ms-python.python"
}
```

### Git配置

```bash
# 全局配置 (如果还没做)
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global core.editor "nano"  # 或你喜欢的编辑器

# 项目特定配置
cd my-spk-project
git config user.name "Your Name"
git config user.email "your@email.com"

# 生成SSH key (if using SSH for Git)
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub  # 复制到GitHub/GitLab的SSH keys
```

## 验证环境就绪

运行检查脚本，确认所有依赖都满足:

```bash
# 检查Docker
docker --version

# 检查Git
git --version

# 进入容器检查工具链
docker run --rm synocommunity/spksrc:latest sh -c "gcc --version && make --version"

# 检查磁盘空间 (需要至少20GB)
df -h ~/synology-spk-workspace

# 检查网络连接 (spksrc需要下载文件)
curl -I https://github.com
```

## 多开发者环境同步

如果多个开发者在同一项目，确保环境一致:

```bash
# 拉取最新的Docker镜像
docker pull ghcr.io/synocommunity/spksrc:latest

# 更新spksrc submodule
git submodule update --remote

# 重新构建工具链缓存
rm -rf toolchain/
make setup
```

## 磁盘空间管理

SPK构建会占用大量磁盘空间:

```bash
# 查看space占用
du -sh ~/synology-spk-workspace/*

# 清理旧的Docker镜像和容器
docker image prune -a
docker container prune

# 清理构建缓存 (如果需要重新构建)
make distclean  # 清理当前项目
rm -rf toolchain/  # 清理工具链缓存
```

## 故障排查

### Docker容器无法启动
```bash
# 检查Docker service是否运行
sudo systemctl status docker

# 如果没运行，启动它
sudo systemctl start docker

# 检查权限
docker ps
```

### 构建时网络错误
```bash
# 确认网络连接
ping github.com

# 如果Docker Hub限速，用阿里云或GHCR
docker pull ghcr.io/synocommunity/spksrc:latest

# 或设置HTTP代理 (if behind proxy)
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080
```

### 磁盘空间不足
```bash
# 清理Docker
docker system prune -a

# 清理项目构建文件
cd my-spk-project
make distclean

# 如果还是不够，转移workspace到更大的磁盘
mv ~/synology-spk-workspace /Volumes/ExternalDrive/
ln -s /Volumes/ExternalDrive/synology-spk-workspace ~/synology-spk-workspace
```

## 环境验证检查清单

- [ ] Docker/OrbStack已安装且运行
- [ ] Git已安装并配置了用户信息
- [ ] SSH key已生成 (for Git)
- [ ] workspace目录已创建并有足够磁盘空间(>=20GB)
- [ ] 项目仓库已clone
- [ ] submodule已初始化
- [ ] 首次make arch-x64能成功构建
- [ ] IDE/编辑器已配置好

---

**版本**: 1.0  
**最后更新**: 2026-05-16
