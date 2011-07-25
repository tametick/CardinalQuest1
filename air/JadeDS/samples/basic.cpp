
#include <exception>
#include <windows.h>
#include <jadesdk/jadesdk.h>

int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nCmdLine)
{
	try
	{
		if(JadeSDK::Connection::init("ogresamples") == false)
			throw std::exception("Jade:DS Client not running or\r\nproduct not installed properly.");

		MessageBox(NULL,"Connected this successfully!","Success",MB_OK);

		JadeSDK::MemoryFile *filePtr = JadeSDK::Connection::getConnection()->openMemoryFile("particle/smoke.particle");

		if(filePtr != 0L)
			MessageBox(NULL,(LPCSTR) filePtr->data(),"particle/smoke.particle",MB_OK);
		else
			MessageBox(NULL,"File not found!","particle/smoke.particle",MB_OK);

		delete filePtr;

		JadeSDK::Connection::getConnection()->close();
	}

	catch(std::exception &e)
	{
		MessageBox(NULL,e.what(),"Error during start",MB_OK|MB_ICONHAND);
	}

	return 0;
}
