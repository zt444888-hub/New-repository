import re
import os

pbxproj_path = r'e:\CodeWorkspace\New-repository\MediaMate.xcodeproj\project.pbxproj'

with open(pbxproj_path, 'r', encoding='utf-8') as f:
    content = f.read()

print("=" * 60)
print("PBXPROJ VALIDATION REPORT")
print("=" * 60)

brace_open = content.count('{')
brace_close = content.count('}')
paren_open = content.count('(')
paren_close = content.count(')')
print(f"\n1. Brace balance: {{ = {brace_open}, }} = {brace_close}, diff = {brace_open - brace_close}")
print(f"   Paren balance: ( = {paren_open}, ) = {paren_close}, diff = {paren_open - paren_close}")

all_object_ids = set()
object_types = {}

obj_pattern = r'^\s+([A-F0-9]+)\s+(?:/\*[^*]*\*/\s+)?=\s*\{'
for m in re.finditer(obj_pattern, content, re.MULTILINE):
    oid = m.group(1)
    all_object_ids.add(oid)
    
    isa_match = re.search(r'isa\s*=\s*(\w+)\s*;', content[m.end():m.end()+200])
    if isa_match:
        isa = isa_match.group(1)
        object_types[isa] = object_types.get(isa, 0) + 1

print(f"\n2. Total objects defined: {len(all_object_ids)}")
print("   Object type breakdown:")
for isa, count in sorted(object_types.items()):
    print(f"     {isa}: {count}")

referenced_ids = set()

ref_patterns = [
    r'fileRef\s*=\s*([A-F0-9]+)\s*;',
    r'mainGroup\s*=\s*([A-F0-9]+)\s*;',
    r'productRefGroup\s*=\s*([A-F0-9]+)\s*;',
    r'buildConfigurationList\s*=\s*([A-F0-9]+)\s*;',
    r'productReference\s*=\s*([A-F0-9]+)\s*;',
    r'rootObject\s*=\s*([A-F0-9]+)\s*;',
]

for pat in ref_patterns:
    for m in re.finditer(pat, content):
        referenced_ids.add(m.group(1))

id_in_comment_pattern = r'([A-F0-9]+)\s+/\*[^*]+\*/'

array_contexts = [
    'children', 'files', 'targets', 'buildPhases', 'buildConfigurations',
    'dependencies', 'buildRules', 'knownRegions'
]

in_array = None
for line in content.split('\n'):
    for ctx in array_contexts:
        if f'{ctx} = (' in line:
            in_array = ctx
            continue
    if in_array and ');' in line:
        in_array = None
        continue
    if in_array:
        m = re.search(id_in_comment_pattern, line)
        if m:
            referenced_ids.add(m.group(1))

print(f"\n3. Total unique IDs referenced: {len(referenced_ids)}")

dangling = referenced_ids - all_object_ids
if dangling:
    print(f"\n4. *** DANGLING REFERENCES ({len(dangling)}) ***")
    for d in sorted(dangling):
        print(f"     {d}")
else:
    print(f"\n4. No dangling references - all IDs resolve correctly ✓")

orphaned = all_object_ids - referenced_ids
if orphaned:
    print(f"\n5. ORPHANED OBJECTS (not referenced anywhere, {len(orphaned)}):")
    for o in sorted(orphaned):
        section = "unknown"
        for m in re.finditer(r'([A-F0-9]+)\s+(?:/\*[^*]*\*/\s+)?=\s*\{isa\s*=\s*(\w+)', content):
            if m.group(1) == o:
                section = m.group(2)
                break
        print(f"     {o} ({section})")
else:
    print(f"\n5. No orphaned objects - everything is referenced ✓")

print(f"\n6. File size: {os.path.getsize(pbxproj_path)} bytes")
print(f"   Lines: {len(content.splitlines())}")

print("\n" + "=" * 60)
print("VALIDATION COMPLETE")
print("=" * 60)
