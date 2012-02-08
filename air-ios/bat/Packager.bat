
:: AIR output
rem if not exist %AIR_PATH% md %AIR_PATH%
rem set OUTPUT=-target ipa-ad-hoc %AIR_PATH%\%AIR_NAME%%AIR_TARGET%.ipa
:: Package
echo.

rem See also:
rem   http://help.adobe.com/en_US/as3/iphone/WS144092a96ffef7cc-371badff126abc17b1f-7fff.html
rem   http://help.adobe.com/en_US/air/build/WSfffb011ac560372f3cb56e2a12cc36970aa-8000.html
rem   http://help.adobe.com/en_US/air/build/WSfffb011ac560372f-5d0f4f25128cc9cd0cb-7ffb.html
rem   http://www.youtube.com/watch?v=mpzSXAW0qUI

rem  c:\haxe\air3\bin\adt -package -target ipa-test -provisioning-profile "bat\Windows_Machine_Cardinal_Quest.mobileprovision" -storetype pkcs12 -keystore "bat\Iphone_Dev_Cert_TjD.p12" ./bin/CQ.ipa application.xml -C ./bin .


time /T

set PACKAGE=cq3.swf icon128.png icon16.png icon32.png icon48.png icon57.png icon72.png

call c:\haxe\air3\bin\adt -package -target ipa-test -provisioning-profile "bat\Cardinal_Quest_on_iPod_Touch.mobileprovision" -storetype pkcs12 -keystore "bat\iphone_dev_cert_jday.p12" -storepass cqdev ./bin/CQ.ipa application.xml -C ./bin/package .
time /T

if errorlevel 1 goto failed
goto end

:failed
echo AIR setup creation FAILED.
echo.
echo Troubleshooting: 
echo - did you build your project in FlashDevelop?
echo - verify AIR SDK target version in %APP_XML%
echo.
if %PAUSE_ERRORS%==1 pause
goto end

:end
echo.