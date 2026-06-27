import os, re

# Change to the tmp dir
os.chdir(r'C:\Users\0.0\Documents\Codex\2026-06-26\hyperframes-plugin-hyperframes-openai-curated-turn-2\outputs\tmp-repo')

with open('MediaMate/ConversionEngine.swift', 'r') as f:
    content = f.read()

lines = content.split('\n')
depth = 0
errors = []

for i, line in enumerate(lines, 1):
    stripped = line.strip()
    if stripped.startswith('//'): continue
    
    opens = stripped.count('{')
    closes = stripped.count('}')
    
    # Skip string literals - a rough approach
    # Remove string contents
    cleaned = re.sub(r'"[^"]*"', '', stripped)
    opens = cleaned.count('{')
    closes = cleaned.count('}')
    
    new_depth = depth + opens - closes
    if new_depth < 0:
        errors.append(f'Line {i}: Negative depth! {depth} -> {new_depth}')
        new_depth = 0
    depth = new_depth

print(f'Final depth: {depth}')
if errors:
    for e in errors:
        print(e)
if depth > 0:
    print(f'UNBALANCED: {depth} extra open braces')
elif depth < 0:
    print(f'UNBALANCED: {-depth} extra closing braces')
else:
    print('All balanced!')
