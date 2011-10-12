if not exist %CERT_FILE% goto certificate

:: AIR output
if not exist %AIR_PATH% md %AIR_PATH%
set OUTPUT=-target ipa-ad-hoc %AIR_PATH%\%AIR_NAME%%AIR_TARGET%.ipa
rem set OUTPUT= %AIR_PATH%\%AIR_NAME%%AIR_TARGET%.air
:: Package
echo.
echo Packaging %AIR_NAME%%AIR_TARGET%.air using certificate %CERT_FILE%...
rem call adt -package %OPTIONS% %SIGNING_OPTIONS% %OUTPUT% %APP_XML% %FILE_OR_DIR%

rem make sure the version is good
rem adt -version

c:\haxe\air3\bin\adt -package -target ipa-test -provisioning-profile "bat\Windows_Machine_Cardinal_Quest.mobileprovision" -storetype pkcs12 -keystore "bat\Iphone_Dev_Cert_TjD.p12" ./bin/CQ.ipa application.xml -C ./bin .

if errorlevel 1 goto failed
goto end

:certificate
echo.
echo Certificate not found: %CERT_FILE%
echo.
echo - generate a default certificate using 'bat\CreateCertificate.bat'
echo Troubleshooting: 
echo.
if %PAUSE_ERRORS%==1 pause
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