import os, re

root = r'C:/Users/0.0/Documents/Codex/2026-06-26/hyperframes-plugin-hyperframes-openai-curated-turn-2/outputs/tmp-repo'
files = 0
errs = []

for dp, dn, fn in os.walk(root):
    for f in fn:
        if not f.endswith('.swift'): continue
        if any(x in dp for x in ['DerivedData','.build','Tests','.git','.codex']): continue
        p = os.path.join(dp, f)
        with open(p, 'r', encoding='utf-8') as fp:
            c = fp.read()
        files += 1
        if c.count("{") != c.count("}"):
            errs.append(f + ": brace mismatch")
        if c.count("[") != c.count("]"):
            errs.append(f + ": bracket mismatch")
        if c.count("try!") > 0:
            errs.append(f + ": try! in production code")
        if re.search(r'var\s+\w+\s*:\s*[A-Z]\w*!', c):
            errs.append(f + ": implicitly unwrapped optional")
        if "ObservableObject" in c and "import Foundation" not in c and "import Combine" not in c:
            errs.append(f + ": missing import for ObservableObject")
        if "as!" in c:
            errs.append(f + ": forced cast (as!)")
        if "@available" in c and "iOS" not in c:
            errs.append(f + ": availability annotation without iOS")

if errs:
    print(f"{len(errs)} issues in {files} files:")
    for e in errs:
        print(f"  - {e}")
else:
    print(f"0 issues in {files} files - all clean")
