import os
import uuid
import glob

os.chdir(r'e:\CodeWorkspace\New-repository')

def UID():
    return uuid.uuid4().hex.upper()

main_swift_files = sorted([
    os.path.join('MediaMate', f) for f in os.listdir('MediaMate')
    if f.endswith('.swift')
])
views_swift_files = sorted([
    os.path.join('MediaMate', 'Views', f) for f in os.listdir('MediaMate/Views')
    if f.endswith('.swift')
])
core_swift_files = sorted([
    os.path.join('Sources', 'MediaMateCore', f) for f in os.listdir('Sources/MediaMateCore')
    if f.endswith('.swift')
])
share_swift_files = sorted([
    os.path.join('Sources', 'MediaMateShare', f) for f in os.listdir('Sources/MediaMateShare')
    if f.endswith('.swift')
])

all_swift_files = main_swift_files + views_swift_files + core_swift_files + share_swift_files

resource_files = [
    'MediaMate/Assets.xcassets',
    'MediaMate/LaunchScreen.storyboard',
    'MediaMate/Localizable.xcstrings',
    'MediaMate/PrivacyPolicy.html',
]

file_refs = {}
build_files = {}
resource_build_files = {}

frefs_section = ''
bfiles_section = ''
rbfiles_section = ''

for fpath in all_swift_files:
    fid = UID()
    bid = UID()
    name = os.path.basename(fpath)
    file_refs[fpath] = fid
    build_files[fpath] = bid
    
    frefs_section += f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{name}"; sourceTree = "<group>"; }};\n'
    bfiles_section += f'\t\t{bid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid}; }};\n'

for fpath in resource_files:
    fid = UID()
    bid = UID()
    name = os.path.basename(fpath)
    file_refs[fpath] = fid
    resource_build_files[fpath] = bid
    
    if fpath.endswith('.xcassets'):
        ftype = 'folder.assetcatalog'
    elif fpath.endswith('.storyboard'):
        ftype = 'file.storyboard'
    elif fpath.endswith('.xcstrings'):
        ftype = 'text.xml.xcstrings'
    elif fpath.endswith('.html'):
        ftype = 'text.html'
    else:
        ftype = 'file'
    
    frefs_section += f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = {ftype}; path = "{name}"; sourceTree = "<group>"; }};\n'
    rbfiles_section += f'\t\t{bid} /* {name} in Resources */ = {{isa = PBXBuildFile; fileRef = {fid}; }};\n'

app_id = UID()
frefs_section += f'\t\t{app_id} /* MediaMate.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MediaMate.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n'

views_gid = UID()
mediamate_gid = UID()
core_gid = UID()
share_gid = UID()
sources_gid = UID()
products_gid = UID()
main_gid = UID()

views_children = ''
for f in views_swift_files:
    name = os.path.basename(f)
    views_children += f'\t\t\t\t{file_refs[f]} /* {name} */,\n'

mediamate_children = ''
for f in main_swift_files:
    name = os.path.basename(f)
    mediamate_children += f'\t\t\t\t{file_refs[f]} /* {name} */,\n'
mediamate_children += f'\t\t\t\t{views_gid} /* Views */,\n'
for f in resource_files:
    name = os.path.basename(f)
    mediamate_children += f'\t\t\t\t{file_refs[f]} /* {name} */,\n'

core_children = ''
for f in core_swift_files:
    name = os.path.basename(f)
    core_children += f'\t\t\t\t{file_refs[f]} /* {name} */,\n'

share_children = ''
for f in share_swift_files:
    name = os.path.basename(f)
    share_children += f'\t\t\t\t{file_refs[f]} /* {name} */,\n'

sources_children = f'\t\t\t\t{core_gid} /* MediaMateCore */,\n'
sources_children += f'\t\t\t\t{share_gid} /* MediaMateShare */,\n'

products_children = f'\t\t\t\t{app_id} /* MediaMate.app */,\n'

main_children = f'\t\t\t\t{mediamate_gid} /* MediaMate */,\n'
main_children += f'\t\t\t\t{sources_gid} /* Sources */,\n'
main_children += f'\t\t\t\t{products_gid} /* Products */,\n'

