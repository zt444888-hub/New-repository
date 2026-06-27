#!/usr/bin/env python3
"""
修复 MediaMate.xcodeproj/project.pbxproj 的脚本。
解决 Xcode 启动时崩溃的问题：-[__NSSetM addObject:]: object cannot be nil
"""
import os
import uuid

# 切换到项目根目录
os.chdir(os.path.dirname(os.path.abspath(__file__)))

def uid():
    return uuid.uuid4().hex[:24].upper()

# ============================================================
# 收集所有源文件
# ============================================================
media_mate_root = sorted([
    f for f in os.listdir('MediaMate')
    if f.endswith('.swift') and os.path.isfile(os.path.join('MediaMate', f))
])
media_mate_views = sorted([
    f for f in os.listdir('MediaMate/Views')
    if f.endswith('.swift')
])
media_mate_core = sorted([
    f for f in os.listdir('Sources/MediaMateCore')
    if f.endswith('.swift')
])
media_mate_share = sorted([
    f for f in os.listdir('Sources/MediaMateShare')
    if f.endswith('.swift')
])

# 资源文件
resources = [
    ('Info.plist', 'MediaMate/Info.plist', 'text.plist.xml'),
    ('Assets.xcassets', 'MediaMate/Assets.xcassets', 'folder.assetcatalog'),
    ('LaunchScreen.storyboard', 'MediaMate/LaunchScreen.storyboard', 'file.storyboard'),
    ('Localizable.xcstrings', 'MediaMate/Localizable.xcstrings', 'text.json.xcstrings'),
    ('PrivacyPolicy.html', 'MediaMate/PrivacyPolicy.html', 'text.html'),
]

# Share Extension 资源
share_resources = [
    ('ShareInfo.plist', 'Sources/MediaMateShare/Info.plist', 'text.plist.xml'),
]

# ============================================================
# 生成 UUID 映射
# ============================================================

# PBXFileReference UUIDs
file_refs = {}  # key: (group, name), value: uuid

# 主应用源文件
for name in media_mate_root:
    file_refs[('MediaMate', name)] = uid()
for name in media_mate_views:
    file_refs[('MediaMate', f'Views/{name}')] = uid()
for name in media_mate_core:
    file_refs[('MediaMateCore', name)] = uid()
for name in media_mate_share:
    file_refs[('MediaMateShare', name)] = uid()

# 资源文件
for res_name, res_path, res_type in resources:
    file_refs[('MediaMate', res_name)] = uid()

# Share Extension 资源
for res_name, res_path, res_type in share_resources:
    file_refs[('MediaMateShare', res_name)] = uid()

# Product
product_ref = uid()

# Group UUIDs
media_mate_group_id = uid()
media_mate_core_group_id = uid()
media_mate_share_group_id = uid()
sources_group_id = uid()
products_group_id = uid()
root_group_id = uid()

# Target
target_id = uid()
target_config_list_id = uid()

# Project
project_id = uid()
project_config_list_id = uid()

# Build phases
sources_build_phase_id = uid()
frameworks_build_phase_id = uid()
resources_build_phase_id = uid()

# Build configs
debug_config_id = uid()
release_config_id = uid()

# PBXBuildFile UUIDs
build_file_refs = {}  # key: (group, name), value: uuid

all_source_files = []
all_source_files.extend([('MediaMate', name) for name in media_mate_root])
all_source_files.extend([('MediaMate', f'Views/{name}') for name in media_mate_views])
all_source_files.extend([('MediaMateCore', name) for name in media_mate_core])
all_source_files.extend([('MediaMateShare', name) for name in media_mate_share])

for key in all_source_files:
    build_file_refs[key] = uid()

# 资源 build files
resource_build_files = {}
for res_name, res_path, res_type in resources:
    if res_name != 'Info.plist':  # Info.plist 不需要在 Resources build phase
        resource_build_files[('MediaMate', res_name)] = uid()
for res_name, res_path, res_type in share_resources:
    resource_build_files[('MediaMateShare', res_name)] = uid()

