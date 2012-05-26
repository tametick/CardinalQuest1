@ECHO OFF

set PAUSE_ERRORS=1

copy ..\bin\cq.swf bin\cq.swf
rem mkdir bin\jadeds
rem copy JadeDS\Release\* bin\jadeds\

call bat\SetupSDK.bat
call bat\SetupApplication.bat

echo.
echo Starting AIR Debug Launcher...
echo NOTE, I AM EXPECTING
ECHO 1) AIR3 TO BE USED
ECHO 2) AIR3 TO BE IN A FOLDER UNDER HAXE
echo.

C:\AdobeAIRSDK\bin\adl -profile mobileDevice "%APP_XML%" "%APP_DIR%"
if errorlevel 1 goto error
goto end

:error
pause

:end