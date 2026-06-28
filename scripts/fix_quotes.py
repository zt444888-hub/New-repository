import os, re

root = r'C:\Users\0.0\Documents\Codex\2026-06-26\hyperframes-plugin-hyperframes-openai-curated-turn-2\outputs\tmp-repo'
for dirpath, dirnames, filenames in os.walk(root):
    for f in filenames:
        if not f.endswith('.swift'): continue
        path = os.path.join(dirpath, f)
        with open(path, 'r', encoding='utf-8') as fp:
            content = fp.read()
        old = content
        
        # Fix: ""text"" -> "text" (but leave standalone "" as empty string)
        content = re.sub(r'""([^"]*?)""', r'"\1"', content)
        
        # Also fix format strings like ""%.0f%%"" -> "%.0f%%"
        content = re.sub(r'""([^"]*?[%].*?)""', r'"\1"', content)
        
        if content != old:
            with open(path, 'w', encoding='utf-8') as fp:
                fp.write(content)
            print(f'Fixed: {f}')
print('Done')
