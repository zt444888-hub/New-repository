#!/usr/bin/env bash
# Run this script on Mac to commit and push the fix
cd /Users/luoxiaopeng/Desktop/MediaMate
git pull origin fixbug-synatx
# Then open in Xcode
open MediaMate.xcodeproj
