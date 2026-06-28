#!/bin/bash
# ==================================================
# MediaMate - Mac 新电脑一键配置脚本
# 在 终端.app 里运行: bash setup_mac.sh
# ==================================================

set -e

PROJECT_DIR="$HOME/Desktop/MediaMate"
REPO_URL="https://github.com/zt444888-hub/New-repository.git"

echo "=========================================="
echo " MediaMate Mac 开发环境配置"
echo "=========================================="

# 1. 检查 Xcode
echo ""
echo "[1/5] 检查 Xcode..."
if ! xcode-select -p &>/dev/null; then
    echo "    ❌ Xcode Command Line Tools 未安装"
    echo "   请在终端运行: xcode-select --install"
    exit 1
fi
XCODE_VERSION=$(xcodebuild -version | head -1)
echo "    ✅ $XCODE_VERSION"

# 2. 克隆项目
echo ""
echo "[2/5] 克隆项目..."
if [ -d "$PROJECT_DIR" ]; then
    echo "    ⚠️  目录已存在，正在更新..."
    cd "$PROJECT_DIR"
    git pull origin master
else
    git clone "$REPO_URL" "$PROJECT_DIR"
    echo "    ✅ 克隆完成"
fi

# 3. 打开项目
echo ""
echo "[3/5] 打开 Xcode 项目..."
cd "$PROJECT_DIR"
open MediaMate.xcodeproj

# 4. 清理 DerivedData
echo ""
echo "[4/5] 清理之前的编译缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/MediaMate-*
echo "    ✅ 已清理"

# 5. 选择模拟器提示
echo ""
echo "[5/5] ✅ 配置完成!"
echo ""
echo "=========================================="
echo " 接下来在 Xcode 中:"
echo ""
echo "  1. 等 Xcode 打开项目"
echo "  2. 顶部工具栏选择模拟器: iPhone 16 Pro 等"
echo "  3. 按 Cmd + R 运行"
echo ""
echo "  如果编译报错:"
echo "    • Product → Clean Build Folder"
echo "    • 然后重新 Cmd + R"
echo "=========================================="
