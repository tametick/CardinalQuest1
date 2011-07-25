#include <exception>
#include <windows.h>
#include <jadesdk\jadesdk.h>

class JadeListener : public JadeSDK::StateSyncListener {

private:
	JadeSDK::TickType tickType;

public:
	JadeListener(){
	}

	~JadeListener(){
	}

	// Not implemented yet
	virtual void onError(JadeSDK::ErrorCode errorCode,const std::string &errorText) {
	}

	// Not implemented yet
	virtual void onBuddy(const std::string &buddyName,const std::string &buddyAvatar) {
	}
			
	// Not implemented yet
	virtual void onProfileAvatar(const std::string &profileAvatar) {
	}

	// Not implemented yet
	virtual void onBuddyAvatar(const std::string &profile,const std::string &avatar) {
	}
			
	// Method:      onMessage
	// Parameter:   type    - Type of the message
	//              message - The text of the message
	//              icon    - An icon representation of the message as unparsed
	//                        PNG file
	// Description: This callback is triggered, if there is a pending message. See
	//              recvMessage for more details.
	virtual void onMessage(JadeSDK::MessageType type,const std::string &message,const std::string &icon) {
	}
			
	// Not implemented yet
	virtual void onBilling(JadeSDK::BillingStatus billingStatus,JadeSDK::LockStatus lockStatus,int expiring) {
	}
			
	// Method:      onOnline
	// Parameter:   isConnected - True, if the client is connected to a user server,
	//                            otherwise false
	// Description: This callback is triggered, if the online status of the client
	//              has changed. See isOnline for more details.
	virtual void onOnline(bool isConnected) {
	}
			
	// Method:      onAchievement
	// Parameter:   achievement - Name of the achievement
	//              unlocked    - Unix time stamp when the achievement has been unlocked
	//                            or zero if not
	//              display     - A flag to determine, if the achievement needs to be
	//                            displayed
	// Description: This callback is triggered, if there is a pending achievement. See
	//              recvAchievement for more details.
	virtual void onAchievement(const std::string &achievement,JadeSDK::Time unlocked,bool display) {
	}
			
	// Method:      onStorageSlot
	// Parameter:   slot  - Name of the pending storage slot
	//              index - Index of the pending data
	//              data  - Content of the storage slot at the specified index
	// Description: This callback is triggered, if there is a pending storage slot. See
	//              recvStorageSlot for more details.
	virtual void onStorageSlot(const std::string &slot,JadeSDK::UInt32 index,const std::string &data) {
	}
			
	// Method:      onStorageView
	// Parameter:   view - Name of the read view
	//              data - Resulting table with data
	// Description: This callback is triggered, if there is a pending storage view. See
	//              recvStorageView for more details.
	virtual void onStorageView(const std::string &view,const std::string &data) {
	}
};


int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nCmdLine) {
	try {

		JadeListener jl;

		if(JadeSDK::Connection::init("ogresamples") != JadeSDK::Success)
			throw std::exception("Jade:DS Client not running or\r\nproduct not installed properly.");

		MessageBox(NULL,"Connected this successfully!","Success",MB_OK);

		JadeSDK::MemoryFile *filePtr = JadeSDK::Connection::getConnection()->openMemoryFile("particle/smoke.particle");

		if(filePtr != 0L)
			MessageBox(NULL,(LPCSTR) filePtr->data(),"particle/smoke.particle",MB_OK);
		else
			MessageBox(NULL,"File not found!","particle/smoke.particle",MB_OK);

		delete filePtr;

		JadeSDK::Connection::getConnection()->close();
	} catch(std::exception &e) {
		MessageBox(NULL,e.what(),"Error during start",MB_OK|MB_ICONHAND);
	}

	return 0;
}