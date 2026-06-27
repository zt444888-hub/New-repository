import re
import sys

pbxproj_path = r'e:\CodeWorkspace\New-repository\MediaMate.xcodeproj\project.pbxproj'

with open(pbxproj_path, 'r', encoding='utf-8') as f:
    content = f.read()

all_object_ids = set()
referenced_ids = set()

pattern = r'^\s+([A-F0-9]{24})\s+/\*.*\*/\s*=\s*\{'
for m in re.finditer(pattern, content, re.MULTILINE):
    all_object_ids.add(m.group(1))

print(f"Total objects defined: {len(all_object_ids)}")

ref_patterns = [
    r'fileRef\s*=\s*([A-F0-9]{24})\s*;',
    r'mainGroup\s*=\s*([A-F0-9]{24})\s*;',
    r'productRefGroup\s*=\s*([A-F0-9]{24})\s*;',
    r'buildConfigurationList\s*=\s*([A-F0-9]{24})\s*;',
    r'productReference\s*=\s*([A-F0-9]{24})\s*;',
    r'rootObject\s*=\s*([A-F0-9]{24})\s*;',
]

for pat in ref_patterns:
    for m in re.finditer(pat, content):
        referenced_ids.add(m.group(1))

children_pattern = r'([A-F0-9]{24})\s+/\*[^*]+\*/'
in_children = False
for line in content.split('\n'):
    if 'children = (' in line:
        in_children = True
        continue
    if in_children and ');' in line:
        in_children = False
        continue
    if in_children:
        m = re.search(children_pattern, line)
        if m:
            referenced_ids.add(m.group(1))

buildphase_files = False
for line in content.split('\n'):
    if 'files = (' in line:
        buildphase_files = True
        continue
    if buildphase_files and ');' in line:
        buildphase_files = False
        continue
    if buildphase_files:
        m = re.search(children_pattern, line)
        if m:
            referenced_ids.add(m.group(1))

targets_pattern = False
for line in content.split('\n'):
    if 'targets = (' in line:
        targets_pattern = True
        continue
    if targets_pattern and ');' in line:
        targets_pattern = False
        continue
    if targets_pattern:
        m = re.search(children_pattern, line)
        if m:
            referenced_ids.add(m.group(1))

buildphases_pattern = False
for line in content.split('\n'):
    if 'buildPhases = (' in line:
        buildphases_pattern = True
        continue
    if buildphases_pattern and ');' in line:
        buildphases_pattern = False
        continue
    if buildphases_pattern:
        m = re.search(children_pattern, line)
        if m:
            referenced_ids.add(m.group(1))

buildconfigs_pattern = False
for line in content.split('\n'):
    if 'buildConfigurations = (' in line:
        buildconfigs_pattern = True
        continue
    if buildconfigs_pattern and ');' in line:
        buildconfigs_pattern = False
        continue
    if buildconfigs_pattern:
        m = re.search(r'([A-F0-9]{24})', line)
        if m:
            referenced_ids.add(m.group(1))

print(f"Total IDs referenced: {len(referenced_ids)}")

dangling = referenced_ids - all_object_ids
if dangling:
    print(f"\nDANGLING REFERENCES ({len(dangling)}):")
    for d in sorted(dangling):
        print(f"  {d}")
else:
    print("\nNo dangling references found!")

orphaned = all_object_ids - referenced_ids
if orphaned:
    print(f"\nORPHANED OBJECTS (not referenced anywhere, {len(orphaned)}):")
    for o in sorted(orphaned):
        section = "unknown"
        if o in [m.group(1) for m in re.finditer(r'([A-F0-9]{24})\s+/\*.*\*/\s*=\s*\{isa = PBXFileReference', content)]:
            section = "PBXFileReference"
        elif o in [m.group(1) for m in re.finditer(r'([A-F0-9]{24})\s+/\*.*\*/\s*=\s*\{isa = PBXBuildFile', content)]:
            section = "PBXBuildFile"
        elif o in [m.group(1) for m in re.finditer(r'([A-F0-9]{24})\s*=\s*\{isa = PBXGroup', content)]:
            section = "PBXGroup"
        print(f"  {o} ({section})")

brace_count = content.count('{') - content.count('}')
print(f"\nBrace balance: {brace_count} (0 = balanced)")
