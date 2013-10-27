
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

if "%1"=="DISTRO" goto distribute
echo Preparing package for *testing* (DO NOT DISTRIBUTE)
call c:\AdobeAIRSDK\bin\adt -package -target ipa-test -provisioning-profile "bat\cq1_dev_oct_2013.mobileprovision" -storetype pkcs12 -keystore "bat\ios_development.p12" -storepass cqdev ./bin/CQ.ipa application.xml cq.swf Default-568h@2x.png icon128.png  icon32.png  icon512.png  icon72.png Default.png icon1024.png  icon16.png   icon48.png  icon57.png Default@2x.png Default-Portrait.png Default-Portrait@2x.png Default-PortraitUpsideDown.png Default-PortraitUpsideDown@2x.png Default-Landscape.png Default-LandscapeLeft@2x.png Default-LandscapeRight.png Default-LandscapeRight@2x.png

goto done

:distribute
echo Preparing package for distribution
call c:\AdobeAIRSDK\bin\adt -package -target ipa-app-store -provisioning-profile "bat\cq1_store_oct_2013.mobileprovision" -storetype pkcs12 -keystore "bat\ios_distribution.p12" -storepass cqdev ./bin/CQ.ipa application.xml cq.swf Default-568h@2x.png icon128.png  icon32.png  icon512.png  icon72.png Default.png icon1024.png  icon16.png   icon48.png  icon57.png Default@2x.png Default-Portrait.png Default-Portrait@2x.png Default-PortraitUpsideDown.png Default-PortraitUpsideDown@2x.png Default-Landscape.png Default-LandscapeLeft@2x.png Default-LandscapeRight.png Default-LandscapeRight@2x.png
goto done

:done

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