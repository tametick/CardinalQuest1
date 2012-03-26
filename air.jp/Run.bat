@echo off
set PAUSE_ERRORS=1

copy ..\bin.jp\cq.swf bin\cq.swf
rem mkdir bin\jadeds
rem copy JadeDS\Release\* bin\jadeds\

call bat\SetupSDK.bat
call bat\SetupApplication.bat

echo.
echo Starting AIR Debug Launcher...
echo.

adl -profile extendedDesktop "%APP_XML%" "%APP_DIR%"
if errorlevel 1 goto error
goto end

:error
pause

:end