
#include <fstream>
#include <shlobj.h>
#include <windows.h>
#include <cdg/frame.h>
#include <jadeds/logging.h>
#include <jadeds/utilities.h>
#include <jadesdk/jadesdk.h>

namespace MessageWindow
{
	int returnStatus;
	HWND hMessageWindow;
}

namespace CDGSample
{
	enum SampleCtrls
	{
		Sample_Frame = 1000,
	};
	
	static cairo_status_t streamIn(void *closure,unsigned char *data,unsigned int length)
	{
		JadeSDK::StreamFile *filePtr = (JadeSDK::StreamFile *) closure;

		filePtr->read(data,length);

		return CAIRO_STATUS_SUCCESS;
	}

	class Frame : public CDG::Frame
	{
	private:
		static Frame *thisPtr;
		cairo_surface_t *logoPtr;
	public:
		Frame() : CDG::Frame("CDGSample",Sample_Frame,UNSET,UNSET,200,100,CDG::CenterX | CDG::CenterY)
		{
			logoPtr = 0L;

			setMessageWindow();

			JadeSDK::StreamFile *filePtr = JadeSDK::Connection::getConnection()->openStreamFile("sdktrays/sdk_cursor.png",8192);
//			JadeSDK::MemoryFile *filePtr = JadeSDK::Connection::getConnection()->openMemoryFile("facial.png");

			if(filePtr != 0L)
			{
				logoPtr = cairo_image_surface_create_from_png_stream(streamIn,filePtr);

				filePtr->close();
			}
			else
				throw std::exception("facial.png not found!");
		}

		virtual ~Frame()
		{
			thisPtr = 0L;

			CDG::globalQuit(0);
		}

		virtual void onPaint(cairo_t *contextPtr) 
		{
			CDG::Frame::onPaint(contextPtr);

			if(logoPtr != 0L)
				cairo_set_source_surface(contextPtr,logoPtr,0,0);

			cairo_paint(contextPtr);
		}

		static Frame *getSingleton(void) 
		{
			if(thisPtr == 0L)
				thisPtr = new Frame();

			return thisPtr;
		}
	};

	Frame *Frame::thisPtr = 0L;
}

int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nCmdLine)
{
	MSG Msg;
	char cbUserPath[MAX_PATH];

	SHGetFolderPath(NULL,CSIDL_PERSONAL|CSIDL_FLAG_CREATE,(HANDLE) NULL,SHGFP_TYPE_CURRENT,cbUserPath);
	strcat(cbUserPath,"\\JadeDSSampleB_CDG.log");

	JadeDSLog::Stream::log().outChannel(JadeDSLog::DebugString,JadeDSLog::Detail,true,true);
	JadeDSLog::Stream::log().outChannel(JadeDSLog::File,JadeDSLog::Detail,true,true);
	JadeDSLog::Stream::log().setFileChannel(cbUserPath);
	JadeDSLog::Stream::log() << JadeDSLog::Info << "JadeDS SampleB" << JadeDSLog::EndL;

	try
	{
		JadeSDK::Connection::Status status;

		if((status = JadeSDK::Connection::init("ogresamples")) != JadeSDK::Connection::Success)
			throw std::exception(std::string("Jade:DS Client not running or\r\nproduct not installed properly.\r\nError code: " + JadeDSUtilities::itostr(status) + " (" + JadeSDK::Connection::statusToStr(status) + ")").c_str());

		CDG::initCDG_Win32(hInstance);
		CDGSample::Frame::getSingleton()->setVisible(true);
	
		while(GetMessage(&Msg,NULL,0,0) != FALSE)
		{
			TranslateMessage(&Msg);
			DispatchMessage(&Msg);
		}
	
		JadeSDK::Connection::getConnection()->close();
	}

	catch(std::exception &e)
	{
		MessageBox(NULL,e.what(),"Error during start",MB_OK|MB_ICONHAND);
	}

	return 0;
}