groups_section = f'''\
\t\t{mediamate_gid} /* MediaMate */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{mediamate_children}\t\t\t);
\t\t\tpath = MediaMate;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{views_gid} /* Views */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{views_children}\t\t\t);
\t\t\tpath = Views;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{sources_gid} /* Sources */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{sources_children}\t\t\t);
\t\t\tpath = Sources;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{core_gid} /* MediaMateCore */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{core_children}\t\t\t);
\t\t\tpath = MediaMateCore;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{share_gid} /* MediaMateShare */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{share_children}\t\t\t);
\t\t\tpath = MediaMateShare;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{products_gid} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{products_children}\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{main_gid} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{main_children}\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
'''

sources_phase_id = UID()
frameworks_phase_id = UID()
resources_phase_id = UID()

sources_files_list = ''
for f in all_swift_files:
    name = os.path.basename(f)
    sources_files_list += f'\t\t\t\t{build_files[f]} /* {name} in Sources */,\n'

resources_files_list = ''
for f in resource_files:
    name = os.path.basename(f)
    resources_files_list += f'\t\t\t\t{resource_build_files[f]} /* {name} in Resources */,\n'

sources_phase = f'''\
\t\t{sources_phase_id} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{sources_files_list}\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
'''

frameworks_phase = f'''\
\t\t{frameworks_phase_id} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
'''

resources_phase = f'''\
\t\t{resources_phase_id} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{resources_files_list}\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
'''

target_id = UID()
target_config_list_id = UID()
project_config_list_id = UID()
project_id = UID()

debug_config_id = UID()
release_config_id = UID()

build_settings = '''\
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = MediaMate;
\t\t\t\tINFOPLIST_KEY_NSDocumentsFolderUsageDescription = "MediaMate needs access to your files to select media for conversion.";
\t\t\t\tINFOPLIST_KEY_NSPhotoLibraryUsageDescription = "MediaMate needs access to your photos to select video and audio files for conversion.";
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_LSRequiresIPhoneOS = YES;
\t\t\t\tSUPPORTED_PLATFORMS = iphoneos;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mediamate.app;
\t\t\t\tPRODUCT_NAME = MediaMate;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
'''

debug_config = f'''\
\t\t{debug_config_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
{build_settings}\t\t\t}};
\t\t\tname = Debug;
\t\t}};
'''

release_config = f'''\
\t\t{release_config_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
{build_settings}\t\t\t}};
\t\t\tname = Release;
\t\t}};
'''

project_config_list = f'''\
\t\t{project_config_list_id} /* Build configuration list for PBXProject "MediaMate" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_config_id} /* Debug */,
\t\t\t\t{release_config_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
'''

target_config_list = f'''\
\t\t{target_config_list_id} /* Build configuration list for PBXNativeTarget "MediaMate" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_config_id} /* Debug */,
\t\t\t\t{release_config_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
'''

target = f'''\
\t\t{target_id} /* MediaMate */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {target_config_list_id} /* Build configuration list for PBXNativeTarget "MediaMate" */;
\t\t\tbuildPhases = (
\t\t\t\t{sources_phase_id} /* Sources */,
\t\t\t\t{frameworks_phase_id} /* Frameworks */,
\t\t\t\t{resources_phase_id} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = MediaMate;
\t\t\tproductName = MediaMate;
\t\t\tproductReference = {app_id} /* MediaMate.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
'''

project = f'''\
\t\t{project_id} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tbuildConfigurationList = {project_config_list_id} /* Build configuration list for PBXProject "MediaMate" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {main_gid};
\t\t\tproductRefGroup = {products_gid} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_id} /* MediaMate */,
\t\t\t);
\t\t}};
'''

pbxproj = f'''// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{bfiles_section}{rbfiles_section}/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{frefs_section}/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
{frameworks_phase}/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{groups_section}/* End PBXGroup section */

/* Begin PBXNativeTarget section */
{target}/* End PBXNativeTarget section */

/* Begin PBXProject section */
{project}/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
{resources_phase}/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
{sources_phase}/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
{debug_config}{release_config}/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
{project_config_list}{target_config_list}/* End XCConfigurationList section */
\t}};
\trootObject = {project_id} /* Project object */;
}}
'''

with open('MediaMate.xcodeproj/project.pbxproj', 'w', encoding='utf-8') as f:
    f.write(pbxproj)

print(f'Generated pbxproj: {len(pbxproj)} bytes')
print(f'  Swift source files: {len(all_swift_files)}')
print(f'  Resource files: {len(resource_files)}')
print(f'  Total objects: {len(all_swift_files) * 2 + len(resource_files) * 2 + 1 + 7 + 3 + 1 + 1 + 2 + 2}')
print('Done!')
