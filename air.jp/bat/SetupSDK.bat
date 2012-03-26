:user_configuration

:: Path to Flex SDK
set FLEX_SDK=C:\Program Files (x86)\FlashDevelop\Tools\flexsdk
rem set FLEX_SDK=C:\haxe\air3
set JAVA_PATH=C:\program files (x86)\java\jre6

:validation
if not exist "%FLEX_SDK%" goto flexsdk
if not exist "%JAVA_PATH%" goto javapath
goto succeed

:flexsdk
echo.
echo ERROR: incorrect path to Flex SDK in 'bat\SetupSDK.bat'
echo.
echo %FLEX_SDK%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:javapath
echo.
echo ERROR: incorrect path to Java JRE in 'bat\SetupSDK.bat'
echo.
echo %JAVA_PATH%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:succeed
set PATH=%PATH%;%FLEX_SDK%\bin;%JAVA_PATH%\bin
