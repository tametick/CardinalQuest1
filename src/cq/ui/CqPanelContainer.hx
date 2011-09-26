package cq.ui;
import cq.GameUI;
import cq.ui.inventory.CqInventoryDialog;
import data.Configuration;
import haxel.HxlButton;
import haxel.HxlGraphics;
import haxel.HxlGroup;
import haxel.HxlSlidingDialog;

class CqPanelContainer extends HxlGroup
{

	public static var instance:CqPanelContainer;
	public var currentPanel:HxlSlidingDialog;
	// View state panels
	public var panelMap:CqMapDialog;
	public var panelInventory:CqInventoryDialog;
	public var panelCharacter:CqCharacterDialog;
	public var panelLog:CqMessageDialog;
	
	public function new() 
	{
		super();
		instance = this;
		currentPanel = null;
		
		panelMap = new CqMapDialog(84, 0, 472, 480);
		// no map bg color (alpha=0)
		panelMap.setBackgroundColor(0x00000000);
		panelMap.zIndex = 2;
		add(panelMap);

		var panelInv_w:Int = 481;
		panelInventory = new CqInventoryDialog(GameUI.instance, Configuration.app_width/2-panelInv_w/2-10, 0, panelInv_w, 403);
		panelInventory.zIndex = 2;
		add(panelInventory);

		panelCharacter = new CqCharacterDialog(84, 0, 472, 480);
		panelCharacter.zIndex = 2;
		add(panelCharacter);

		//deprecated?
		panelLog = new CqMessageDialog(84, 0, 472, 480);
		panelLog.setBackgroundColor(0xffBCB59A);
		panelLog.zIndex = 2;
		add(panelLog);	
	}
	override public function kill():Void 
	{
		currentPanel = null;
		panelInventory.kill();
		super.kill();
	}
	public function updateItems() {
		panelInventory.updateItemPositions();
	}
	public function hideCurrentPanel(?hideCallBack:Dynamic):Void
	{
		if (!active) 
			return;
		if ( currentPanel != null ) {
			currentPanel.hide(function() { 
				instance.currentPanel = null; 
				if (hideCallBack) 
					hideCallBack(); 
			});
			GameUI.instance.disableAllButtons();
		}
	}
	public function showPanel(Panel:HxlSlidingDialog, ?Button:HxlButton = null, ?showCallback:Dynamic) {
		if (!active) return;
		if (Panel == panelInventory)
			panelInventory.updateItemPositions();
		if ( HxlGraphics.mouse.dragSprite != null ) 
			return;
		// If user was in targeting mode, cancel it
		if ( GameUI.isTargeting ) 
			GameUI.setTargeting(false);

		if ( Button != null ) {
			GameUI.instance.disableAllButtons();
			Button.setActive(true);
		}
		if ( Panel == null ) {
			if ( currentPanel != null ) {
				currentPanel.hide(function() { instance.currentPanel = null; });
			}
		} else {
			if ( currentPanel == null ) {
				currentPanel = Panel;
				Panel.show(showCallback);
			} else {
				if ( currentPanel!=Panel ) {
					// A view state other than main is already active: 
					// Hide that one first before showing the selected one
					currentPanel.hide(function() {
						instance.currentPanel = Panel;
						instance.currentPanel.show(showCallback);
					});
				} else {
					// User clicked on a view state button which is already active, switch back to main view state
					if ( currentPanel != null ) {
						currentPanel.hide(function() { instance.currentPanel = null; });
						GameUI.instance.btnMainView.setActive(true);
						GameUI.instance.disableAllButtons();
					}
				}
			}
		}
	}
}