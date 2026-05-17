#!/bin/bash

# OrbStack VM 初始化脚本 (macOS Only)
# 为macOS用户在OrbStack上创建Debian 13 VM并安装SPK开发环境

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# 检查macOS和OrbStack
check_system() {
  info "检查系统环境..."
  
  if [[ "$OSTYPE" != "darwin"* ]]; then
    error "本脚本仅适用于macOS"
    exit 1
  fi
  
  if ! command -v orbstack &> /dev/null; then
    error "OrbStack未安装，请先运行:"
    echo "  brew install orbstack"
    exit 1
  fi
  
  info "✓ OrbStack已安装"
}

# 启动OrbStack
start_orbstack() {
  info "启动OrbStack..."
  
  if orbstack status &>/dev/null; then
    info "✓ OrbStack已运行"
  else
    info "启动OrbStack服务..."
    orbstack start
    sleep 3
    info "✓ OrbStack已启动"
  fi
}

# 验证Docker
verify_docker() {
  info "验证Docker..."
  
  if ! docker ps &>/dev/null; then
    error "Docker连接失败"
    exit 1
  fi
  
  info "✓ Docker正常"
}

# 拉取spksrc镜像
pull_image() {
  info "拉取spksrc Docker镜像..."
  
  if docker pull ghcr.io/synocommunity/spksrc:latest; then
    info "✓ 镜像已拉取 (使用GHCR)"
  else
    warn "GHCR拉取失败，尝试Docker Hub..."
    docker pull synocommunity/spksrc:latest
    info "✓ 镜像已拉取 (使用Docker Hub)"
  fi
}

# 创建workspace
setup_workspace() {
  info "创建workspace..."
  
  workspace="$HOME/synology-spk-workspace"
  mkdir -p "$workspace"/{projects,build-cache,artifacts}
  
  info "✓ Workspace已创建: $workspace"
}

# 完成
print_summary() {
  info "=========================================="
  info "✓ OrbStack环境已准备就绪"
  info "=========================================="
  echo ""
  echo "现在可以开始SPK开发:"
  echo ""
  echo "1. 进入workspace:"
  echo "   cd ~/synology-spk-workspace/projects"
  echo ""
  echo "2. Clone项目:"
  echo "   git clone <repo-url>"
  echo ""
  echo "3. 启动Docker并构建:"
  echo "   docker run -it -v \$(pwd):/workspace ghcr.io/synocommunity/spksrc:latest bash"
  echo "   cd /workspace"
  echo "   make setup && make arch-x64"
  echo ""
}

# 主流程
main() {
  info "=========================================="
  info "OrbStack macOS SPK开发环境初始化"
  info "=========================================="
  echo ""
  
  check_system
  start_orbstack
  verify_docker
  pull_image
  setup_workspace
  print_summary
}

main