# ============================================================
# 构建 pbxproj 内容
# ============================================================

pbx = '// !$*UTF8*$!\n'
pbx += '{\n'
pbx += '\tarchiveVersion = 1;\n'
pbx += '\tclasses = {};\n'
pbx += '\tobjectVersion = 56;\n'
pbx += '\tobjects = {\n'

# --- PBXBuildFile section ---
pbx += '\n/* Begin PBXBuildFile section */\n'
for key in all_source_files:
    bid = build_file_refs[key]
    fid = file_refs[key]
    name = key[1].split('/')[-1]
    pbx += f'\t\t{bid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};\n'
for key, bid in resource_build_files.items():
    fid = file_refs[key]
    name = key[1]
    pbx += f'\t\t{bid} /* {name} in Resources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};\n'
pbx += '/* End PBXBuildFile section */\n'

# --- PBXFileReference section ---
# 路径说明：
#   - Root group 没有 path，代表 .xcodeproj 所在目录
#   - MediaMate group 有 path="MediaMate"，文件路径相对于此目录
#   - Sources group 有 path="Sources"，子 group 和文件路径相对于此目录
pbx += '\n/* Begin PBXFileReference section */\n'
for key, fid in file_refs.items():
    group, name = key
    if group == 'MediaMate':
        if name.endswith('.swift'):
            file_type = 'sourcecode.swift'
            # 路径相对于 MediaMate group (path="MediaMate")
            # root .swift: "AppState.swift", Views: "Views/BatchPickerView.swift"
            ref_path = name
            pbx += f'\t\t{fid} /* {name.split("/")[-1]} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = "{ref_path}"; sourceTree = "<group>"; }};\n'
        elif name == 'Info.plist':
            pbx += f'\t\t{fid} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "Info.plist"; sourceTree = "<group>"; }};\n'
        elif name == 'Assets.xcassets':
            pbx += f'\t\t{fid} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Assets.xcassets"; sourceTree = "<group>"; }};\n'
        elif name == 'LaunchScreen.storyboard':
            pbx += f'\t\t{fid} /* LaunchScreen.storyboard */ = {{isa = PBXFileReference; lastKnownFileType = file.storyboard; path = "LaunchScreen.storyboard"; sourceTree = "<group>"; }};\n'
        elif name == 'Localizable.xcstrings':
            pbx += f'\t\t{fid} /* Localizable.xcstrings */ = {{isa = PBXFileReference; lastKnownFileType = text.json.xcstrings; path = "Localizable.xcstrings"; sourceTree = "<group>"; }};\n'
        elif name == 'PrivacyPolicy.html':
            pbx += f'\t\t{fid} /* PrivacyPolicy.html */ = {{isa = PBXFileReference; lastKnownFileType = text.html; path = "PrivacyPolicy.html"; sourceTree = "<group>"; }};\n'
    elif group == 'MediaMateCore':
        # 路径相对于 MediaMateCore group (path="Sources/MediaMateCore")
        pbx += f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{name}"; sourceTree = "<group>"; }};\n'
    elif group == 'MediaMateShare':
        # 路径相对于 MediaMateShare group (path="Sources/MediaMateShare")
        if name.endswith('.swift'):
            pbx += f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{name}"; sourceTree = "<group>"; }};\n'
        elif name == 'ShareInfo.plist':
            pbx += f'\t\t{fid} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "Info.plist"; sourceTree = "<group>"; }};\n'

# Product reference
pbx += f'\t\t{product_ref} /* MediaMate.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MediaMate.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n'
pbx += '/* End PBXFileReference section */\n'

# --- PBXGroup section ---
pbx += '\n/* Begin PBXGroup section */\n'

# MediaMate group
pbx += f'\t\t{media_mate_group_id} /* MediaMate */ = {{\n'
pbx += f'\t\t\tisa = PBXGroup;\n'
pbx += f'\t\t\tchildren = (\n'
for name in media_mate_root:
    fid = file_refs[('MediaMate', name)]
    pbx += f'\t\t\t\t{fid} /* {name} */,\n'
