
#include <wx/wx.h>
#include <wx/combobox.h>
#include <wx/treectrl.h>
#include <jadesdk/jadesdk.h>

namespace DirectorySample
{
	enum
	{
		ID_Directory = 1,
		ID_Select,
	};

	class SampleFrame : public wxFrame
	{
	private:
		wxTreeCtrl *treePtr;
		wxComboBox *selectPtr;
	public:
		SampleFrame() : wxFrame((wxFrame *) NULL,-1,_T("Directory Sample"),wxPoint(50,50),wxSize(300,500))
		{
			wxString mounts[] = {
				"",
				"sdktrays/",
				"thumbnails/",
				"fonts/",
				"materials/programs/",
				"materials/scripts/",
				"materials/textures/",
				"materials/textures/nvidia/",
				"models/",
				"particle/",
				"DeferredShadingMedia/",
				"PCZAppMedia/",
				"RTShaderLib/",
				"cubemap/",
				"cubemapsjs/",
				"dragon/",
				"fresneldemo/",
				"ogretestmap/",
				"ogredance/",
				"sinbad/",
				"skybox/"
			};

			selectPtr = new wxComboBox(this,ID_Select,wxEmptyString,wxDefaultPosition,wxDefaultSize,21,mounts,wxCB_READONLY);
			selectPtr->SetSelection(0);
			treePtr = new wxTreeCtrl(this,ID_Directory);

			wxBoxSizer *dlgSizerPtr = new wxBoxSizer(wxVERTICAL);
			dlgSizerPtr->Add(selectPtr,0,wxEXPAND,2);
			dlgSizerPtr->Add(treePtr,1,wxEXPAND,0);
			dlgSizerPtr->SetSizeHints(this);
			SetSizer(dlgSizerPtr);
		}

		void buildTree(wxTreeItemId parentId,JadeSDK::Directory &directory)
		{
			JadeSDK::UInt32 files = directory.entryCount();

			for(JadeSDK::UInt32 index = 0; index < files; index++)
			{
				JadeSDK::Directory::Type type;
				std::string name;

				directory.getEntry(index,&name,0L,0L,&type);

				wxTreeItemId itemId = treePtr->AppendItem(parentId,name);

				if(type == JadeSDK::Directory::SubDirectory)
					buildTree(itemId,directory.getSubDirectory(index));
			}
		}

		void mountSelected(wxCommandEvent &event)
		{
			JadeSDK::Directory *dirPtr = JadeSDK::Connection::getConnection()->readDirectory(std::string(selectPtr->GetStringSelection().c_str()),true);

			if(dirPtr != 0L)
			{
				treePtr->DeleteAllItems();
				
				wxTreeItemId rootId = treePtr->AddRoot(selectPtr->GetStringSelection());

				buildTree(rootId,(*dirPtr));

				treePtr->ExpandAll();

				delete dirPtr;
			}
			else
				wxMessageBox("Directory not found!");
		}

		DECLARE_EVENT_TABLE()
	};

	BEGIN_EVENT_TABLE(SampleFrame,wxFrame)
		EVT_COMBOBOX(ID_Select,mountSelected)
	END_EVENT_TABLE()

	class SampleC_Directory : public wxApp
	{
	private:
		SampleFrame *framePtr;
	public:
		virtual bool OnInit()
		{
			if(JadeSDK::Connection::init("ogresamples") == false)
				return false;

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

	IMPLEMENT_APP(SampleC_Directory)
}
