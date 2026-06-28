import os,uuid,glob
os.chdir(os.path.dirname(os.path.abspath(__file__)))
def uid(): return uuid.uuid4().hex[:24].upper()
files=sorted(glob.glob("MediaMate/*.swift")+glob.glob("MediaMate/Views/*.swift"))
f=b="";fr={};br={}
for f_ in files:
 n=os.path.basename(f_);fi=uid();bi=uid()
 f+=f"\t\t{fi}/* {n} */={{isa=PBXFileReference;lastKnownFileType=sourcecode.swift;path=\"MediaMate/{n}\";sourceTree=\"<group>\";}};\n"
 b+=f"\t\t{bi}/* {n} in Sources */={{isa=PBXBuildFile;fileRef={fi};}};\n"
 fr[n]=fi;br[n]=bi
ii=uid();f+=f"\t\t{ii}/* Info.plist */={{isa=PBXFileReference;lastKnownFileType=text.plist.xml;path=\"MediaMate/Info.plist\";sourceTree=\"<group>\";}};\n"
ai=uid();f+=f"\t\t{ai}/* Assets.xcassets */={{isa=PBXFileReference;lastKnownFileType=folder.assetcatalog;path=\"MediaMate/Assets.xcassets\";sourceTree=\"<group>\";}};\n"
c=""
for f_ in files: c+=f"\t\t\t\t{fr[os.path.basename(f_)]}/* {os.path.basename(f_)} */,\n"
c+=f"\t\t\t\t{ii}/* Info.plist */,\n\t\t\t\t{ai}/* Assets.xcassets */,\n"
M=uid();G=uid();P=uid()
g=f"\t\t{M}={{isa=PBXGroup;children=(\n{c}\t\t\t);path=\"\";sourceTree=\"<group>\";}};\n"
g+=f"\t\t{G}={{isa=PBXGroup;children=(\t\t\t\t{M}/* MediaMate */,\t\t\t);sourceTree=\"<group>\";}};\n"
g+=f"\t\t{P}={{isa=PBXGroup;children=();name=Products;sourceTree=\"<group>\";}};\n"
T=uid();S=uid();tc=uid()
t=f"\t\t{T}/* MediaMate */={{isa=PBXNativeTarget;buildConfigurationList={tc};buildPhases=({S}/* Sources */,);buildRules=();dependencies=();name=MediaMate;productName=MediaMate;productReference={uid()};productType=\"com.apple.product-type.application\";}};\n"
p=uid();pc=uid()
pr=f"\t\t{p}={{isa=PBXProject;buildConfigurationList={pc};compatibilityVersion=\"Xcode 14.0\";developmentRegion=en;hasScannedForEncodings=0;knownRegions=(en,Base);mainGroup={G};productRefGroup={P};projectDirPath=\"\";projectRoot=\"\";targets=({T}/* MediaMate */,);}};\n"
sb=f"\t\t{S}/* Sources */={{isa=PBXSourcesBuildPhase;buildActionMask=2147483647;files=(\n"
for f_ in files: sb+=f"\t\t\t\t{br[os.path.basename(f_)]}/* {os.path.basename(f_)} in Sources */,\n"
sb+="\t\t\t);runOnlyForDeploymentPostprocessing=0;};\n"
d=uid();r=uid()
dc=f"\t\t{d}={{isa=XCBuildConfiguration;buildSettings={{ASSETCATALOG_COMPILER_APPICON_NAME=AppIcon;INFOPLIST_FILE=MediaMate/Info.plist;IPHONEOS_DEPLOYMENT_TARGET=18.0;PRODUCT_BUNDLE_IDENTIFIER=com.mediamate.app;PRODUCT_NAME=MediaMate;SWIFT_VERSION=5.0;TARGETED_DEVICE_FAMILY=\"1,2\";ALWAYS_SEARCH_USER_PATHS=NO;}};name=Debug;}};\n"
rc=dc.replace("Debug","Release")
cl=""
for clid in[pc,tc]: cl+=f"\t\t{clid}={{isa=XCConfigurationList;buildConfigurations=({d},{r},);defaultConfigurationIsVisible=0;defaultConfigurationName=Release;}};\n"
x="// !$*UTF8*$!\n{\n\tarchiveVersion=1;\n\tclasses={};\n\tobjectVersion=56;\n\tobjects={\n"
for sec,con in[("PBXBuildFile",b),("PBXFileReference",f),("PBXGroup",g),("PBXNativeTarget",t),("PBXProject",pr),("PBXSourcesBuildPhase",sb),("XCBuildConfiguration",dc+rc),("XCConfigurationList",cl)]:
 x+="\n/* Begin "+sec+" section */\n"+con+"\n/* End "+sec+" section */\n"
x+="\t};\n\trootObject="+p+";\n}\n"
open("MediaMate.xcodeproj/project.pbxproj","w").write(x)
print("OK:",len(x),"bytes,",len(files),"files")
