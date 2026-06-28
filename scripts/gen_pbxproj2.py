import os, uuid, glob

os.chdir(r'C:\Users\0.0\Documents\Codex\2026-06-26\hyperframes-plugin-hyperframes-openai-curated-turn-2\outputs\tmp-repo')
def uid(): return uuid.uuid4().hex[:24].upper()

files = sorted(glob.glob('MediaMate/*.swift') + glob.glob('MediaMate/Views/*.swift'))

frefs = ""
brefs = ""
fr = {}
br = {}

for f in files:
    fid = uid(); bid = uid()
    n = os.path.basename(f)
    p = f.replace('\\', '/')
    frefs += "\t\t" + fid + " /* " + n + " */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"" + p + "\"; sourceTree = \"<group>\"; };\n"
    brefs += "\t\t" + bid + " /* " + n + " in Sources */ = {isa = PBXBuildFile; fileRef = " + fid + "; };\n"
    fr[n] = fid; br[n] = bid

assetid = uid()
frefs += "\t\t" + assetid + " /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = \"MediaMate/Assets.xcassets\"; sourceTree = \"<group>\"; };\n"

mg = uid(); tg = uid(); pg = uid()
c = ""
for f in files:
    n = os.path.basename(f)
    c += "\t\t\t\t" + fr[n] + " /* " + n + " */,\n"
c += "\t\t\t\t" + assetid + " /* Assets.xcassets */,\n"

g = "\t\t" + mg + " = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n" + c + "\t\t\t);\n\t\t\tname = MediaMate;\n\t\t\tsourceTree = \"<group>\";\n\t\t};\n"
g += "\t\t" + tg + " = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t" + mg + " /* MediaMate */,\n\t\t\t);\n\t\t\tsourceTree = \"<group>\";\n\t\t};\n"
g += "\t\t" + pg + " = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = ();\n\t\t\tname = Products;\n\t\t\tsourceTree = \"<group>\";\n\t\t};\n"

ti = uid(); si = uid(); tcl = uid()
t = "\t\t" + ti + " /* MediaMate */ = {\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = " + tcl + ";\n\t\t\tbuildPhases = (\n\t\t\t\t" + si + " /* Sources */,\n\t\t\t);\n\t\t\tbuildRules = ();\n\t\t\tdependencies = ();\n\t\t\tname = MediaMate;\n\t\t\tproductName = MediaMate;\n\t\t\tproductReference = " + uid() + ";\n\t\t\tproductType = \"com.apple.product-type.application\";\n\t\t};\n"

pi = uid(); pcl = uid()
pr = "\t\t" + pi + " = {\n\t\t\tisa = PBXProject;\n\t\t\tbuildConfigurationList = " + pcl + ";\n\t\t\tcompatibilityVersion = \"Xcode 14.0\";\n\t\t\tdevelopmentRegion = en;\n\t\t\thasScannedForEncodings = 0;\n\t\t\tknownRegions = (en, Base);\n\t\t\tmainGroup = " + tg + ";\n\t\t\tproductRefGroup = " + pg + ";\n\t\t\tprojectDirPath = \"\";\n\t\t\tprojectRoot = \"\";\n\t\t\ttargets = (\n\t\t\t\t" + ti + " /* MediaMate */,\n\t\t\t);\n\t\t};\n"

sb = "\t\t" + si + " /* Sources */ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n"
for f in files:
    n = os.path.basename(f)
    sb += "\t\t\t\t" + br[n] + " /* " + n + " in Sources */,\n"
sb += "\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};\n"

di = uid(); ri = uid()
bs = "\t\t" + di + " = {\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {\n"
bs += "\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n"
bs += "\t\t\t\tCODE_SIGN_STYLE = Automatic;\n"
bs += "\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n"
bs += "\t\t\t\tGENERATE_INFOPLIST_FILE = YES;\n"
bs += "\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = MediaMate;\n"
bs += "\t\t\t\tINFOPLIST_KEY_NSDocumentsFolderUsageDescription = \"MediaMate needs access to your files to select media for conversion.\";\n"
bs += "\t\t\t\tINFOPLIST_KEY_NSPhotoLibraryUsageDescription = \"MediaMate needs access to your photos to select video and audio files for conversion.\";\n"
bs += "\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;\n"
bs += "\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;\n"
bs += "\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 18.0;\n"
bs += "\t\t\t\tMARKETING_VERSION = 1.0;\n"
bs += "\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mediamate.app;\n"
bs += "\t\t\t\tPRODUCT_NAME = MediaMate;\n"
bs += "\t\t\t\tSWIFT_VERSION = 5.0;\n"
bs += "\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\n"
bs += "\t\t\t};\n\t\t\tname = Debug;\n\t\t};\n"
b2 = bs.replace('name = Debug', 'name = Release')

cl = ""
for clid in [pcl, tcl]:
    cl += "\t\t" + clid + " = {\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n\t\t\t\t" + di + ",\n\t\t\t\t" + ri + ",\n\t\t\t);\n\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t};\n"

pbx = "// !$*UTF8*$!\n{\n\tarchiveVersion = 1;\n\tclasses = {};\n\tobjectVersion = 56;\n\tobjects = {\n"
pbx += "\n/* Begin PBXBuildFile section */\n" + brefs + "/* End PBXBuildFile section */\n"
pbx += "\n/* Begin PBXFileReference section */\n" + frefs + "/* End PBXFileReference section */\n"
pbx += "\n/* Begin PBXGroup section */\n" + g + "/* End PBXGroup section */\n"
pbx += "\n/* Begin PBXNativeTarget section */\n" + t + "/* End PBXNativeTarget section */\n"
pbx += "\n/* Begin PBXProject section */\n" + pr + "/* End PBXProject section */\n"
pbx += "\n/* Begin PBXSourcesBuildPhase section */\n" + sb + "/* End PBXSourcesBuildPhase section */\n"
pbx += "\n/* Begin XCBuildConfiguration section */\n" + bs + b2 + "/* End XCBuildConfiguration section */\n"
pbx += "\n/* Begin XCConfigurationList section */\n" + cl + "/* End XCConfigurationList section */\n"
pbx += "\t};\n\trootObject = " + pi + ";\n}\n"

with open('MediaMate.xcodeproj/project.pbxproj', 'w') as f:
    f.write(pbx)
print('OK:' + str(len(pbx)) + 'bytes,' + str(len(files)) + 'files')
