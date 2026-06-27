import os, uuid, glob

os.chdir(r'C:\Users\0.0\Documents\Codex\2026-06-26\hyperframes-plugin-hyperframes-openai-curated-turn-2\outputs\tmp-repo')

def uid():
    return uuid.uuid4().hex[:24].upper()

files = sorted(glob.glob('MediaMate/*.swift') + glob.glob('MediaMate/Views/*.swift'))

file_refs = {}
build_refs = {}
frefs = ''
brefs = ''

for f in files:
    fid = uid()
    bid = uid()
    name = os.path.basename(f)
    filepath = f.replace('\\', '/')
    frefs += '\t\t' + fid + ' /* ' + name + ' */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "' + filepath + '"; sourceTree = "<group>"; };\n'
    brefs += '\t\t' + bid + ' /* ' + name + ' in Sources */ = {isa = PBXBuildFile; fileRef = ' + fid + '; };\n'
    file_refs[name] = fid
    build_refs[name] = bid

infoid = uid()
frefs += '\t\t' + infoid + ' /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "MediaMate/Info.plist"; sourceTree = "<group>"; };\n'
assetid = uid()
frefs += '\t\t' + assetid + ' /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "MediaMate/Assets.xcassets"; sourceTree = "<group>"; };\n'

main_gid = uid()
top_gid = uid()
prod_gid = uid()
children = ''
for f in files:
    name = os.path.basename(f)
    children += '\t\t\t\t' + file_refs[name] + ' /* ' + name + ' */,\n'
children += '\t\t\t\t' + infoid + ' /* Info.plist */,\n'
children += '\t\t\t\t' + assetid + ' /* Assets.xcassets */,\n'

main_group = '\t\t' + main_gid + ' = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n' + children + '\t\t\t);\n\t\t\tname = MediaMate;\n\t\t\tsourceTree = "<group>";\n\t\t};\n'
top_group = '\t\t' + top_gid + ' = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t' + main_gid + ' /* MediaMate */,\n\t\t\t);\n\t\t\tsourceTree = "<group>";\n\t\t};\n'
prod_group = '\t\t' + prod_gid + ' = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = ();\n\t\t\tname = Products;\n\t\t\tsourceTree = "<group>";\n\t\t};\n'

tid = uid(); sid = uid(); tclist = uid()
target = '\t\t' + tid + ' /* MediaMate */ = {\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = ' + tclist + ';\n\t\t\tbuildPhases = (\n\t\t\t\t' + sid + ' /* Sources */,\n\t\t\t);\n\t\t\tbuildRules = ();\n\t\t\tdependencies = ();\n\t\t\tname = MediaMate;\n\t\t\tproductName = MediaMate;\n\t\t\tproductReference = ' + uid() + ';\n\t\t\tproductType = "com.apple.product-type.application";\n\t\t};\n'

pid = uid(); pclist = uid()
project = '\t\t' + pid + ' = {\n\t\t\tisa = PBXProject;\n\t\t\tbuildConfigurationList = ' + pclist + ';\n\t\t\tcompatibilityVersion = "Xcode 14.0";\n\t\t\tdevelopmentRegion = en;\n\t\t\thasScannedForEncodings = 0;\n\t\t\tknownRegions = (en, Base);\n\t\t\tmainGroup = ' + top_gid + ';\n\t\t\tproductRefGroup = ' + prod_gid + ';\n\t\t\tprojectDirPath = "";\n\t\t\tprojectRoot = "";\n\t\t\ttargets = (\n\t\t\t\t' + tid + ' /* MediaMate */,\n\t\t\t);\n\t\t};\n'

sbp = '\t\t' + sid + ' /* Sources */ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n'
for f in files:
    name = os.path.basename(f)
    sbp += '\t\t\t\t' + build_refs[name] + ' /* ' + name + ' in Sources */,\n'
sbp += '\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};\n'

did = uid(); rid = uid()
debug = '\t\t' + did + ' = {\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {\n\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n\t\t\t\tCODE_SIGN_STYLE = Automatic;\n\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n\t\t\t\tGENERATE_INFOPLIST_FILE = YES;\n\t\t\t\tINFOPLIST_FILE = MediaMate/Info.plist;\n\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;\n\t\t\t\tMARKETING_VERSION = 1.0;\n\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mediamate.app;\n\t\t\t\tPRODUCT_NAME = MediaMate;\n\t\t\t\tSWIFT_VERSION = 5.0;\n\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";\n\t\t\t};\n\t\t\tname = Debug;\n\t\t};\n'
release = debug.replace('name = Debug', 'name = Release')

cl = ''
for clid in [pclist, tclist]:
    cl += '\t\t' + clid + ' = {\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n\t\t\t\t' + did + ',\n\t\t\t\t' + rid + ',\n\t\t\t);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t};\n'

pbx = '// !$*UTF8*$!\n{\n\tarchiveVersion = 1;\n\tclasses = {};\n\tobjectVersion = 56;\n\tobjects = {\n'
pbx += '\n/* Begin PBXBuildFile section */\n' + brefs + '/* End PBXBuildFile section */\n'
pbx += '\n/* Begin PBXFileReference section */\n' + frefs + '/* End PBXFileReference section */\n'
pbx += '\n/* Begin PBXGroup section */\n' + main_group + top_group + prod_group + '/* End PBXGroup section */\n'
pbx += '\n/* Begin PBXNativeTarget section */\n' + target + '/* End PBXNativeTarget section */\n'
pbx += '\n/* Begin PBXProject section */\n' + project + '/* End PBXProject section */\n'
pbx += '\n/* Begin PBXSourcesBuildPhase section */\n' + sbp + '/* End PBXSourcesBuildPhase section */\n'
pbx += '\n/* Begin XCBuildConfiguration section */\n' + debug + release + '/* End XCBuildConfiguration section */\n'
pbx += '\n/* Begin XCConfigurationList section */\n' + cl + '/* End XCConfigurationList section */\n'
pbx += '\t};\n\trootObject = ' + pid + ';\n}\n'

with open('MediaMate.xcodeproj/project.pbxproj', 'w') as f:
    f.write(pbx)
print('OK: ' + str(len(pbx)) + ' bytes, ' + str(len(files)) + ' files')
