#!/bin/bash
# MediaMate - 租用 Mac 一键配置脚本
# 在 Terminal 中运行: bash setup-mac.sh

set -e

echo "📦 MediaMate Mac Setup"
echo "======================"

# 1. Check Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found. Please install Xcode from the App Store first."
    exit 1
fi
echo "✅ Xcode: $(xcodebuild -version | head -1)"

# 2. Accept Xcode license
sudo xcodebuild -license accept 2>/dev/null || echo "ℹ️  License may already be accepted"

# 3. Clone project
if [ ! -d ~/Desktop/MediaMate ]; then
    echo "📥 Cloning project..."
    cd ~/Desktop
    git clone https://github.com/zt444888-hub/New-repository.git MediaMate
    echo "✅ Project cloned to ~/Desktop/MediaMate"
else
    echo "📂 Project already exists, pulling latest..."
    cd ~/Desktop/MediaMate
    git pull
fi

# 4. Open Xcode project
cd ~/Desktop/MediaMate
open MediaMate.xcodeproj

echo ""
echo "🎯 Next steps:"
echo "   1. In Xcode, go to Settings → Accounts → Add your Apple ID"
echo "   2. Select MediaMate target → Signing & Capabilities → Choose your Team"
echo "   3. Change Bundle Identifier to your own (e.g. com.yourname.mediamate)"
echo "   4. Product → Archive"
echo "   5. Distribute App → App Store Connect"
echo ""
echo "✅ Setup complete!"
