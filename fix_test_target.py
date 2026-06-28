import re, os

path = "MediaMate.xcodeproj/project.pbxproj"
content = open(path, encoding="utf-8").read()

# Generate a unique UUID for the test product reference
import random
test_prod_uuid = "".join(random.choices("0123456789ABCDEF", k=24))
print("New test product UUID:", test_prod_uuid)

# 1. Add PBXFileReference for MediaMateTests.xctest
old_line = "\t\t1E401C06A0EC7F711BA8C284 /* MediaMate.app */"
new_line = f"\t\t{test_prod_uuid} /* MediaMateTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MediaMateTests.xctest; path = MediaMateTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};\n\t\t1E401C06A0EC7F711BA8C284 /* MediaMate.app */"
if old_line in content:
    content = content.replace(old_line, new_line)
    print("1. Added PBXFileReference for MediaMateTests.xctest")
else:
    print("1. ERROR: Could not find MediaMate.app product ref")
    for i, line in enumerate(content.split("\n")):
        if "MediaMate.app" in line:
            print(f"   Line {i+1}: {line}")

# 2. Add productReference to test target
old_target = 'name = MediaMateTests; productName = MediaMateTests; productType = "com.apple.product-type.bundle.unit-test"; };'
new_target = f'name = MediaMateTests; productName = MediaMateTests; productReference = {test_prod_uuid}; productType = "com.apple.product-type.bundle.unit-test"; }};'
if old_target in content:
    content = content.replace(old_target, new_target)
    print("2. Added productReference to test target")
else:
    print("2. ERROR: Could not find test target line")
    for i, line in enumerate(content.split("\n")):
        if "MediaMateTests" in line and "PBXNativeTarget" in line:
            print(f"   Line {i+1}: {line}")

# 3. Add to product group
old_group = "1E401C06A0EC7F711BA8C284 /* MediaMate.app */,"
new_group = f"1E401C06A0EC7F711BA8C284 /* MediaMate.app */,\n\t\t\t\t{test_prod_uuid} /* MediaMateTests.xctest */,"
content = content.replace(old_group, new_group)
print("3. Added to product group")

# Verify
print("\n--- Verification ---")
print("Has test product ref:", f"productReference = {test_prod_uuid};" in content)
print("Has test PBXFileReference:", test_prod_uuid in content)

# Count objects and UUIDs
uuids_found = set(re.findall(r"[A-F0-9]{24}", content))
print(f"Total UUIDs: {len(uuids_found)}")

open(path, "w", encoding="utf-8", newline="\n").write(content)
print("\nSaved!")
