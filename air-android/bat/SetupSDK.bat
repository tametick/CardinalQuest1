:user_configuration

:: Path to Flex SDK
set ANDROID_SDK="C:\Android\android-sdk"
set FLEX_SDK=C:\AdobeAirSDK

:validation
if not exist "%FLEX_SDK%" goto flexsdk
goto succeed

:flexsdk
echo.
echo ERROR: incorrect path to Flex SDK in 'bat\SetupSDK.bat'
echo (Attempting to continue...)
echo.
echo %FLEX_SDK%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:succeed
set PATH=%PATH%;%FLEX_SDK%\bin