for name in media_mate_views:
    fid = file_refs[('MediaMate', f'Views/{name}')]
    pbx += f'\t\t\t\t{fid} /* {name} */,\n'
for res_name, res_path, res_type in resources:
    fid = file_refs[('MediaMate', res_name)]
    pbx += f'\t\t\t\t{fid} /* {res_name} */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tpath = MediaMate;\n'
pbx += f'\t\t\tsourceTree = "<group>";\n'
pbx += f'\t\t}};\n'

# MediaMateCore group (child of Sources group, path relative to Sources)
pbx += f'\t\t{media_mate_core_group_id} /* MediaMateCore */ = {{\n'
pbx += f'\t\t\tisa = PBXGroup;\n'
pbx += f'\t\t\tchildren = (\n'
for name in media_mate_core:
    fid = file_refs[('MediaMateCore', name)]
    pbx += f'\t\t\t\t{fid} /* {name} */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tpath = MediaMateCore;\n'
pbx += f'\t\t\tsourceTree = "<group>";\n'
pbx += f'\t\t}};\n'

# MediaMateShare group (child of Sources group, path relative to Sources)
pbx += f'\t\t{media_mate_share_group_id} /* MediaMateShare */ = {{\n'
pbx += f'\t\t\tisa = PBXGroup;\n'
pbx += f'\t\t\tchildren = (\n'
for name in media_mate_share:
    fid = file_refs[('MediaMateShare', name)]
    pbx += f'\t\t\t\t{fid} /* {name} */,\n'
for res_name, res_path, res_type in share_resources:
    fid = file_refs[('MediaMateShare', res_name)]
    pbx += f'\t\t\t\t{fid} /* Info.plist */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tpath = MediaMateShare;\n'
pbx += f'\t\t\tsourceTree = "<group>";\n'
pbx += f'\t\t}};\n'

# Sources group (parent of MediaMateCore and MediaMateShare)
pbx += f'\t\t{sources_group_id} /* Sources */ = {{\n'
pbx += f'\t\t\tisa = PBXGroup;\n'
pbx += f'\t\t\tchildren = (\n'
pbx += f'\t\t\t\t{media_mate_core_group_id} /* MediaMateCore */,\n'
pbx += f'\t\t\t\t{media_mate_share_group_id} /* MediaMateShare */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tpath = Sources;\n'
pbx += f'\t\t\tsourceTree = "<group>";\n'
pbx += f'\t\t}};\n'

# Products group
pbx += f'\t\t{products_group_id} /* Products */ = {{\n'
pbx += f'\t\t\tisa = PBXGroup;\n'
pbx += f'\t\t\tchildren = (\n'
pbx += f'\t\t\t\t{product_ref} /* MediaMate.app */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tname = Products;\n'
pbx += f'\t\t\tsourceTree = "<group>";\n'
pbx += f'\t\t}};\n'

# Root group
pbx += f'\t\t{root_group_id} = {{\n'
pbx += f'\t\t\tisa = PBXGroup;\n'
pbx += f'\t\t\tchildren = (\n'
pbx += f'\t\t\t\t{media_mate_group_id} /* MediaMate */,\n'
pbx += f'\t\t\t\t{sources_group_id} /* Sources */,\n'
pbx += f'\t\t\t\t{products_group_id} /* Products */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tsourceTree = "<group>";\n'
pbx += f'\t\t}};\n'

pbx += '/* End PBXGroup section */\n'

# --- PBXNativeTarget section ---
pbx += '\n/* Begin PBXNativeTarget section */\n'
pbx += f'\t\t{target_id} /* MediaMate */ = {{\n'
pbx += f'\t\t\tisa = PBXNativeTarget;\n'
pbx += f'\t\t\tbuildConfigurationList = {target_config_list_id};\n'
pbx += f'\t\t\tbuildPhases = (\n'
pbx += f'\t\t\t\t{sources_build_phase_id} /* Sources */,\n'
pbx += f'\t\t\t\t{frameworks_build_phase_id} /* Frameworks */,\n'
pbx += f'\t\t\t\t{resources_build_phase_id} /* Resources */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tbuildRules = (\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tdependencies = (\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tname = MediaMate;\n'
pbx += f'\t\t\tproductName = MediaMate;\n'
pbx += f'\t\t\tproductReference = {product_ref};\n'
pbx += f'\t\t\tproductType = "com.apple.product-type.application";\n'
pbx += f'\t\t}};\n'
pbx += '/* End PBXNativeTarget section */\n'

