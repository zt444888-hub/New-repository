import os, re, json

root = r'C:\Users\0.0\Documents\Codex\2026-06-26\hyperframes-plugin-hyperframes-openai-curated-turn-2\outputs\tmp-repo'
files_found = 0
errors = []

for dirpath, dirnames, filenames in os.walk(root):
    for f in filenames:
        if not f.endswith('.swift'): continue
        if 'DerivedData' in dirpath or '.build' in dirpath or 'Tests' in dirpath or '.git' in dirpath or '.codex' in dirpath:
            continue
        path = os.path.join(dirpath, f)
        with open(path, 'r', encoding='utf-8') as fp:
            try:
                content = fp.read()
            except:
                errors.append(f"{f}: Cannot read file")
                continue
        
        files_found += 1
        lines = content.split('\n')
        
        # 1. Check brace balance
        opens = content.count('{')
        closes = content.count('}')
        if opens != closes:
            errors.append(f"{f}: Brace mismatch - {{ = {opens}, }} = {closes}")
        
        # 2. Check bracket balance
        opens = content.count('[')
        closes = content.count(']')
        if opens != closes:
            errors.append(f"{f}: Bracket mismatch - [ = {opens}, ] = {closes}")
        
        # 3. Check paren balance (excluding string contents)
        paren_open = 0
        in_string = False
        for c in content:
            if c == '"' and (len(content) > 0 and content[0] != '\\'):
                in_string = not in_string
            if not in_string:
                if c == '(': paren_open += 1
                elif c == ')': paren_open -= 1
        if paren_open != 0:
            errors.append(f"{f}: Parenthesis mismatch: {paren_open} unclosed")
        
        # 4. Check enum cases for commas
        in_enum = False
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped.startswith('enum ') and stripped.endswith('{'):
                in_enum = True
                continue
            if stripped == '}':
                in_enum = False
                continue
            if in_enum and 'case ' in stripped and not stripped.endswith(',') and not stripped.endswith('{'):
                # Some enum cases don't need commas - this is fine
                pass
        
        # 5. Check for common Swift syntax errors
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # Check for missing colon in ternary
            if '?' in stripped and ':' not in stripped:
                # Could be optional chaining, not just ternary
                pass
            
            # Check for incorrect closure syntax
            if '{' in stripped and stripped.count('{') > stripped.count('}'):
                # Check if the block opens but doesn't close on same line (OK for multi-line)
                pass
            
            # Check for \. in Swift 5.4+ keypath expressions
            # Check for missing self in escaping closure
            if 'escaping' in stripped or '@escaping' in stripped:
                pass
        
        # 6. Check for force unwraps that could crash
        force_unwrap_matches = re.findall(r'[\!]\s', content)
        if len(force_unwrap_matches) > 5:
            # More than 5 force unwraps is suspicious
            errors.append(f"{f}: {len(force_unwrap_matches)} force unwraps (!)")
        
        # 7. Check for implicit unwrapping
        if re.search(r'var\s+\w+\s*:\s*[A-Z]\w*!', content):
            errors.append(f"{f}: Has implicitly unwrapped optionals")
        
        # 8. Check for missing imports
        if 'View {' in content and 'import SwiftUI' not in content:
            errors.append(f"{f}: Missing import SwiftUI")
        
        if 'ObservableObject' in content and 'import Foundation' not in content and 'import Combine' not in content:
            errors.append(f"{f}: Missing import for ObservableObject")

# Report
if errors:
    print(f"Found {len(errors)} issues in {files_found} files:")
    for e in errors:
        print(f"  ❌ {e}")
else:
    print(f"✅ All clean! {files_found} files checked, 0 issues found")
