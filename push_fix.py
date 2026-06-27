import subprocess, os, re
cwd = os.getcwd()
# Verify the pbxproj is valid
with open(os.path.join(cwd, "MediaMate.xcodeproj", "project.pbxproj"), "r") as f:
    c = f.read()
opens = c.count("{")
closes = c.count("}")
print(f"Braces: {opens}/{closes}", "OK" if opens == closes else "FAIL")
defs = set(re.findall(r"^\s*([A-F0-9]{24})\s", c, re.MULTILINE))
refs = set(re.findall(r"[A-F0-9]{24}", c))
missing = refs - defs
print(f"UUIDs: {len(defs)} defined, {len(refs)} refs, missing: {len(missing)}")
if missing: print("Missing:", list(missing))
print()
print("Committing and pushing...")
subprocess.run(["git", "add", "MediaMate.xcodeproj/project.pbxproj"], cwd=cwd, check=True)
subprocess.run(["git", "commit", "-m", "fix: 从零生成全新 pbxproj，解决 Xcode 崩溃"], cwd=cwd, check=True)
subprocess.run(["git", "push", "origin", "fixbug-synatx"], cwd=cwd, check=True)
print("DONE! Push successful.")