# --- PBXProject section ---
pbx += '\n/* Begin PBXProject section */\n'
pbx += f'\t\t{project_id} /* Project object */ = {{\n'
pbx += f'\t\t\tisa = PBXProject;\n'
pbx += f'\t\t\tattributes = {{\n'
pbx += f'\t\t\t\tBuildIndependentTargetsInParallel = 1;\n'
pbx += f'\t\t\t\tLastSwiftUpdateCheck = 1640;\n'
pbx += f'\t\t\t\tLastUpgradeCheck = 1640;\n'
pbx += f'\t\t\t}};\n'
pbx += f'\t\t\tbuildConfigurationList = {project_config_list_id};\n'
pbx += f'\t\t\tcompatibilityVersion = "Xcode 14.0";\n'
pbx += f'\t\t\tdevelopmentRegion = en;\n'
pbx += f'\t\t\thasScannedForEncodings = 0;\n'
pbx += f'\t\t\tknownRegions = (\n'
pbx += f'\t\t\t\ten,\n'
pbx += f'\t\t\t\tBase,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\tmainGroup = {root_group_id};\n'
pbx += f'\t\t\tproductRefGroup = {products_group_id};\n'
pbx += f'\t\t\tprojectDirPath = "";\n'
pbx += f'\t\t\tprojectRoot = "";\n'
pbx += f'\t\t\ttargets = (\n'
pbx += f'\t\t\t\t{target_id} /* MediaMate */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t}};\n'
pbx += '/* End PBXProject section */\n'

# --- PBXSourcesBuildPhase section ---
pbx += '\n/* Begin PBXSourcesBuildPhase section */\n'
pbx += f'\t\t{sources_build_phase_id} /* Sources */ = {{\n'
pbx += f'\t\t\tisa = PBXSourcesBuildPhase;\n'
pbx += f'\t\t\tbuildActionMask = 2147483647;\n'
pbx += f'\t\t\tfiles = (\n'
for key in all_source_files:
    bid = build_file_refs[key]
    name = key[1].split('/')[-1]
    pbx += f'\t\t\t\t{bid} /* {name} in Sources */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\trunOnlyForDeploymentPostprocessing = 0;\n'
pbx += f'\t\t}};\n'
pbx += '/* End PBXSourcesBuildPhase section */\n'

# --- PBXFrameworksBuildPhase section ---
pbx += '\n/* Begin PBXFrameworksBuildPhase section */\n'
pbx += f'\t\t{frameworks_build_phase_id} /* Frameworks */ = {{\n'
pbx += f'\t\t\tisa = PBXFrameworksBuildPhase;\n'
pbx += f'\t\t\tbuildActionMask = 2147483647;\n'
pbx += f'\t\t\tfiles = (\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\trunOnlyForDeploymentPostprocessing = 0;\n'
pbx += f'\t\t}};\n'
pbx += '/* End PBXFrameworksBuildPhase section */\n'

# --- PBXResourcesBuildPhase section ---
pbx += '\n/* Begin PBXResourcesBuildPhase section */\n'
pbx += f'\t\t{resources_build_phase_id} /* Resources */ = {{\n'
pbx += f'\t\t\tisa = PBXResourcesBuildPhase;\n'
pbx += f'\t\t\tbuildActionMask = 2147483647;\n'
pbx += f'\t\t\tfiles = (\n'
for key, bid in resource_build_files.items():
    name = key[1]
    pbx += f'\t\t\t\t{bid} /* {name} in Resources */,\n'
