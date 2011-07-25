
#include <wx/wx.h>
#include <wx/thread.h>
#include <wx/tglbtn.h>
#include <wx/tokenzr.h>
#include <wx/mstream.h>
#include <wx/notebook.h>
#include <wx/listctrl.h>
#include <wx/imaglist.h>
#include <jadeds/logging.h>
#include <jadeds/utilities.h>
#include <jadesdk/jadesdk.h>

#include "wxPNGImage.h"

namespace 
{
	enum
	{
		ID_GUI_TIMER,
		ID_PAUSED_TIMER,
		ID_PLAYING_TIMER,
		ID_PROFILE,
		ID_TABS,
		ID_STORAGE_LIST,
		ID_STORAGE_EDIT,
		ID_STORAGE_SEND,
		ID_MESSAGE_LIST,
		ID_ACHIEVEMENT_LIST,
		ID_HIGHSCORE_LIST,
	};

	class SampleFrame : public wxFrame,
						public wxThreadHelper,
						public JadeSDK::Connection::StateSyncListener
	{
	private:
		JadeSDK::Connection::TickType tickType;
		wxToggleButton *guiTimerPtr;
		wxToggleButton *pausedTimerPtr;
		wxToggleButton *playingTimerPtr;
		wxTextCtrl *storageTextPtr;
		wxButton *storageSendPtr;
		wxStatusBar *statusPtr;
		wxPNGImage *profileImagePtr;
		wxListCtrl *storageListPtr;
		wxListCtrl *messageListPtr;
		wxListCtrl *achievementListPtr;
		wxListCtrl *highscoreListPtr;
		wxImageList *imagesPtr;
	public:
		SampleFrame() : wxFrame((wxFrame *) NULL,-1,formatTitle(),wxPoint(50,50))
		{
			int statusW[] = { -1,75 };

			tickType = JadeSDK::Connection::GUI;

			statusPtr = CreateStatusBar();
			statusPtr->SetFieldsCount(2,statusW);
			statusPtr->SetStatusText(_T("StatusIO example."),0);
			statusPtr->SetStatusText(_T("0:00"),1);

			guiTimerPtr = new wxToggleButton(this,ID_GUI_TIMER,_T("GUI"));
			guiTimerPtr->SetValue(true);
			pausedTimerPtr = new wxToggleButton(this,ID_PAUSED_TIMER,_T("Paused"));
			playingTimerPtr = new wxToggleButton(this,ID_PLAYING_TIMER,_T("Playing"));
			profileImagePtr = new wxPNGImage(this,ID_PROFILE,NULL,0,wxDefaultPosition,wxSize(80,80));

			wxBoxSizer *dlgTimerPtr = new wxStaticBoxSizer(wxVERTICAL,this,_T("Timer Mode"));
			dlgTimerPtr->Add(guiTimerPtr,1,wxEXPAND,2);
			dlgTimerPtr->Add(pausedTimerPtr,1,wxEXPAND,2);
			dlgTimerPtr->Add(playingTimerPtr,1,wxEXPAND,2);
			dlgTimerPtr->SetSizeHints(this);

			wxBoxSizer *dlgLeftPtr = new wxBoxSizer(wxVERTICAL);
			dlgLeftPtr->Add(profileImagePtr,0,wxEXPAND,2);
			dlgLeftPtr->Add(dlgTimerPtr,1,wxEXPAND,2);
			dlgLeftPtr->SetSizeHints(this);

			wxNotebook *tabPtr = new wxNotebook(this,ID_TABS);
			wxPanel *storagePagePtr = new wxPanel(tabPtr,wxID_ANY);

			storageListPtr = new wxListCtrl(storagePagePtr,ID_STORAGE_LIST,wxDefaultPosition,wxDefaultSize,wxLC_REPORT|wxLC_SINGLE_SEL);
			storageListPtr->InsertColumn(0,_T("StorageSlot"),wxLIST_FORMAT_LEFT,120);
			storageListPtr->InsertColumn(1,_T("Index"),wxLIST_FORMAT_LEFT,50);
			storageListPtr->InsertColumn(2,_T("Value"),wxLIST_FORMAT_LEFT,167);
			storageTextPtr = new wxTextCtrl(storagePagePtr,ID_STORAGE_EDIT);
			storageTextPtr->Disable();
			storageSendPtr = new wxButton(storagePagePtr,ID_STORAGE_SEND,_T("Send"));
			storageSendPtr->Disable();

			wxBoxSizer *storageEditPtr = new wxBoxSizer(wxHORIZONTAL);
			storageEditPtr->Add(storageTextPtr,1,wxEXPAND,2);
			storageEditPtr->Add(storageSendPtr,0,wxFIXED_MINSIZE,2);

			wxBoxSizer *storageSizerPtr = new wxBoxSizer(wxVERTICAL);
			storageSizerPtr->Add(storageListPtr,1,wxEXPAND,2);
			storageSizerPtr->Add(storageEditPtr,0,wxEXPAND,2);
			storageSizerPtr->SetSizeHints(tabPtr);

			storagePagePtr->SetSizer(storageSizerPtr);

			wxPanel *messagePagePtr = new wxPanel(tabPtr,wxID_ANY);

			imagesPtr = new wxImageList(32,32,false);
			messageListPtr = new wxListCtrl(messagePagePtr,ID_MESSAGE_LIST,wxDefaultPosition,wxDefaultSize,wxLC_REPORT|wxLC_SINGLE_SEL);
			messageListPtr->SetImageList(imagesPtr,wxIMAGE_LIST_SMALL);
			messageListPtr->InsertColumn(0,_T("Icon"),wxLIST_FORMAT_CENTER,40);
			messageListPtr->InsertColumn(1,_T("Message"),wxLIST_FORMAT_LEFT,300);

			wxBoxSizer *messageSizerPtr = new wxBoxSizer(wxVERTICAL);
			messageSizerPtr->Add(messageListPtr,1,wxEXPAND,2);
			messageSizerPtr->SetSizeHints(tabPtr);

			messagePagePtr->SetSizer(messageSizerPtr);

			wxPanel *achievementPagePtr = new wxPanel(tabPtr,wxID_ANY);

			achievementListPtr = new wxListCtrl(achievementPagePtr,ID_ACHIEVEMENT_LIST,wxDefaultPosition,wxDefaultSize,wxLC_REPORT|wxLC_SINGLE_SEL);
			achievementListPtr->InsertColumn(0,_T("Achievement"),wxLIST_FORMAT_LEFT,260);
			achievementListPtr->InsertColumn(1,_T("Unlocked"),wxLIST_FORMAT_LEFT,80);

			wxBoxSizer *achievementSizerPtr = new wxBoxSizer(wxVERTICAL);
			achievementSizerPtr->Add(achievementListPtr,1,wxEXPAND,2);
			achievementSizerPtr->SetSizeHints(tabPtr);

			achievementPagePtr->SetSizer(achievementSizerPtr);

			wxPanel *highscorePagePtr = new wxPanel(tabPtr,wxID_ANY);

			highscoreListPtr = new wxListCtrl(highscorePagePtr,ID_HIGHSCORE_LIST,wxDefaultPosition,wxDefaultSize,wxLC_REPORT|wxLC_SINGLE_SEL);
			highscoreListPtr->InsertColumn(0,_T("Rank"),wxLIST_FORMAT_LEFT,60);
			highscoreListPtr->InsertColumn(1,_T("Player"),wxLIST_FORMAT_LEFT,160);
			highscoreListPtr->InsertColumn(2,_T("Score"),wxLIST_FORMAT_LEFT,60);
			highscoreListPtr->InsertColumn(3,_T("Visited"),wxLIST_FORMAT_LEFT,60);

			wxBoxSizer *highscoreSizerPtr = new wxBoxSizer(wxVERTICAL);
			highscoreSizerPtr->Add(highscoreListPtr,1,wxEXPAND,2);
			highscoreSizerPtr->SetSizeHints(tabPtr);

			highscorePagePtr->SetSizer(highscoreSizerPtr);

			tabPtr->AddPage(storagePagePtr,_T("Storage"),true);
			tabPtr->AddPage(messagePagePtr,_T("Messages"),true);
			tabPtr->AddPage(achievementPagePtr,_T("Achievements"),true);
			tabPtr->AddPage(highscorePagePtr,_T("Highscores"),true);

			wxBoxSizer *dlgSizerPtr = new wxBoxSizer(wxHORIZONTAL);
			dlgSizerPtr->Add(dlgLeftPtr,0,wxEXPAND,2);
			dlgSizerPtr->Add(tabPtr,1,wxEXPAND,2);
			dlgSizerPtr->SetSizeHints(this);

			SetSizer(dlgSizerPtr);
			SetInitialSize(wxSize(450,250));
			CreateThread(wxTHREAD_JOINABLE);

			addStorageSlot("SampleBezierPatchVisited",0);
			addStorageSlot("SampleBSPVisited",0);
			addStorageSlot("SampleFresnelVisited",0);
			addStorageSlot("SamplesVisited",0);
			addStorageSlot("Highscore",0);

			JadeSDK::Connection::getConnection()->queryAchievement("test1");
			JadeSDK::Connection::getConnection()->queryAchievement("test2");
			JadeSDK::Connection::getConnection()->queryAchievement("test3");
			JadeSDK::Connection::getConnection()->queryAchievement("test4");
			JadeSDK::Connection::getConnection()->queryAchievement("test5");
			JadeSDK::Connection::getConnection()->queryAchievement("test6");

			GetThread()->Run();
		}

		virtual ~SampleFrame()
		{
			delete imagesPtr;
		}

		wxString formatTitle(void)
		{
			wxString profileName = wxString(JadeSDK::Connection::getConnection()->getProfileName().c_str());
			wxString connected = JadeSDK::Connection::getConnection()->isOnline() ? "Online" : "Offline";

			return wxString(_T("StatusIO Sample (")) + profileName + wxString(_T(") ") + connected);
		}

		void addStorageSlot(std::string slotName,JadeDSTypes::UInt32 index)
		{
			std::string value;
			wxListItem item;

			item.SetId(storageListPtr->GetItemCount());
			item.SetText(slotName);
			long idx = storageListPtr->InsertItem(item);
			storageListPtr->SetItem(idx,1,JadeDSUtilities::itostr(index));

			if(JadeSDK::Connection::getConnection()->queryStorageSlot(JadeSDK::Connection::SlotIndex(slotName,index)) == JadeSDK::Connection::Success)
				storageListPtr->SetItem(idx,2,value);
		}

		void switchTickType(JadeSDK::Connection::TickType newType)
		{
			JadeDSLog::Stream::log() << "Switch tick type." << JadeDSLog::EndL;

			JadeSDK::Connection::TickType oldType = tickType;

			tickType = newType;

			if(JadeSDK::Connection::getConnection()->notifyTick(oldType,false) == false)
				JadeDSLog::Stream::log() << JadeDSLog::Error << "NotifyTickType failed!" << JadeDSLog::EndL;
		}

		void OnTimerChange(wxCommandEvent &event)
		{
			if(event.GetEventObject() == guiTimerPtr)
			{
				guiTimerPtr->SetValue(true);
				pausedTimerPtr->SetValue(false);
				playingTimerPtr->SetValue(false);

				switchTickType(JadeSDK::Connection::GUI);
			}
			else if(event.GetEventObject() == pausedTimerPtr)
			{
				guiTimerPtr->SetValue(false);
				pausedTimerPtr->SetValue(true);
				playingTimerPtr->SetValue(false);

				switchTickType(JadeSDK::Connection::Paused);
			}
			else if(event.GetEventObject() == playingTimerPtr)
			{
				guiTimerPtr->SetValue(false);
				pausedTimerPtr->SetValue(false);
				playingTimerPtr->SetValue(true);

				switchTickType(JadeSDK::Connection::Playing);
			}
		}

		virtual wxThread::ExitCode Entry()
		{
			while(GetThread()->TestDestroy() == false)
			{
				JadeSDK::Connection::getConnection()->notifyTick(tickType,true);

				if(JadeSDK::Connection::getConnection()->updateStateSync(100) != JadeSDK::Connection::NoState)
					::wxWakeUpIdle();
			}

			return 0L;
		}

		virtual void onBuddy(std::string &buddyName,std::string &buddyAvatar)
		{

		}
			
		virtual void onAvatar(std::string &profileAvatar)
		{

		}

		virtual void onAvatar(std::string &profile,std::string &avatar)
		{

		}

		virtual void onMessage(JadeSDK::Connection::MessageType type,std::string &message,std::string &icon)
		{
			wxListItem item;

			wxMemoryInputStream istream(icon.c_str(),icon.length());
			wxImage pngBitmap(istream,wxBITMAP_TYPE_PNG);

			int width = pngBitmap.GetWidth();

			int imgIdx = imagesPtr->Add(pngBitmap);

			item.SetId(messageListPtr->GetItemCount());
			item.SetImage(imgIdx);
			long idx = messageListPtr->InsertItem(item);
			messageListPtr->SetItem(idx,1,wxString(message.c_str()));
		}

		virtual void onBilling(JadeSDK::Connection::BillingStatus billingStatus,JadeSDK::Connection::LockStatus lockStatus,int expiring)
		{

		}

		virtual void onOnline(bool isConnected)
		{
			JadeDSLog::Stream::log() << "Online status changed: " << (isConnected ? "TRUE" : "FALSE") << JadeDSLog::EndL;

			SetTitle(formatTitle());
		}

		virtual void onAchievement(std::string &achievement,JadeSDK::Time unlocked,bool display)
		{
			JadeDSLog::Stream::log() << "Achievement received: " << achievement << JadeDSLog::EndL;

			if(display == true)
			{
				wxListItem itemAchievement;
				wxListItem unlockAchievement;
				long idx = getIndexByColumn(achievementListPtr,achievement,0);

				itemAchievement.SetText(achievement);
				itemAchievement.SetColumn(0);

				if(idx >= 0)
				{
					itemAchievement.SetId(idx);
					achievementListPtr->SetItem(itemAchievement);
				}
				else
					idx = achievementListPtr->InsertItem(itemAchievement);

				unlockAchievement.SetId(idx);
				unlockAchievement.SetText(unlocked == 0 ? "" : JadeDSUtilities::itostr(unlocked));
				unlockAchievement.SetColumn(1);
				achievementListPtr->SetItem(unlockAchievement);
			}
			else
			{
				long idx = getIndexByColumn(achievementListPtr,achievement,0);

				if(idx >= 0)
					achievementListPtr->DeleteItem(idx);
			}
		}

		long getIndexByColumn(wxListCtrl *listPtr,std::string value,int column)
		{
			wxString wxSlot = wxString(value.c_str());
			long listIdx = -1;

			while((listIdx = listPtr->GetNextItem(listIdx)) >= 0)
			{
				wxListItem item;

				item.SetMask(wxLIST_MASK_TEXT);
				item.SetId(listIdx);
				item.SetColumn(column);
				listPtr->GetItem(item);

				if(item.GetText() == wxSlot)
					return listIdx;
			}

			return -1;
		}

		void onStorageSlot(std::string &slot,JadeSDK::UInt32 index,std::string &data)
		{
			JadeDSLog::Stream::log() << "onStorageSlot: " << slot << "[" << index << "]=" << data << JadeDSLog::EndL;

			storageListPtr->SetItem(getIndexByColumn(storageListPtr,slot,0),2,wxString(data.c_str()));

			if(slot == "Highscore")
				JadeSDK::Connection::getConnection()->queryStorageView("highscore",20,0);
		}

		virtual void onStorageView(std::string &view,std::string &data)
		{
			wxStringTokenizer perLine(wxString(data.c_str()),_T("\n"));
			
			highscoreListPtr->DeleteAllItems();

			if(perLine.HasMoreTokens() == true)
			{
				wxString header = perLine.GetNextToken();

				while(perLine.HasMoreTokens() == true)
				{
					wxStringTokenizer perColumn(perLine.GetNextToken(),_T(","));

					if(perColumn.HasMoreTokens() == true)
					{
						wxListItem item;

						item.SetId(highscoreListPtr->GetItemCount());
						item.SetText(perColumn.GetNextToken());
						long idx = highscoreListPtr->InsertItem(item);
			
						if(perColumn.HasMoreTokens() == true)
							highscoreListPtr->SetItem(idx,1,perColumn.GetNextToken());

						if(perColumn.HasMoreTokens() == true)
							highscoreListPtr->SetItem(idx,2,perColumn.GetNextToken());

						if(perColumn.HasMoreTokens() == true)
							highscoreListPtr->SetItem(idx,3,perColumn.GetNextToken());
					}
				}
			}
		}

		void OnIdle(wxIdleEvent &event)
		{
			JadeDSLog::Stream::log() << "Enter OnIdle" << JadeDSLog::EndL;

			JadeSDK::Connection::getConnection()->updateStateSync(0,this);
			JadeSDK::UInt32 runTime = JadeSDK::Connection::getConnection()->getRuntime(JadeSDK::Connection::Global);
			std::string timeStr = JadeDSUtilities::formatStr("%d:%02d:%02d",runTime / 3600,(runTime / 60) % 60,runTime % 60);
		
			statusPtr->SetStatusText(wxString(timeStr.c_str()),1);

			JadeDSLog::Stream::log() << "Leave OnIdle" << JadeDSLog::EndL;
		}

		void OnStorageSelect(wxListEvent &event)
		{
			wxListItem item = event.GetItem();
			
			item.SetColumn(2);

			storageListPtr->GetItem(item);
			storageTextPtr->SetValue(item.GetText());
			storageTextPtr->Enable();
			storageSendPtr->Enable();
		}

		void OnStorageSend(wxCommandEvent &event)
		{
			long selId = storageListPtr->GetNextItem(-1,wxLIST_NEXT_ALL,wxLIST_STATE_SELECTED);

			if(selId >= 0)
			{
				wxListItem slot;
				wxListItem index;
				wxListItem value;

				slot.SetMask(wxLIST_MASK_TEXT);
				slot.SetId(selId);
				slot.SetColumn(0);
				storageListPtr->GetItem(slot);

				index.SetMask(wxLIST_MASK_TEXT);
				index.SetId(selId);
				index.SetColumn(1);
				storageListPtr->GetItem(index);

				value.SetId(selId);
				value.SetColumn(2);
				value.SetText(storageTextPtr->GetValue());
				storageListPtr->SetItem(value);

				JadeSDK::Connection::getConnection()->updateStorageSlot(std::string(slot.GetText().c_str()),std::string(storageTextPtr->GetValue().c_str()),atoi(index.GetText().c_str()));
			}
		}

		void OnClose(wxCloseEvent &event)
		{
			JadeSDK::Connection::getConnection()->notifyTick(tickType,false);

			GetThread()->Delete();

			if(GetThread()->IsRunning() == true)
				GetThread()->Wait();

			Destroy();
		}

		DECLARE_EVENT_TABLE()
	};
	
