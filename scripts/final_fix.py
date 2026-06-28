import os, re
root = r'C:\Users\0.0\Documents\Codex\2026-06-26\hyperframes-plugin-hyperframes-openai-curated-turn-2\outputs\tmp-repo'
count = 0
for dirpath, dirnames, filenames in os.walk(root):
    for f in filenames:
        if not f.endswith('.swift'): continue
        path = os.path.join(dirpath, f)
        with open(path, 'r', encoding='utf-8') as fp:
            content = fp.read()
        old = content
        content = re.sub(r'""([A-Za-z])', r'"\1', content)
        content = re.sub(r'([A-Za-z])""', r'\1"', content)
        content = content.replace('""%.0f%%""', '"%.0f%%"')
        content = content.replace('""-62%""', '"-62%"')
        if content != old:
            with open(path, 'w', encoding='utf-8') as fp:
                fp.write(content)
            count += 1
            print(f'Fixed: {f}')
print(f'Done: {count} files')
