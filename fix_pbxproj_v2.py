import os, uuid, glob

os.chdir(os.path.dirname(os.path.abspath(__file__)))

swift_files = sorted(glob.glob('MediaMate/*.swift'))
views_files = sorted(glob.glob('MediaMate/Views/*.swift'))
all_files = swift_files + views_files

def uid():
    return uuid.uuid4().hex[:24].upper()

pbx = '// !$*UTF8*$!\n'
pbx += '{\n\tarchiveVersion = 1;\n\tclasses = {};\n\tobjectVersion = 56;\n\tobjects = {\n'

# PBXBuildFile
pbx += '\n/* Begin PBXBuildFile section */\n'
build_refs = {}
for f in all_files:
    bid = uid()
    build_refs[f] = bid
    name = os.path.basename(f)
    pbx += f'\t\t{bid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {uid()}; }};\n'
pbx += '/* End PBXBuildFile section */\n'

# PBXFileReference
pbx += '\n/* Begin PBXFileReference section */\n'
file_refs = {}
for f in all_files:
    fid = uid()
    file_refs[f] = fid
    name = os.path.basename(f)
    pbx += f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "MediaMate/{name}"; sourceTree = "<group>"; }};\n'
fid = uid()
file_refs['Info.plist'] = fid
pbx += f'\t\t{fid} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "Info.plist"; sourceTree = "<group>"; }};\n'
fid = uid()
file_refs['Assets'] = fid
pbx += f'\t\t{fid} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Assets.xcassets"; sourceTree = "<group>"; }};\n'
pbx += '/* End PBXFileReference section */\n'

# PBXGroup
main_group_id = uid()
top_group_id = uid()
products_group_id = uid()
pbx += '\n/* Begin PBXGroup section */\n'
children = ''
for f in all_files:
    children += f'\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */,\n'
children += f'\t\t\t\t{file_refs["Info.plist"]} /* Info.plist */,\n'
children += f'\t\t\t\t{file_refs["Assets"]} /* Assets.xcassets */,\n'
pbx += f'\t\t{main_group_id} = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{children}\t\t\t);\n\t\t\tpath = MediaMate;\n\t\t\tsourceTree = "<group>";\n\t\t}};\n'
pbx += f'\t\t{top_group_id} = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t{main_group_id} /* MediaMate */,\n\t\t\t);\n\t\t\tsourceTree = "<group>";\n\t\t}};\n'
pbx += f'\t\t{products_group_id} = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t);\n\t\t\tname = Products;\n\t\t\tsourceTree = "<group>";\n\t\t}};\n'
pbx += '/* End PBXGroup section */\n'

# PBXNativeTarget
target_id = uid()
sources_id = uid()
configlist_target = uid()
pbx += '\n/* Begin PBXNativeTarget section */\n'
pbx += f'\t\t{target_id} /* MediaMate */ = {{\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = {configlist_target};\n\t\t\tbuildPhases = (\n\t\t\t\t{sources_id} /* Sources */,\n\t\t\t);\n\t\t\tbuildRules = ();\n\t\t\tdependencies = ();\n\t\t\tname = MediaMate;\n\t\t\tproductName = MediaMate;\n\t\t\tproductReference = {uid()};\n\t\t\tproductType = "com.apple.product-type.application";\n\t\t}};\n'
pbx += '/* End PBXNativeTarget section */\n'

# PBXProject
project_id = uid()
configlist_project = uid()
pbx += '\n/* Begin PBXProject section */\n'
pbx += f'\t\t{project_id} = {{\n\t\t\tisa = PBXProject;\n\t\t\tbuildConfigurationList = {configlist_project};\n\t\t\tcompatibilityVersion = "Xcode 14.0";\n\t\t\tdevelopmentRegion = en;\n\t\t\thasScannedForEncodings = 0;\n\t\t\tknownRegions = (en, Base);\n\t\t\tmainGroup = {top_group_id};\n\t\t\tproductRefGroup = {products_group_id};\n\t\t\tprojectDirPath = "";\n\t\t\tprojectRoot = "";\n\t\t\ttargets = (\n\t\t\t\t{target_id} /* MediaMate */,\n\t\t\t);\n\t\t}};\n'
pbx += '/* End PBXProject section */\n'

# PBXSourcesBuildPhase
pbx += f'\n/* Begin PBXSourcesBuildPhase section */\n'
pbx += f'\t\t{sources_id} /* Sources */ = {{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n'
for f in all_files:
    name = os.path.basename(f)
    pbx += f'\t\t\t\t{build_refs[f]} /* {name} in Sources */,\n'
pbx += f'\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n'
pbx += '/* End PBXSourcesBuildPhase section */\n'

# XCBuildConfiguration
debug_id = uid()
release_id = uid()
pbx += '\n/* Begin XCBuildConfiguration section */\n'
for cfg_id, cfg_name in [(debug_id, 'Debug'), (release_id, 'Release')]:
    pbx += f'\t\t{cfg_id} = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n\t\t\t\tINFOPLIST_FILE = MediaMate/Info.plist;\n\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;\n\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mediamate.app;\n\t\t\t\tPRODUCT_NAME = MediaMate;\n\t\t\t\tSWIFT_VERSION = 5.0;\n\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";\n\t\t\t}};\n\t\t\tname = {cfg_name};\n\t\t}};\n'
pbx += '/* End XCBuildConfiguration section */\n'

# XCConfigurationList
pbx += '\n/* Begin XCConfigurationList section */\n'
for cl_id in [configlist_project, configlist_target]:
    pbx += f'\t\t{cl_id} = {{\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n\t\t\t\t{debug_id},\n\t\t\t\t{release_id},\n\t\t\t);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t}};\n'
pbx += '/* End XCConfigurationList section */\n'

pbx += '\t};\n\trootObject = ' + project_id + ';\n}\n'

with open('MediaMate.xcodeproj/project.pbxproj', 'w') as f:
    f.write(pbx)
print(f'OK: {len(pbx)} bytes, {len(all_files)} files')

