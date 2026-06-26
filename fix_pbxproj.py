import uuid, re

pbx_path = r'C:\Users\0.0\Documents\Codex\2026-06-26\hyperframes-plugin-hyperframes-openai-curated-turn-2\outputs\tmp-repo\MediaMate.xcodeproj\project.pbxproj'
with open(pbx_path, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

def new_id():
    return uuid.uuid4().hex[:24].upper()

new_files = [
    ('PaywallView.swift', 'MediaMate/Views/PaywallView.swift'),
    ('ConvertedFilesView.swift', 'MediaMate/Views/ConvertedFilesView.swift'),
    ('PresetsView.swift', 'MediaMate/Views/PresetsView.swift'),
    ('BatchPickerView.swift', 'MediaMate/Views/BatchPickerView.swift'),
]

file_entries = []
build_entries = []
file_ids = {}
for name, path in new_files:
    fid = new_id()
    bid = new_id()
    file_ids[name] = (fid, bid)
    file_entries.append(f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{path}"; sourceTree = <group>; }};')
    build_entries.append(f'\t\t{bid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid}; }};')

content = content.replace('/* End PBXFileReference section */', '\n'.join(file_entries) + '\n/* End PBXFileReference section */')
content = content.replace('/* End PBXBuildFile section */', '\n'.join(build_entries) + '\n/* End PBXBuildFile section */')

sections = content.split('/* Begin PBXSourcesBuildPhase section */')
if len(sections) > 1:
    parts = sections[1].split('/* End PBXSourcesBuildPhase section */')
    lines = parts[0].split('\n')
    last_idx = -1
    for i, line in enumerate(lines):
        if 'PBXBuildFile' in line and 'fileRef' in line:
            last_idx = i
    if last_idx >= 0:
        for name in ['BatchPickerView.swift', 'PresetsView.swift', 'ConvertedFilesView.swift', 'PaywallView.swift']:
            fid, bid = file_ids[name]
            lines.insert(last_idx + 1, f'\t\t\t\t{bid} /* {name} in Sources */,')
            last_idx += 1
    content = sections[0] + '/* Begin PBXSourcesBuildPhase section */' + '\n'.join(lines) + '/* End PBXSourcesBuildPhase section */' + parts[1]

with open(pbx_path, 'w', encoding='utf-8') as f:
    f.write(content)
print(f'OK - {len(content)} bytes')
