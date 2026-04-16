#!/bin/bash

# MobileFFmpeg 自定义构建脚本
# 基于 AndroidAppFactory 项目中的 FFmpegBuild.java 构建流程

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "MobileFFmpeg 自定义构建脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --help, -h          显示此帮助信息"
    echo "  --minimal           最小配置构建（仅基础功能）"
    echo "  --standard          标准配置构建（推荐）"
    echo "  --full              完整配置构建（包含所有库）"
    echo "  --disable-arch ARCH 禁用特定架构"
    echo ""
    echo "公共参数（所有模式自动包含）:"
    echo "  --disable-arm-v7a-neon  --enable-libpng  --enable-openh264"
    echo ""
    echo "示例:"
    echo "  $0 --standard                    # 标准构建（推荐）"
    echo "  $0 --minimal                     # 最小构建（仅 arm64-v8a）"
    echo "  $0 --full                        # 完整构建（所有架构）"
}

# 检查环境变量
check_environment() {
    log_info "检查环境变量..."
    
    if [ -z "$ANDROID_NDK_ROOT" ]; then
        log_error "ANDROID_NDK_ROOT 环境变量未设置"
        log_info "请设置: export ANDROID_NDK_ROOT=<你的 NDK 路径>"
        exit 1
    fi
    
    if [ ! -d "$ANDROID_NDK_ROOT" ]; then
        log_error "NDK 目录不存在: $ANDROID_NDK_ROOT"
        exit 1
    fi
    
    log_success "环境变量检查通过"
}

# 检查依赖
check_dependencies() {
    log_info "检查构建依赖..."
    
    local deps=("autoconf" "automake" "libtool" "pkg-config" "curl" "cmake" "gcc" "gperf" "texinfo" "yasm" "nasm" "bison" "autogen" "patch" "git")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_warn "依赖未安装: $dep"
            log_info "请使用包管理器安装: brew install $dep"
        fi
    done
    
    # 检查 NASM 配置
    if [ ! -f "$ANDROID_NDK_ROOT/prebuilt/darwin-x86_64/bin/nasm" ]; then
        log_info "配置 NASM..."
        if [ -f "$ANDROID_NDK_ROOT/prebuilt/darwin-x86_64/bin/yasm" ]; then
            cp "$ANDROID_NDK_ROOT/prebuilt/darwin-x86_64/bin/yasm" "$ANDROID_NDK_ROOT/prebuilt/darwin-x86_64/bin/nasm"
            log_success "NASM 配置完成"
        else
            log_error "yasm 未找到，无法配置 NASM"
            exit 1
        fi
    fi
    
    log_success "依赖检查完成"
}

# 构建配置
BUILD_ARGS=""

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --minimal)
                # 最小构建：仅 arm64-v8a
                BUILD_MODE="minimal"
                BUILD_ARGS="$BUILD_ARGS --disable-arm-v7a --disable-x86 --disable-x86-64"
                shift
                ;;
            --standard)
                # 标准构建：所有架构（除 arm-v7a-neon）
                BUILD_MODE="standard"
                shift
                ;;
            --full)
                # 完整构建：与标准相同，预留扩展
                BUILD_MODE="full"
                shift
                ;;
            --disable-arch)
                if [ -n "$2" ]; then
                    BUILD_ARGS="$BUILD_ARGS --disable-$2"
                    shift 2
                else
                    log_error "--disable-arch 需要参数"
                    exit 1
                fi
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 公共参数：所有模式都包含
    local COMMON_ARGS="--disable-arm-v7a-neon --enable-libpng --enable-openh264"
    
    if [ -z "$BUILD_MODE" ]; then
        BUILD_MODE="standard"
        log_info "未指定模式，使用默认标准配置"
    fi
    
    log_info "构建模式: $BUILD_MODE"
    
    # 合并公共参数和模式特有参数
    BUILD_ARGS="$COMMON_ARGS $BUILD_ARGS"
}

# 执行构建
run_build() {
    log_info "开始构建 MobileFFmpeg..."
    log_info "构建参数: $BUILD_ARGS"
    
    # 检查构建脚本是否存在
    if [ ! -f "./android.sh" ]; then
        log_error "android.sh 构建脚本未找到"
        exit 1
    fi
    
    # 执行构建
    log_info "执行构建命令: ./android.sh $BUILD_ARGS"
    
    if ./android.sh $BUILD_ARGS; then
        log_success "构建成功完成！"
        
        # 显示构建输出信息
        log_info "构建输出位置:"
        log_info "- AAR 文件: prebuilt/android-aar/"
        log_info "- 预编译库: prebuilt/android-*/"
        
    else
        log_error "构建失败，请检查 build.log 文件获取详细信息"
        exit 1
    fi
}

# 主函数
main() {
    log_info "=== MobileFFmpeg 自定义构建脚本 ==="
    
    # 切换到脚本所在目录
    cd "$(dirname "$0")"
    log_info "工作目录: $(pwd)"
    
    # 解析参数
    parse_arguments "$@"
    
    # 检查环境
    check_environment
    
    # 检查依赖
    check_dependencies
    
    # 执行构建
    run_build
    
    log_success "构建流程完成！"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi