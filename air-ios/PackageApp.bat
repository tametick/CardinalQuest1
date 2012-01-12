@ECHO OFF

set PAUSE_ERRORS=1

copy ..\bin\cq.swf bin\cq.swf

call bat\SetupSDK.bat
call bat\SetupApplication.bat

set AIR_TARGET=
set OPTIONS=
call bat\Packager.bat

pause