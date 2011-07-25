For Developing AIR applications, you need the runtime and the SDK.

Runtime: http://get.adobe.com/air/
SDK: http://www.adobe.com/products/air/tools/sdk/

Install the runtime and unzip the SDK somewhere.

Finally, you need the haxe air library. This is easiest installed by executing
"haxelib install air" from a prompt.

After this, starting the test project should be as simple as pressing F5 in FlashDevelop.


Instructions for DISTRIBUTING* your application:

1. Creating a self-signed certificate:
- Edit CreateCertificate.bat to change the path to AIR SDK, unless you have set AIRSDK.
- Edit CreateCertificate.bat to set your certificate password (and name if you like)
- Run CreateCertificate.bat to generate your self-signed certificate
- Wait a minute before packaging.

2. Packaging the application:
- Edit PackageApplication.bat and change the path to AIR SDK, unless you have set AIRSDK.
- If you have a signed certificate, edit PackageApplication.bat to change the path to the certificate
- Run PackageApplication.bat, you will be prompted for the certificate password
  (note that you may not see '***' when typing your password - it works anyway)
- The packaged application should appear in your project in a new 'air' directory.

* to test your application from FlashDevelop, just press F5 as usual.
