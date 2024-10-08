@REM This file was automatically generated by alyxlib.
@REM Run this file before uploading your addon to the workshop, then follow window instructions after uploading.
@echo off


IF NOT EXIST "..\alyxlib" (
echo AlyxLib folder wasn't found, cannot perform this batch file! Please rerun alyxlib.py to setup correctly...
PAUSE
EXIT
)

rmdir "scripts\vscripts\alyxlib"
del "scripts\vlua_globals.lua"
rmdir "scripts\vscripts\game"

echo Symlinks have been removed, continue after uploading to workshop.
PAUSE
echo.

mklink /d "C:\Program Files (x86)\Steam\steamapps\common\Half-Life Alyx\content\hlvr_addons\body_holsters\scripts\vscripts\alyxlib" "C:\Program Files (x86)\Steam\steamapps\common\Half-Life Alyx\content\hlvr_addons\alyxlib\scripts\vscripts\alyxlib"
echo.
mklink "C:\Program Files (x86)\Steam\steamapps\common\Half-Life Alyx\content\hlvr_addons\body_holsters\scripts\vlua_globals.lua" "C:\Program Files (x86)\Steam\steamapps\common\Half-Life Alyx\content\hlvr_addons\alyxlib\scripts\vlua_globals.lua"
echo.
mklink /d "C:\Program Files (x86)\Steam\steamapps\common\Half-Life Alyx\content\hlvr_addons\body_holsters\scripts\vscripts\game" "C:\Program Files (x86)\Steam\steamapps\common\Half-Life Alyx\content\hlvr_addons\alyxlib\scripts\vscripts\game"
echo.

echo Symlinks reinstated! This window can now be closed.
PAUSE