	BEGIN_EVENT_TABLE(SampleFrame,wxFrame)
		EVT_IDLE(SampleFrame::OnIdle)
		EVT_CLOSE(SampleFrame::OnClose)
		EVT_BUTTON(ID_STORAGE_SEND,SampleFrame::OnStorageSend)
		EVT_TOGGLEBUTTON(ID_GUI_TIMER,SampleFrame::OnTimerChange)
		EVT_TOGGLEBUTTON(ID_PAUSED_TIMER,SampleFrame::OnTimerChange)
		EVT_TOGGLEBUTTON(ID_PLAYING_TIMER,SampleFrame::OnTimerChange)
		EVT_LIST_ITEM_SELECTED(ID_STORAGE_LIST,SampleFrame::OnStorageSelect)
	END_EVENT_TABLE()

	class SampleD_StatusIO : public wxApp
	{
	private:
		SampleFrame *framePtr;
	public:
		virtual bool OnInit()
		{
			JadeDSLog::Stream::log().outChannel(JadeDSLog::DebugString,JadeDSLog::Detail,true,true);
			JadeDSLog::Stream::log().outChannel(JadeDSLog::File,JadeDSLog::Detail,true,true);
			JadeDSLog::Stream::log().setFileChannel("C:\\Development\\Subversion\\JadeDS\\client\\CDGClient\\platform\\win32\\Debug_Build\\logs\\SampleD.log");
			JadeDSLog::Stream::log() << JadeDSLog::Info << "JadeDS SampleD" << JadeDSLog::EndL;

			if(JadeSDK::Connection::init("ogresamples") == false)
			{
				JadeDSLog::Stream::log() << JadeDSLog::Error << "Failed to connect!" << JadeDSLog::EndL;

				return false;	
			}

			wxImage::AddHandler(new wxPNGHandler);

			framePtr = new SampleFrame();
			framePtr->Show(TRUE);

			SetTopWindow(framePtr);

			return true;
		}

		virtual int OnExit()
		{
			JadeSDK::Connection::getConnection()->close();
			
			return wxApp::OnExit();
		}
	};

	IMPLEMENT_APP(SampleD_StatusIO)
}
