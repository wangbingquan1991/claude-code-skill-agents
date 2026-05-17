#!/bin/bash

# SPK包验证脚本
# 检查生成的SPK包是否符合标准

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

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 检查文件
if [ -z "$1" ]; then
  info "用法: $0 <spk-file>"
  info "例子: $0 packages/vscode-1.90.0-1_x64.spk"
  exit 1
fi

spk_file="$1"

if [ ! -f "$spk_file" ]; then
  error "文件不存在: $spk_file"
  exit 1
fi

info "=========================================="
info "SPK包验证"
info "=========================================="
info "文件: $spk_file"
echo ""

# 检查1: 文件类型
info "检查1: 文件类型"
file_type=$(file -b "$spk_file")
if [[ "$file_type" == *"gzip"* ]]; then
  success "✓ 文件格式正确 (gzip)"
else
  error "✗ 文件格式错误: $file_type (应为gzip)"
  exit 1
fi
echo ""

# 检查2: 包大小
info "检查2: 包大小"
size_bytes=$(stat -f%z "$spk_file" 2>/dev/null || stat -c%s "$spk_file")
size_mb=$((size_bytes / 1024 / 1024))

if [ $size_mb -lt 100 ]; then
  warn "⚠ 包大小很小 ($size_mb MB)，可能缺少文件"
elif [ $size_mb -lt 2048 ]; then
  success "✓ 包大小合理 ($size_mb MB)"
else
  warn "⚠ 包大小很大 ($size_mb MB)，考虑优化"
fi
echo ""

# 检查3: 包内容
info "检查3: 包内容和元数据"
temp_dir=$(mktemp -d)
trap "rm -rf $temp_dir" EXIT

tar -xzf "$spk_file" -C "$temp_dir"

# 检查INFO文件
if [ -f "$temp_dir/INFO" ]; then
  success "✓ INFO元数据文件存在"
  
  # 提取关键信息
  package_name=$(grep "^package=" "$temp_dir/INFO" | cut -d= -f2)
  version=$(grep "^version=" "$temp_dir/INFO" | cut -d= -f2)
  arch=$(grep "^arch=" "$temp_dir/INFO" | cut -d= -f2)
  
  info "  package: $package_name"
  info "  version: $version"
  info "  arch: $arch"
else
  error "✗ INFO文件缺失"
  exit 1
fi
echo ""

# 检查4: PACKAGE.TGZ
info "检查4: 应用包文件"
if [ -f "$temp_dir/PACKAGE.TGZ" ]; then
  success "✓ PACKAGE.TGZ存在"
  
  # 检查PACKAGE.TGZ大小
  pkg_size=$(stat -f%z "$temp_dir/PACKAGE.TGZ" 2>/dev/null || stat -c%s "$temp_dir/PACKAGE.TGZ")
  pkg_size_mb=$((pkg_size / 1024 / 1024))
  info "  大小: $pkg_size_mb MB"
  
  # 列出PACKAGE.TGZ中的顶级文件
  info "  文件列表 (前20个):"
  tar -tzf "$temp_dir/PACKAGE.TGZ" | head -20 | sed 's/^/    /'
else
  error "✗ PACKAGE.TGZ缺失"
  exit 1
fi
echo ""

# 检查5: 签名文件 (可选)
info "检查5: 签名文件 (可选)"
if [ -f "$temp_dir/package.tgz.asc" ]; then
  success "✓ 签名文件存在"
else
  warn "⚠ 签名文件不存在 (发布前需要签名)"
fi
echo ""

# 总结
info "=========================================="
info "验证完成"
info "=========================================="
success "✓ SPK包基本检查通过"
success "包 $spk_file 可以安装到DSM上"
