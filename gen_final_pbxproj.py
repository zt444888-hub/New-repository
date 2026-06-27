import os, uuid, glob

os.chdir(r'C:\Users\0.0\Documents\Codex\2026-06-26\hyperframes-plugin-hyperframes-openai-curated-turn-2\outputs\tmp-repo'.replace('\\', '/'))

def UID():
    return uuid.uuid4().hex[:24].upper()

# All source files
all_files = sorted(glob.glob('MediaMate/*.swift') + glob.glob('MediaMate/Views/*.swift') + glob.glob('Sources/MediaMateCore/*.swift'))
print(f'Found {len(all_files)} source files')

# === Generate PBXBuildFile ===
build_refs = {}
brefs = ''
for f in all_files:
    bid = UID()
    name = os.path.basename(f)
    brefs += f'\t\t{bid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = BID_{name}; }};\n'
    build_refs[name] = bid

# === Generate PBXFileReference ===
file_refs = {}
frefs = ''
for f in all_files:
    fid = UID()
    name = os.path.basename(f)
    path = f.replace('\\', '/')
    frefs += f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{path}"; sourceTree = "<group>"; }};\n'
    file_refs[name] = fid
# Replace placeholders
for name in file_refs:
    brefs = brefs.replace(f'BID_{name}', file_refs[name])

# Assets.xcassets
assetid = UID()
frefs += f'\t\t{assetid} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "MediaMate/Assets.xcassets"; sourceTree = "<group>"; }};\n'

# === PBXGroup ===
main_gid = UID()
top_gid = UID()
prod_gid = UID()
children = ''
for f in all_files:
    name = os.path.basename(f)
    children += f'\t\t\t\t{file_refs[name]} /* {name} */,\n'
children += f'\t\t\t\t{assetid} /* Assets.xcassets */,\n'

main = f'\t\t{main_gid} = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{children}\t\t\t);\n\t\t\tname = MediaMate;\n\t\t\tsourceTree = "<group>";\n\t\t}};\n'
top = f'\t\t{top_gid} = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t{main_gid} /* MediaMate */,\n\t\t\t);\n\t\t\tsourceTree = "<group>";\n\t\t}};\n'
prod = f'\t\t{prod_gid} = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = ();\n\t\t\tname = Products;\n\t\t\tsourceTree = "<group>";\n\t\t}};\n'

# === PBXNativeTarget ===
tid = UID()
sid = UID()
tcl = UID()
target = f'\t\t{tid} /* MediaMate */ = {{\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = {tcl};\n\t\t\tbuildPhases = (\n\t\t\t\t{sid} /* Sources */,\n\t\t\t);\n\t\t\tbuildRules = ();\n\t\t\tdependencies = ();\n\t\t\tname = MediaMate;\n\t\t\tproductName = MediaMate;\n\t\t\tproductReference = {UID()};\n\t\t\tproductType = "com.apple.product-type.application";\n\t\t}};\n'

# === PBXProject ===
pid = UID()
pcl = UID()
proj = f'\t\t{pid} = {{\n\t\t\tisa = PBXProject;\n\t\t\tbuildConfigurationList = {pcl};\n\t\t\tcompatibilityVersion = "Xcode 14.0";\n\t\t\tdevelopmentRegion = en;\n\t\t\thasScannedForEncodings = 0;\n\t\t\tknownRegions = (en, Base);\n\t\t\tmainGroup = {top_gid};\n\t\t\tproductRefGroup = {prod_gid};\n\t\t\tprojectDirPath = "";\n\t\t\tprojectRoot = "";\n\t\t\ttargets = (\n\t\t\t\t{tid} /* MediaMate */,\n\t\t\t);\n\t\t}};\n'

# === PBXSourcesBuildPhase ===
sb = f'\t\t{sid} /* Sources */ = {{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n'
for f in all_files:
    name = os.path.basename(f)
    sb += f'\t\t\t\t{build_refs[name]} /* {name} in Sources */,\n'
sb += '\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};\n'

# === XCBuildConfiguration ===
did = UID()
rid = UID()
bs = f'\t\t{did} = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n'
bs += '\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n'
bs += '\t\t\t\tCODE_SIGN_STYLE = Automatic;\n'
bs += '\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n'
bs += '\t\t\t\tGENERATE_INFOPLIST_FILE = YES;\n'
bs += '\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = MediaMate;\n'
bs += '\t\t\t\tINFOPLIST_KEY_NSDocumentsFolderUsageDescription = "MediaMate needs access to your files to select media for conversion.";\n'
bs += '\t\t\t\tINFOPLIST_KEY_NSPhotoLibraryUsageDescription = "MediaMate needs access to your photos to select video and audio files for conversion.";\n'
bs += '\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;\n'
bs += '\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;\n'
bs += '\t\t\t\tINFOPLIST_KEY_LSRequiresIPhoneOS = YES;\n'
bs += '\t\t\t\tSUPPORTED_PLATFORMS = iphoneos;\n'
bs += '\t\t\t\tSDKROOT = iphoneos;\n'
bs += '\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;\n'
bs += '\t\t\t\tMARKETING_VERSION = 1.0;\n'
bs += '\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mediamate.app;\n'
bs += '\t\t\t\tPRODUCT_NAME = MediaMate;\n'
bs += '\t\t\t\tSWIFT_VERSION = 5.0;\n'
bs += '\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";\n'
bs += '\t\t\t}};\n\t\t\tname = Debug;\n\t\t}};\n'
bs2 = bs.replace('name = Debug', 'name = Release')

# === XCConfigurationList ===
cl = ''
for clid in [pcl, tcl]:
    cl += f'\t\t{clid} = {{\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n\t\t\t\t{did},\n\t\t\t\t{rid},\n\t\t\t);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t}};\n'

# === Assemble ===
pbx = '// !$*UTF8*$!\n{\n\tarchiveVersion = 1;\n\tclasses = {};\n\tobjectVersion = 56;\n\tobjects = {\n'
pbx += '\n/* Begin PBXBuildFile section */\n' + brefs + '/* End PBXBuildFile section */\n'
pbx += '\n/* Begin PBXFileReference section */\n' + frefs + '/* End PBXFileReference section */\n'
pbx += '\n/* Begin PBXGroup section */\n' + main + top + prod + '/* End PBXGroup section */\n'
pbx += '\n/* Begin PBXNativeTarget section */\n' + target + '/* End PBXNativeTarget section */\n'
pbx += '\n/* Begin PBXProject section */\n' + proj + '/* End PBXProject section */\n'
pbx += '\n/* Begin PBXSourcesBuildPhase section */\n' + sb + '/* End PBXSourcesBuildPhase section */\n'
pbx += '\n/* Begin XCBuildConfiguration section */\n' + bs + bs2 + '/* End XCBuildConfiguration section */\n'
pbx += '\n/* Begin XCConfigurationList section */\n' + cl + '/* End XCConfigurationList section */\n'
pbx += '\t};\n\trootObject = ' + pid + ';\n}\n'

with open('MediaMate.xcodeproj/project.pbxproj', 'w') as f:
    f.write(pbx)
print(f'OK: {len(pbx)} bytes, {len(all_files)} files')

