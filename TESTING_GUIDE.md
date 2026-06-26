# MediaMate Mock 测试流程操作指南

## 📋 概述

本文档详细描述了如何使用 Mock 数据测试 PHPicker 文件选择功能，无需真实相册权限即可验证完整的文件选择和转换流程。

---

## 🚀 快速开始

### 环境要求
- **IDE**: Xcode 15+
- **SDK**: iOS 18+
- **目标设备**: iPhone 模拟器或真实设备

### 打开项目
```bash
# 在 Finder 中打开项目目录
open "G:\新建文件夹\MediaMate"

# 或在终端中
cd "G:\新建文件夹\MediaMate"
open MediaMate.xcodeproj
```

---

## 🧪 测试流程

### 步骤 1：运行项目

1. 在 Xcode 中选择目标设备（推荐 iPhone 15 模拟器）
2. 点击 ▶️ **Run** 按钮或按 `Cmd + R`
3. 等待应用启动

### 步骤 2：启用测试模式

| 界面元素 | 操作 | 说明 |
|----------|------|------|
| **Enable Test Mode** 按钮 | 点击 | 启用 Mock 测试模式 |
| **绿色提示条** | 显示 "Test Mode Active" | 确认测试模式已启用 |
| **Switch to Real Mode** | 点击可切换回真实模式 | 用于测试真实权限流程 |

### 步骤 3：测试文件选择

#### 场景 A：测试从相册选择
1. 点击 **Choose from Photos** 按钮
2. 系统自动选择随机 Mock 文件
3. 自动跳转到 **Convert Settings** 页面

#### 场景 B：测试从文件应用选择
1. 点击 **Choose from Files** 按钮
2. 系统自动选择随机 Mock 文件  
3. 自动跳转到 **Convert Settings** 页面

### 步骤 4：验证文件信息

在 **Convert Settings** 页面验证以下信息：

| 信息项 | 验证内容 | 示例值 |
|--------|----------|--------|
| **文件名** | 显示正确的 Mock 文件名 | `mock_video_a1b2c3d4.mp4` |
| **文件大小** | 显示文件大小（5-50 MB） | `24.5 MB` |
| **文件图标** | 根据类型显示对应图标 | 🎬 视频 / 🎵 音频 |
| **格式选项** | 默认选中 MP4 | MP4 芯片高亮 |

### 步骤 5：测试转换流程

1. 在设置页调整参数（可选）：
   - 输出格式：MP4 / MOV / M4A / MP3 / WAV
   - 质量：Low / Medium / High / Lossless
   - 分辨率：Original / 1080p / 720p / 480p

2. 点击 **Start Conversion** 按钮
3. 进入 **Progress** 页面，观察进度动画
4. 等待约 6 秒后自动跳转到 **Complete** 页面
5. 验证完成页显示：
   - ✅ 成功勾选动画
   - ✅ 文件大小对比（Before → After）
   - ✅ 压缩率显示（如 -62%）

### 步骤 6：测试历史记录

1. 切换到 **History** Tab
2. 验证刚完成的转换记录已添加到列表顶部
3. 记录状态显示为 **Done**（绿色）

---

## 📊 Mock 数据说明

### 文件生成规则

| 文件类型 | 数量 | 大小范围 | 格式 |
|----------|------|----------|------|
| 视频文件 | 3 个 | 5-50 MB | MOV / MP4（随机） |
| 音频文件 | 2 个 | 1-10 MB | M4A / MP3 / WAV（随机） |

### 文件存储位置

Mock 文件生成在设备的临时目录：
```
iOS 模拟器: ~/Library/Developer/CoreSimulator/Devices/<设备ID>/data/Containers/Data/Application/<应用ID>/tmp/
真实设备: /private/var/mobile/Containers/Data/Application/<应用ID>/tmp/
```

### 文件命名格式

```
mock_video_<8位UUID>.mov
mock_audio_<8位UUID>.mp3
```

---

## ✅ 测试用例矩阵

