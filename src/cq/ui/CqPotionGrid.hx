package cq.ui;
import cq.GameUI;
import cq.states.GameState;
import cq.states.HelpState;
import cq.states.MainMenuState;
import cq.ui.inventory.CqInventoryGrid;
import data.SoundEffectsManager;
import haxel.HxlButton;
import haxel.HxlGraphics;
import haxel.HxlPoint;
import haxel.HxlSprite;
import haxel.HxlText;

import cq.CqItem;
import cq.CqResources;
import cq.ui.CqPotionButton;


class CqPotionGrid extends CqInventoryGrid {
	var belt:HxlSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);
		
		belt = new HxlSprite(0, 0);
		belt.zIndex = -1;
		belt.loadGraphic(UiBeltHorizontal, false, false, 460, 71);
		add(belt);
		
		cells = new Array();

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var offsetX:Int = 50;
		var offsetY:Int = 2;
		var btnSize:Int = 64;
		var padding:Int = 18;
		var idx:Int = 0;
			
		var btnSprite = new ButtonSprite();
		
		for ( i in 0...5 ) {
			var btnCell:CqPotionButton = new CqPotionButton(this, offsetX + (i * (btnSize+10)), offsetY, btnSize, btnSize,i);
			btnCell.setBackgroundSprite(btnSprite);
			add(btnCell);
			cells.push(btnCell.cell);
		}
		initButtons();

	}
	
	private function initButtons():Void 
	{
		//menu/help
		var MenuSprite = new ButtonSprite();
		var MenuSpriteH = new ButtonSprite();
		var HelpSprite = new ButtonSprite();
		var HelpSpriteH = new ButtonSprite();
		_point.x = 0.44;
		_point.y = 1;
		
		MenuSpriteH.setAlpha(0.6);
		HelpSpriteH.setAlpha(0.6);
		
		MenuSprite.scale = MenuSpriteH.scale = _point.clone();
		HelpSprite.scale = HelpSpriteH.scale = _point.clone();
		
		var btnSize:Int = 64;
		var menuButton:HxlButton = new HxlButton(4, 2, Std.int(_point.x * btnSize), Std.int(_point.y * btnSize), pressMenu);
		var helpButton:HxlButton = new HxlButton(Std.int(width-66), 2, Std.int(_point.x * btnSize), Std.int(_point.y * btnSize),pressHelp);
		helpButton.loadGraphic(HelpSprite,HelpSpriteH);
		menuButton.loadGraphic(MenuSprite,MenuSpriteH);
		helpButton.configEvent(5, true, true);
		menuButton.configEvent(5, true, true);
		
		helpButton.loadText(new HxlText(15, 32, btnSize, "Help", true).setFormat(FontDungeon.instance.fontName, 23, 0xffffff, "center", 0x010101));
		helpButton.getText().angle = 90;
		
		menuButton.loadText(new HxlText(-14, 32, btnSize, "Menu", true).setFormat(FontDungeon.instance.fontName, 23, 0xffffff, "center", 0x010101));
		menuButton.getText().angle = -90;
		
		var pop:CqPopup;
		pop = new CqPopup(150,"[hotkey ESC]", GameUI.instance.popups);
		pop.zIndex = 15;
		menuButton.setPopup(pop);
		GameUI.instance.popups.add(pop);
		pop = new CqPopup(150,"[hotkey F1]", GameUI.instance.popups);
		pop.zIndex = 15;
		helpButton.setPopup(pop);
		GameUI.instance.popups.add(pop);
		
		menuButton.extendOverlap.x = -16;
		menuButton.extendOverlap.width = 4;
		
		helpButton.extendOverlap.x = -4;
		helpButton.extendOverlap.width = 16;
		
		add(helpButton);
		add(menuButton);
	}
	public function pressHelp(?playSound:Bool = true):Void 
	{
		GameUI.showInvHelp = false;
		if (Std.is(HxlGraphics.getState(), GameState))
		{
			GameUI.instance.setActive();
			if (GameUI.instance.panels.currentPanel == GameUI.instance.panels.panelInventory) {
				if (playSound)
					SoundEffectsManager.play(MenuItemClick);
				GameUI.showInvHelp = true;
			}
			else if(GameUI.instance.panels.currentPanel != null){
				if (playSound)
					SoundEffectsManager.play(MenuItemClick);
				GameUI.instance.panels.hideCurrentPanel(pressHelp);
				return;
			}
			HxlGraphics.pushState(HelpState.instance);
		}
	}
	public function pressMenu(?playSound:Bool = false):Void	{
		if (Std.is(HxlGraphics.getState(), GameState)) {
			if (playSound)
				SoundEffectsManager.play(MenuItemClick);
			
			if (GameUI.instance.panels.currentPanel != null) {
				GameUI.instance.panels.hideCurrentPanel(pressMenu);
			} else {
				GameUI.instance.setActive(false);
				HxlGraphics.pushState(new MainMenuState());
			}
		}
	}
}