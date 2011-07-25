1. About Jade:DS
----------------
Jade:DS is a complex system to sell and distribute computer game on the
internet. As most features are implemented as web services with a specialized
CMS, there needs to be a client application present on the customers computer.
This client has a small footprint in memory, but provides general access to
the games assets and the Jade:DS online features. To enable your application
to use the features of the client, you need to add the provided library or one
of its wrappers into your game.

2. How to use this SDK
----------------------
Before you can use the SDK for any meaningful application, you need to contact
us to open a product associated to your product. After this is done, you only
need to add the choosen library and the include path to your project. Now you
are ready to open a connection, while the client is running. From here, you can
add the status functions to your game and test it. If this is working correctly,
you can migrate your file access layer to the SDK interface and build a set of
archives with the given wxArchive tool. These archives can now be uploaded to the
server and are available from the client afterwards.

3. Features
-----------
The current version of the development kit allows access to the following
features of the system:
 - Access files from the file caches
 - Read the full or partial dirctory of caches
 - Read the username of the current user
 - Read and write slots for online storage
 - Query aggregated views of online storage, e.g. highscores
 - Query and receive the status of achievements
 - Query the online status of the client
 - Read and pulse the running time of the game
 - Receive notifications from the server

4. Wrappers
-----------
At the moment, we provide a wrapper for OGRE. This wrapper is delivered as pure
source code now, as it was impossible to keep up with all available OGRE releases
yet. To build the code, you simply need to add all the sources, except the plugin
related, for a static build. A plugin dll can be created with all delivered files
in the project. If you experience problems with the interface, please contact us
to adopt it.

5. Samples
----------
Currently, the samples are only ment as an example and can't be used in a running
state out of the box. They show the basic principals of the SDK in a context, which
is as simple as possible.

basic.cpp     - Connect to the client, read and display a text file, uses win32.
cdg.cpp       - Connect to the client and display a png file, uses our custom UI,
                which isn't publically availble. Shows basic concepts only.
directory.cpp - Read a directory from the caches and displays it as a tree, uses
                wxWindows as UI.
statusio.cpp  - Shows how to query status information and how to receive the
                result asynchronous, uses wxWindows as UI.
product.xml   - A sample declaration file, used for the OGRE sample browser
setup.xml     - A sample setup file, used for the binary files in the OGRE sample
				browser.
				
6. Support
----------
Developer support is provided by email. We'll try to assist you as good as
possible to integrate your product into the system. Don't hesitate to contact
us under dev@jade-ds.com or the support address provided by your personal
reseller.

7. Release Notes
----------------
Release 2011....
 - New wxArchive release with validators
 - Renamed and rearranged libraries and dlls
 - Added sources for ogre wrapper to enable manual build
 - Added a general dll of the SDK

Relase 20110705
 - Added a product.xml and a setup.xml example
 - Added an integration guide
 - Added debug builds for the libraries

Release 20110614
 - Flatten the type hierachy for better compatibility with SWIG
 - Changed most object parameter to const references

Release 20110602
 - Initial release
 