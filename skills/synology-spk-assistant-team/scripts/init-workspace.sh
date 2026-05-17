#!/bin/bash

# 群晖SPK开发环境初始化脚本
# 初次使用时运行此脚本自动搭建开发环境

set -e  # 任何错误都中止

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# 函数：打印带颜色的输出
info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# 检查前置条件
check_requirements() {
  info "检查前置条件..."
  
  # 检查Docker/OrbStack
  if ! command -v docker &> /dev/null; then
    error "Docker未安装。请先安装Docker或OrbStack"
    exit 1
  fi
  info "✓ Docker已安装: $(docker --version)"
  
  # 检查Git
  if ! command -v git &> /dev/null; then
    error "Git未安装"
    exit 1
  fi
  info "✓ Git已安装: $(git --version)"
  
  # 检查磁盘空间 (需要至少20GB)
  available=$(df -P . | awk 'NR==2 {print $4}')
  available_gb=$((available / 1024 / 1024))
  
  if [ $available_gb -lt 20 ]; then
    error "磁盘空间不足 (需要>=20GB，现有${available_gb}GB)"
    exit 1
  fi
  info "✓ 磁盘空间充足: ${available_gb}GB"
}

# 创建workspace目录
setup_workspace() {
  info "创建workspace目录..."
  
  workspace_root="$HOME/synology-spk-workspace"
  
  mkdir -p "$workspace_root"/{projects,build-cache,artifacts}
  
  info "✓ Workspace已创建: $workspace_root"
  echo "workspace_root=$workspace_root" > .workspace.env
}

# 拉取spksrc Docker镜像
pull_docker_image() {
  info "拉取spksrc Docker镜像..."
  
  if docker pull ghcr.io/synocommunity/spksrc:latest; then
    info "✓ spksrc镜像已拉取"
  else
    warn "GHCR镜像拉取失败，尝试Docker Hub"
    docker pull synocommunity/spksrc:latest
    info "✓ spksrc镜像已拉取"
  fi
}

# 初始化项目结构
init_project_structure() {
  info "初始化项目结构..."
  
  # 创建目录
  mkdir -p spk/$(basename $(pwd))/{patches,icons}
  mkdir -p cross/{project}
  mkdir -p test
  mkdir -p scripts
  mkdir -p doc
  
  # 创建基础Makefile (如果不存在)
  if [ ! -f Makefile ]; then
    cat > Makefile << 'EOF'
# 项目根Makefile

.PHONY: help setup arch-x64 arch-aarch64 arch-x86 all-supported clean distclean

help:
	@echo "Available targets:"
	@echo "  make setup         - 初始化构建环境"
	@echo "  make arch-x64      - 构建x64架构"
	@echo "  make arch-aarch64  - 构建ARM64架构"
	@echo "  make arch-x86      - 构建x86架构"
	@echo "  make all-supported - 构建所有支持的架构"
	@echo "  make clean         - 清理项目构建文件"
	@echo "  make distclean     - 清理所有文件和cache"

setup:
	cd spksrc && make setup

arch-x64:
	cd spksrc && make arch-x64

arch-aarch64:
	cd spksrc && make arch-aarch64

arch-x86:
	cd spksrc && make arch-x86

all-supported:
	cd spksrc && make all-supported

clean:
	cd spksrc && make clean

distclean:
	cd spksrc && make distclean
EOF
    info "✓ Makefile已创建"
  fi
}

# 验证环境
verify_environment() {
  info "验证环境..."
  
  # 测试Docker
  if docker run --rm hello-world &>/dev/null; then
    info "✓ Docker运行正常"
  else
    error "Docker运行异常"
    exit 1
  fi
  
  # 验证Git
  if git --version &>/dev/null; then
    info "✓ Git配置正常"
  else
    error "Git配置异常"
    exit 1
  fi
}

# 打印完成信息
print_summary() {
  info "=========================================="
  info "✓ 开发环境初始化完成!"
  info "=========================================="
  echo ""
  echo "下一步:"
  echo "1. Git配置 (如果还没做):"
  echo "   git config --global user.name 'Your Name'"
  echo "   git config --global user.email 'your@email.com'"
  echo ""
  echo "2. Clone项目到workspace:"
  echo "   cd $HOME/synology-spk-workspace/projects"
  echo "   git clone <repo-url>"
  echo ""
  echo "3. 进入项目并初始化spksrc:"
  echo "   cd <project>"
  echo "   git submodule update --init --recursive"
  echo ""
  echo "4. 进入Docker容器执行构建:"
  echo "   docker run -it -v $(pwd):/workspace ghcr.io/synocommunity/spksrc:latest bash"
  echo "   cd /workspace"
  echo "   make setup"
  echo "   make arch-x64"
  echo ""
  echo "5. 输出SPK包在 packages/ 目录"
  echo ""
}

# 主流程
main() {
  echo "=========================================="
  echo "群晖SPK开发环境初始化脚本"
  echo "=========================================="
  echo ""
  
  check_requirements
  setup_workspace
  pull_docker_image
  init_project_structure
  verify_environment
  print_summary
}

main
