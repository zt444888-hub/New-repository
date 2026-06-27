@echo off
cd /d E:\CodeWorkspace\New-repository
echo Adding pbxproj...
call git add MediaMate.xcodeproj/project.pbxproj
echo Committing...
call git commit -m "Fix pbxproj: bump objectVersion to 60, fix Xcode 26 compatibility, remove ShareViewController from main target"
echo Pushing to fixbug-synatx...
call git push origin fixbug-synatx
echo Done!
pause