| 测试编号 | 测试场景 | 预期结果 |
|----------|----------|----------|
| TC-001 | 启用测试模式 | 显示绿色提示条，按钮切换行为 |
| TC-002 | 选择视频文件 | 正确识别 MOV/MP4 格式，显示视频图标 |
| TC-003 | 选择音频文件 | 正确识别 M4A/MP3/WAV 格式，显示音频图标 |
| TC-004 | 文件信息显示 | 文件名、大小、图标正确显示 |
| TC-005 | 页面导航 | 选择文件后正确跳转到设置页 |
| TC-006 | 转换进度 | 进度条正确动画，ETA 更新 |
| TC-007 | 转换完成 | 成功动画播放，大小对比显示 |
| TC-008 | 历史记录 | 新记录添加到列表顶部 |
| TC-009 | 模式切换 | 切换回真实模式后使用真实选择器 |
| TC-010 | 多次选择 | 每次选择不同的随机文件 |

---

## 🔧 故障排除

### 问题 1：Mock 文件未生成

**现象**: 点击选择按钮后无响应或报错

**排查步骤**:
1. 检查控制台输出是否有错误信息
2. 确认 `MockDataGenerator.setupMockFiles()` 已调用
3. 检查临时目录写入权限

**解决方案**:
```swift
// 在 HomeView 中确保测试模式启用时调用
Button("Enable Test Mode") {
    MockDataGenerator.shared.setupMockFiles()  // 确保此调用存在
    isTestMode = true
}
```

### 问题 2：文件信息显示不正确

**现象**: 文件名显示 "Unknown File" 或大小显示 "Unknown"

**排查步骤**:
1. 检查 `appState.currentFile` 是否正确设置
2. 验证文件 URL 是否有效
3. 检查 `getFileSize()` 函数是否正确实现

### 问题 3：页面导航失败

**现象**: 选择文件后停留在首页，未跳转

**排查步骤**:
1. 检查 `navigationPath.append(Route.convert)` 是否调用
2. 确认 `NavigationStack` 和 `navigationDestination` 配置正确
3. 验证 `Route` 枚举实现 `Hashable` 协议

### 问题 4：权限提示弹窗不显示

**现象**: 在真实模式下未授权时直接报错

**排查步骤**:
1. 检查 `Info.plist` 中权限描述是否配置
2. 验证 `PHPhotoLibrary.requestAuthorization()` 调用流程
3. 确认 `showPermissionAlert` 状态正确更新

---

## 📝 日志调试

启用调试日志，在控制台查看测试流程：

```swift
// MockDataGenerator.swift - 生成文件时打印
print("Created mock video file: \(fileUrl.path)")
print("Created mock audio file: \(fileUrl.path)")

// HomeView.swift - 选择文件时打印
print("Selected mock file: \(mockFile.lastPathComponent)")
print("File size: \(fileInfo.size)")
```

---

## 📸 测试截图参考

### 测试模式首页
```
┌─────────────────────────────┐
│      MediaMate              │
│   Video & Audio Tool        │
├─────────────────────────────┤
│ 🟢 Test Mode Active         │
│ Switch to Real Mode         │
├─────────────────────────────┤
│ [Choose from Photos]        │
│ [Choose from Files]         │
├─────────────────────────────┤
│ Recent Conversions          │
│ ┌─────────────────────────┐ │
│ │ 🎬 vacation_clip.mov    │ │
│ │ MOV → MP4 · 128 MB      │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

### 转换设置页
```
┌─────────────────────────────┐
│    Convert Settings         │
├─────────────────────────────┤
│ Selected File               │
│ ┌─────────────────────────┐ │
│ │ 🎬 mock_video_xxx.mp4   │ │
│ │ 24.5 MB                 │ │
│ └─────────────────────────┘ │
├─────────────────────────────┤
│ Output Format               │
│ [MP4] [MOV] [M4A] [MP3] [WA│V]
├─────────────────────────────┤
│ Quality                     │
│ [Low] [Medium] [High] [Lossl│ess]
│ ███████████──────────────── │
├─────────────────────────────┤
│ Resolution                  │
│ [Original] [1080p]         │
│ [720p]    [480p]           │
├─────────────────────────────┤
│ [Start Conversion]          │
│ Cancel                      │
└─────────────────────────────┘
```

---

## 📄 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0 | 2026-06-22 | 初始版本，包含 Mock 测试流程 |

---

## 📞 支持

如有问题，请检查以下文件：
- [HomeView.swift](file:///G:/新建文件夹/MediaMate/MediaMate/HomeView.swift) - 测试模式逻辑
- [MockDataGenerator.swift](file:///G:/新建文件夹/MediaMate/MediaMate/MockDataGenerator.swift) - Mock 数据生成
- [AppState.swift](file:///G:/新建文件夹/MediaMate/MediaMate/AppState.swift) - 状态管理