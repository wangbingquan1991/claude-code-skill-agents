#!/bin/bash

# 多架构构建脚本
# 一次构建所有支持的架构（x64, ARM64, x86）

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
ARCHITECTURES=("x64" "aarch64" "x86")
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BUILD_LOG_DIR="build_logs_$TIMESTAMP"

info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# 创建日志目录
mkdir -p "$BUILD_LOG_DIR"

info "=========================================="
info "多架构SPK构建开始"
info "=========================================="
info "时间戳: $TIMESTAMP"
info "架构: ${ARCHITECTURES[@]}"
echo ""

# 进入spksrc目录
if [ ! -d "spksrc" ]; then
  error "spksrc目录不存在，请确保在项目根目录运行此脚本"
  exit 1
fi

cd spksrc

# 构建每个架构
build_count=0
success_count=0
failed_archs=()

for arch in "${ARCHITECTURES[@]}"; do
  build_count=$((build_count + 1))
  
  info "==============================================="
  info "[$build_count/${#ARCHITECTURES[@]}] 开始构建架构: $arch"
  info "==============================================="
  
  log_file="../$BUILD_LOG_DIR/build_${arch}.log"
  
  if make arch-$arch > "$log_file" 2>&1; then
    success_count=$((success_count + 1))
    info "✓ $arch 构建成功"
    
    # 输出包信息
    if ls ../packages/*-$arch.spk 2>/dev/null > /dev/null; then
      spk_file=$(ls ../packages/*-$arch.spk | head -1)
      spk_size=$(du -h "$spk_file" | cut -f1)
      info "  输出文件: $(basename $spk_file) ($spk_size)"
    fi
  else
    failed_archs+=("$arch")
    error "✗ $arch 构建失败 (日志: $log_file)"
    
    # 打印最后20行日志供快速诊断
    echo "========== 错误日志摘录 =========="
    tail -20 "$log_file"
    echo "=================================="
  fi
  
  echo ""
done

# 总结
info "=========================================="
info "多架构构建完成"
info "=========================================="
info "总计: $build_count, 成功: $success_count, 失败: $((build_count - success_count))"

if [ ${#failed_archs[@]} -gt 0 ]; then
  error "失败的架构: ${failed_archs[@]}"
  error "请查看 $BUILD_LOG_DIR/ 中的详细日志"
  exit 1
else
  info "✓ 所有架构构建成功!"
  
  # 列出所有输出
  info "输出SPK包:"
  ls -lh ../packages/*.spk 2>/dev/null || warn "未找到SPK包"
  
  # 计算总大小
  total_size=$(du -sh ../packages 2>/dev/null | cut -f1)
  info "总大小: $total_size"
fi

info "日志目录: $BUILD_LOG_DIR/"