pbx += f'\t\t\t);\n'
pbx += f'\t\t\trunOnlyForDeploymentPostprocessing = 0;\n'
pbx += f'\t\t}};\n'
pbx += '/* End PBXResourcesBuildPhase section */\n'

# --- XCBuildConfiguration section ---
def build_config(config_id, config_name):
    result = f'\t\t{config_id} /* {config_name} */ = {{\n'
    result += f'\t\t\tisa = XCBuildConfiguration;\n'
    result += f'\t\t\tbuildSettings = {{\n'
    result += f'\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n'
    result += f'\t\t\t\tCODE_SIGN_STYLE = Automatic;\n'
    result += f'\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n'
    result += f'\t\t\t\tGENERATE_INFOPLIST_FILE = YES;\n'
    result += f'\t\t\t\tINFOPLIST_FILE = MediaMate/Info.plist;\n'
    result += f'\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = MediaMate;\n'
    result += f'\t\t\t\tINFOPLIST_KEY_NSDocumentsFolderUsageDescription = "MediaMate needs access to your files to select media for conversion.";\n'
    result += f'\t\t\t\tINFOPLIST_KEY_NSPhotoLibraryUsageDescription = "MediaMate needs access to your photos to select video and audio files for conversion.";\n'
    result += f'\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;\n'
    result += f'\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;\n'
    result += f'\t\t\t\tINFOPLIST_KEY_LSRequiresIPhoneOS = YES;\n'
    result += f'\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;\n'
    result += f'\t\t\t\tMARKETING_VERSION = 1.0;\n'
    result += f'\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mediamate.app;\n'
    result += f'\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";\n'
    result += f'\t\t\t\tSUPPORTED_PLATFORMS = iphoneos;\n'
    result += f'\t\t\t\tSDKROOT = iphoneos;\n'
    result += f'\t\t\t\tSWIFT_VERSION = 5.0;\n'
    result += f'\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";\n'
    result += f'\t\t\t}};\n'
    result += f'\t\t\tname = {config_name};\n'
    result += f'\t\t}};\n'
    return result

pbx += '\n/* Begin XCBuildConfiguration section */\n'
pbx += build_config(debug_config_id, 'Debug')
pbx += build_config(release_config_id, 'Release')
pbx += '/* End XCBuildConfiguration section */\n'

# --- XCConfigurationList section ---
pbx += '\n/* Begin XCConfigurationList section */\n'
for cl_id, cl_name in [(project_config_list_id, 'Project'), (target_config_list_id, 'Target')]:
    pbx += f'\t\t{cl_id} /* Build configuration list for PBX{cl_name} "MediaMate" */ = {{\n'
    pbx += f'\t\t\tisa = XCConfigurationList;\n'
    pbx += f'\t\t\tbuildConfigurations = (\n'
    pbx += f'\t\t\t\t{debug_config_id} /* Debug */,\n'
    pbx += f'\t\t\t\t{release_config_id} /* Release */,\n'
    pbx += f'\t\t\t);\n'
    pbx += f'\t\t\tdefaultConfigurationIsVisible = 0;\n'
    pbx += f'\t\t\tdefaultConfigurationName = Release;\n'
    pbx += f'\t\t}};\n'
pbx += '/* End XCConfigurationList section */\n'

pbx += '\t};\n'
pbx += f'\trootObject = {project_id} /* Project object */;\n'
pbx += '}\n'

# ============================================================
# 写入文件
# ============================================================
output_path = 'MediaMate.xcodeproj/project.pbxproj'
with open(output_path, 'w', encoding='utf-8') as f:
    f.write(pbx)

print(f'[OK] 已生成 {output_path}')
print(f'     文件大小: {len(pbx)} 字节')
print(f'     源文件数: {len(all_source_files)}')
print(f'     资源文件数: {len(resource_build_files)}')
print(f'     组结构: MediaMate / Sources (MediaMateCore + MediaMateShare) / Products')
print()
print('验证方法:')
print('  1. 在 macOS 上运行: plutil -lint MediaMate.xcodeproj/project.pbxproj')
print('  2. 用 Xcode 打开 MediaMate.xcodeproj')