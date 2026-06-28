import os, re, glob

root = r'C:\Users\0.0\Documents\Codex\2026-06-26\hyperframes-plugin-hyperframes-openai-curated-turn-2\outputs\tmp-repo'
all_ok = True

for path in glob.glob(root + '/MediaMate/**/*.swift', recursive=True):
    with open(path) as f:
        content = f.read()
    
    lines = content.split('\n')
    depth = 0
    
    for i, line in enumerate(lines, 1):
        cleaned = re.sub(r'"[^"]*"', '', line)
        opens = cleaned.count('{')
        closes = cleaned.count('}')
        depth += opens - closes
    
    if depth != 0:
        print(f'ISSUE: {os.path.basename(path)}: depth={depth}')
        all_ok = False

if all_ok:
    print('ALL CLEAN')
