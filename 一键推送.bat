@echo off
cd /d "E:\CodeWorkspace\New-repository"
echo Adding files...
git add -A
echo Committing...
git commit -m "Fix all"
echo Pushing to GitHub...
git push origin fixbug-synatx
echo.
echo Done! Press any key to exit.
pause
