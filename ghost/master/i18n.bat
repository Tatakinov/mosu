@echo off
chcp 65001
cd /d "%~dp0"
lua.exe i18n.lua "%~dp0" dll
pause
