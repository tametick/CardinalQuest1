package cq;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.GenericActuator;
import com.eclecticdesignstudio.motion.actuators.SimpleActuator;
import com.eclecticdesignstudio.motion.easing.Cubic;
import com.eclecticdesignstudio.motion.easing.Elastic;
import com.eclecticdesignstudio.motion.easing.Linear;
import cq.states.GameState;
import cq.states.HelpState;
import cq.ui.CqPanelContainer;
import cq.ui.CqPopup;

import haxel.HxlRect;

// import cq.ui.CqPotionGrid;
// import cq.ui.CqSpellGrid;
// import cq.ui.inventory.InventoryDialog;
// import cq.ui.inventory.CqInventoryItem;
// import cq.ui.inventory.CqInventoryItemManager;

import cq.ui.bag.BagGrid;
import cq.ui.bag.BagDialog;

import cq.CqActor;
import cq.effects.CqEffectChest;
import cq.effects.CqEffectInjure;
import cq.ui.CqFloatText;
import cq.CqItem;
import cq.CqSpell;
import cq.CqWorld;
import cq.ui.CqVitalBar;
import cq.effects.CqEffectSpell;
import cq.CqResources;
import cq.CqGraphicKey;
import cq.ui.CqCharacterDialog;
import cq.ui.CqMapDialog;
import cq.ui.CqMessageDialog;
import cq.ui.CqTextNotification;
import data.Resources;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.events.Event;
import flash.system.System;
import haxel.HxlGroup;
import haxel.HxlObject;
import haxel.HxlSpriteSheet;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlTilemap;
import world.GameObject;


import data.Configuration;
import data.Registery;
import data.SoundEffectsManager;

import world.Player;
import world.Tile;
import world.World;

import flash.display.Bitmap;
import flash.display.Graphics;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxel.HxlButton;
import haxel.HxlButtonContainer;
import haxel.HxlDialog;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;
import haxel.HxlPoint;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlText;
import haxel.HxlTextContainer;
import haxel.HxlUIBar;
import haxel.GraphicCache;

class GameUIBMPData extends GraphicCacheBMPData {} 

class GameUI extends HxlDialog {

	// Main UI containers
	var leftButtons:HxlButtonContainer;
	
	// public var dlgSpellGrid:CqSpellGrid;
	// public var dlgPotionGrid:CqPotionGrid;
	
	public var bagDialog:BagDialog;
	
	// public var invItemManager:CqInventoryItemManager;
	
	public var panels:CqPanelContainer;
	public var doodads:HxlDialog;//spell charges
	public var popups:HxlGroup;
	
	// Notification area
	public static var notifications:CqTextNotification;

	// Left side button panel
	public var btnMainView:HxlButton;
	var btnMapView:HxlButton;
	var btnInventoryView:HxlButton;
	var btnCharacterView:HxlButton;
	var btnInfoView:HxlButton;
	var menuBelt:HxlSprite;
	var infoViewHpBar:CqHealthBar;
	var infoViewXpBar:CqXpBar;
	var infoViewHearts:HxlGroup;
	var infoViewLevel:HxlText;
	var infoViewFloor:HxlText;
	
	// Misc UI elements
	var centralHealthBar:CqHealthBar;
	var centralXpBar:CqXpBar;
	
	var targetSprite:HxlSprite;
	var targetText:HxlText;

	// State & helper vars -- really pretty messy junk
	public static var targetString:String = "";
	public static var targetSpell:CqItem = null;
	public static var hasShownInv:Bool;
	public static var showInvHelp:Bool;
	public static var instance:GameUI = null;
	var targetLastPos:HxlPoint;
	
	public override function new() {
		super(0, 0, HxlGraphics.width, HxlGraphics.height);
		//defaults
		targetLastPos = new HxlPoint(0, 0);
		hasShownInv = false;
		showInvHelp = false;
		targetString = "";
		targetSpell = null;
		targetSprite = null;
		targetText = null;
		GameUI.instance = this;
		var self = this;
		
		//container for spell charges and notifications
		doodads = new HxlDialog();
		doodads.zIndex = 50;
		doodads.scrollFactor.x = 0;
		doodads.scrollFactor.y = 0;
		add(doodads);
		
		popups = new HxlDialog();
		popups.zIndex = 51;
		popups.scrollFactor.x = 0;
		popups.scrollFactor.y = 0;
		add(popups);

		/**
		 * Create and cache graphics for use by UI widgets
		 **/
		initGraphicsCache();
		
		/**
		 * Create and init main containers
		 **/
		
		var mainBtn = SpritePortrait.getIcon(Registery.player.playerClassSprite,64 ,1.0);
		var infoBtn = new HxlSprite();
		infoBtn.loadGraphic(SpriteInfo, false, false, 64, 64, true, 1, 1);				 
		
		var pop:CqPopup;
		leftButtons = new HxlButtonContainer(HxlGraphics.smallScreen ? -6 : 0, HxlGraphics.smallScreen ? 10 : 30, 84, 380, HxlButtonContainer.VERTICAL, HxlButtonContainer.TOP_TO_BOTTOM, 10, 10);
		leftButtons.scrollFactor.x = leftButtons.scrollFactor.y = 0;
		add(leftButtons);
		
		notifications = new CqTextNotification(Math.floor(HxlGraphics.width / 2), HxlGraphics.smallScreen ? 20 : 60);
		notifications.zIndex = 3;
		
		add(notifications);
		
		var mapBtn = new ButtonSprite();
		var mapBtnHigh = new ButtonSprite();
		var invBtn = new ButtonSprite();		
		var invBtnHigh = new ButtonSprite();
		var charBtn = new ButtonSprite();		
		var charBtnHigh = new ButtonSprite();
		
		var mapIcon = getIcon(1);		
		mapBtn.draw(mapIcon, 16, 10);
		mapBtnHigh.draw(mapIcon, 16, 10);
		mapBtnHigh.setAlpha(0.6);
		
		var invIcon = getIcon(0);
		invBtn.draw(invIcon, 16, 10);
		invBtnHigh.draw(invIcon, 16, 10);
		invBtnHigh.setAlpha(0.6);
		
		var charIcon = getIcon(2);
		charBtn.draw(charIcon, 16, 10);
		charBtnHigh.draw(charIcon, 16, 10);
		charBtnHigh.setAlpha(0.6);
		
		/**
		 * Left side panel buttons
		 **/

		var btnWidth:Int = 64;
		var btnHeight:Int = 64;
		
		menuBelt = HxlGraphics.smallScreen ? new HxlSprite(6, -10) : new HxlSprite(6, -13);
		menuBelt.zIndex = 0;
		
		if (HxlGraphics.smallScreen) {
			menuBelt.loadGraphic(MobileUiBeltVertical, true, false, 71, 320, false);
		} else {
			menuBelt.loadGraphic(UiBeltVertical, true, false, 71, 406, false);
		}
		
		menuBelt.setFrame(1);
		leftButtons.add(menuBelt);

		#if flashmobile
		leftButtons.bakeInBounds(0, 0, menuBelt.width, menuBelt.height, false);
		#end
		
			// main
		btnMainView = new HxlButton(0, 0, btnWidth, btnHeight);
		btnMainView.loadGraphic(mainBtn);
		btnMainView.configEvent(5, true, true);
		leftButtons.addButton(btnMainView);
		
		// info
		btnInfoView = new HxlButton(0, 0, btnWidth, btnHeight);
		btnInfoView.loadGraphic(infoBtn);
		btnInfoView.configEvent(5, true, true);
		leftButtons.addButton(btnInfoView);
		addInfoButtonBars();
		addInfoButtonTexts();
		addCentralBars();
		
		// map
		btnMapView = new HxlButton(0, 0, btnWidth, btnHeight);
		btnMapView.loadGraphic(mapBtn, mapBtnHigh);
		btnMapView.loadText(new HxlText(0, 40, btnWidth, Resources.getString( "UI_MAP" ), true).setFormat(FontAnonymousPro.instance.fontName, 12, 0xffffff, "center", 0x010101));
		btnMapView.setCallback(showMapDlg);
		btnMapView.configEvent(5, true, true);
		leftButtons.addButton(btnMapView);
		pop = new CqPopup(100, "\n" + Resources.getString( "POPUP_M" ), popups);
		pop.zIndex = 15;
		btnMapView.setPopup(pop);
		popups.add(pop);

		// inv
		btnInventoryView = new HxlButton(0, 0, btnWidth, btnHeight);
		btnInventoryView.loadGraphic(invBtn,invBtnHigh);
		btnInventoryView.loadText(new HxlText(0, 40, btnWidth, Resources.getString( "UI_INV" ), true).setFormat(FontAnonymousPro.instance.fontName, 12, 0xffffff, "center", 0x010101));
		btnInventoryView.setCallback(showInvDlg);
		btnInventoryView.configEvent(5, true, true);
		leftButtons.addButton(btnInventoryView);
		pop = new CqPopup(100, "\n" + Resources.getString( "POPUP_I" ), popups);
		pop.zIndex = 15;
		btnInventoryView.setPopup(pop);
		popups.add(pop);
		
		// stats
		btnCharacterView = new HxlButton(0, 0, btnWidth, btnHeight);
		btnCharacterView.loadGraphic(charBtn,charBtnHigh);
#if japanese
		btnCharacterView.loadText(new HxlText(0, 40, btnWidth, Resources.getString( "UI_CHAR" ), true, FontAnonymousPro.instance.fontName).setFormat(FontAnonymousPro.instance.fontName, 10, 0xffffff, "center", 0x010101));
#else
		btnCharacterView.loadText(new HxlText(0, 40, btnWidth, Resources.getString( "UI_CHAR" ), true).setFormat(FontAnonymousPro.instance.fontName, 12, 0xffffff, "center", 0x010101));
#end

		btnCharacterView.setCallback(showCharDlg);
		btnCharacterView.configEvent(5, true, true);
		pop = new CqPopup(100, "\n" + Resources.getString( "POPUP_C" ), popups);
		pop.zIndex = 15;
		btnCharacterView.setPopup(pop);
		popups.add(pop);
		
		if (!HxlGraphics.smallScreen) {
			leftButtons.addButton(btnCharacterView);
		} else {
			addMainMenuButton();
			remove(btnCharacterView);
			
			btnInfoView.y -= 13;
			btnMapView.y -= 12;
			btnInventoryView.y -= 24;
			
			btnMainView.setCallback(showCharDlg);
		}

		bagDialog = new BagDialog(this, 5, 5, HxlGraphics.smallScreen ? 9 : 13, ["shoes", "gloves", "armor", "jewelry", "weapon", "hat"]);
		
		panels = new CqPanelContainer();
		add(panels);
		panels.zIndex = 2;
		
		
		updateAll();
		update();
		
		
		initSheets();
		
		
		
		targetText = new HxlText( 80, HxlGraphics.height - 130, HxlGraphics.width - 160, "" );
		targetText.setFormat(null, 24, 0xffffff, "center", 0x010101);
		targetText.visible = false;
		add(targetText);
	}

	public function updatePlayerClass() {
		var mainBtn = SpritePortrait.getIcon(Registery.player.playerClassSprite,64 ,1.0);
		btnMainView.loadGraphic(mainBtn);
	}
	
	override public function update() 
	{
		//invItemManager.update();
		popups.update();
		
		if (bagDialog != null) {
			bagDialog.equippedSpells.update();
		}
		
		super.update();
	}

	public function setActive(?toggle:Bool = false)
	{
		if (!toggle){
			btnCharacterView.setActive(false);
			btnInventoryView.setActive(false);
			btnMapView.setActive(false);
		}
	}
	
	// the area where the map is visible (the full screen on the desktop version)
	public static function getMapFrame():HxlRect {
		return HxlGraphics.smallScreen ? new HxlRect(70, 0, HxlGraphics.width - 70 * 2, HxlGraphics.height - 40) : new HxlRect(0, 0, HxlGraphics.width, HxlGraphics.height);
	}
	
	override public function kill() {
		clearEventListeners();

		btnMainView.kill();
		doodads.kill();
		//invItemManager
		notifications.kill();
		panels.kill();
		popups.kill();
		btnCharacterView.kill();
		btnInfoView.kill();
		btnInventoryView.kill();
		btnMapView.kill();
		centralHealthBar.kill();
		centralXpBar.kill();
		var e:CqFloatText = null;
		while (effectQueue.length > 0) {
			e = effectQueue.pop();
			e.kill();
			e = null;
		}
		infoViewFloor.kill();
		infoViewHearts.kill();
		infoViewHpBar.kill();
		infoViewLevel.kill();
		infoViewXpBar.kill();
		leftButtons.kill();		
		if(targetSprite!=null)
			targetSprite.kill();
		if(targetText!=null)
			targetText.kill();
		
		destroy();
		super.kill();
	}
	
	override public function destroy() {
		if (btnMainView == null) return; // getting destroyed twice sometimes
		btnMainView.destroy();
		doodads.destroy();
		//invItemManager
		notifications.destroy();
		panels.destroy();
		popups.destroy();
		btnCharacterView.destroy();
		btnInfoView.destroy();
		btnInventoryView.destroy();
		btnMapView.destroy();
		centralHealthBar.destroy();
		centralXpBar.destroy();
		var e:CqFloatText = null;
		while (effectQueue.length > 0) {
			e = effectQueue.pop();
			e.destroy();
			e = null;
		}
		infoViewFloor.destroy();
		infoViewHearts.destroy();
		infoViewHpBar.destroy();
		infoViewLevel.destroy();
		infoViewXpBar.destroy();
		leftButtons.destroy();		
		if(targetSprite!=null)
			targetSprite.destroy();
		if(targetText!=null)
			targetText.destroy();
		
		
		btnMainView=null;
		doodads=null;
		notifications=null;
		panels=null;
		popups=null;
		btnCharacterView=null;
		btnInfoView=null;
		btnInventoryView=null;
		btnMapView=null;
		centralHealthBar=null;
		centralXpBar=null;
		infoViewFloor=null;
		infoViewHearts=null;
		infoViewHpBar=null;
		infoViewLevel=null;
		infoViewXpBar=null;
		leftButtons=null;		
		targetSprite=null;
		targetText=null;
		menuBelt = null;
		
		instance = null;
		super.destroy();
	}
	
	public function showMapDlg() {
		if (!Std.is(HxlGraphics.getState(), GameState)) return;
		SoundEffectsManager.play(MenuItemClick);
		panels.showPanel(panels.panelMap, btnMapView);
	}
	public function showInvDlg()
	{
		if (!Std.is(HxlGraphics.getState(), GameState)) 
			return;
			
		SoundEffectsManager.play(MenuItemClick);

		// Show inventory charge arcs now. Disable them again when we close the dialog.
		Registery.player.bag.setInventoryChargeArcsVisible(true);
		
		if (!hasShownInv && !Configuration.mobile) {
			hasShownInv = true;
			showInvHelp = true;
			panels.showPanel(panels.panelInventory, btnInventoryView, function() {
				instance.setActive();
				HxlGraphics.pushState(HelpState.instance);
			});
		} else {
			panels.showPanel(panels.panelInventory, btnInventoryView);
		}
	}
	public function showCharDlg() {
		if (!Std.is(HxlGraphics.getState(), GameState)) return;
		SoundEffectsManager.play(MenuItemClick);
		panels.showPanel(panels.panelCharacter, btnCharacterView);
	}
	override public function overlapsPoint(X:Float, Y:Float, ?PerPixel:Bool = false):Bool {
		return leftButtons.overlapsPoint(X, Y) ||
		    //dlgSpellGrid.overlapsPoint(X, Y) ||
		    //dlgPotionGrid.overlapsPoint(X, Y) ||
			 bagDialog.overlapsPoint(X, Y) ||
			 panels.panelInventory.overlapsPoint(X, Y) ||
			 panels.panelCharacter.overlapsPoint(X, Y);
	}
	

	
	private function addMainMenuButton():Void  {
		//menu/help
		var MenuSprite = new ButtonSprite();
		var MenuSpriteH = new ButtonSprite();
		
		MenuSprite.scale = new HxlPoint(1.0, 0.44);
		MenuSpriteH.scale = new HxlPoint(1.0, 0.44);
		
		MenuSpriteH.setAlpha(0.6);
		
		MenuSprite.bakeCurrent();
		MenuSpriteH.bakeCurrent();
		
		var btnSize:Int = 64;
		var menuButton:HxlButton = new HxlButton(4, 200, Math.floor(MenuSprite.width), Math.floor(MenuSprite.height), pressMenu);
		menuButton.loadGraphic(MenuSprite, MenuSpriteH);
		menuButton.configEvent(5, true, true);
		
		menuButton.loadText(new HxlText(0, HxlGraphics.smallScreen ? 3 : 22, btnSize, "Menu", true).setFormat(FontDungeon.instance.fontName, 23, 0xffffff, "center", 0x010101));
		
		menuButton.extendOverlap.y = -8;
		menuButton.extendOverlap.height = 8;

		leftButtons.addButton(menuButton);
		
		menuButton.y -= 27; // undo the magic that leftButtons does to menuButton's position (grr)
	}	
	
	function addInfoButtonBars() {
		var width = 50;
		var height = 6;
		var xShift = (leftButtons.width - width) / 4;
		var yShift = btnMainView.height-3;

		infoViewHpBar = new CqHealthBar(Registery.player, leftButtons.x+btnInfoView.x+xShift, leftButtons.y+btnMainView.y+yShift,width, height,BarType.INFO);
		infoViewXpBar = new CqXpBar(Registery.player, infoViewHpBar.x, infoViewHpBar.y+infoViewHpBar.height, width, height, BarType.INFO);
		infoViewHpBar.scrollFactor.x = infoViewHpBar.scrollFactor.y = 0;
		infoViewXpBar.scrollFactor.x = infoViewXpBar.scrollFactor.y = 0;
		
		
		if (!HxlGraphics.smallScreen) {
			add(infoViewHpBar);
			add(infoViewXpBar);
		}
	}
	
	function addCentralBars() {
		var width = 16 * Configuration.zoom;
		var height = 4;
		
		var xShift = Registery.player.getScreenXY().x+2;
		var yShift = Registery.player.getScreenXY().y + Configuration.zoomedTileSize()+2;
		
		centralHealthBar = new CqHealthBar(Registery.player, xShift, yShift,width, height, BarType.CENTRAL);
		centralXpBar = new CqXpBar(Registery.player, xShift, yShift+centralHealthBar.height, width, height, BarType.CENTRAL);
		centralHealthBar.scrollFactor.x = centralHealthBar.scrollFactor.y = 0;
		centralXpBar.scrollFactor.x = centralXpBar.scrollFactor.y = 0;
		
		centralHealthBar.zIndex = zIndex ;
		centralXpBar.zIndex = zIndex;
		
		add(centralHealthBar);
		add(centralXpBar);
	}
	
	public function pressHelp(?playSound:Bool = true) {
		bagDialog.equippedConsumables.pressHelp(playSound);
	}
	
	public function pressMenu(?playSound:Bool = true) {
		bagDialog.equippedConsumables.pressMenu(playSound);
	}
	
	public function updateCentralBarsPosition() {
		centralHealthBar.targetX = Registery.player.getScreenXY().x+2;
		centralHealthBar.targetY = Registery.player.getScreenXY().y + Configuration.zoomedTileSize()+2;
		
		centralXpBar.targetX = centralHealthBar.targetX;
		centralXpBar.targetY = centralHealthBar.targetY + centralHealthBar.height;
	}
	
	function addInfoButtonTexts() {
		var fontSize = 12;
		var player = Registery.player;
		var level  = Registery.level;
		
		//heart n coin info
		infoViewHearts = new HxlGroup();
		infoViewHearts.zIndex = zIndex+1;
		infoViewHearts.width = 50;
		infoViewHearts.height = 20;
		infoViewHearts.x = infoViewXpBar.x;
		infoViewHearts.y = HxlGraphics.smallScreen ? btnMainView.y + btnMainView.height + 9 : infoViewXpBar.y + infoViewXpBar.height + 3;
		//lives
		var heart = new HeartSprite();
		heart.x -= 2;
		heart.y += 3;
#if japanese		
		var lives = new HxlText(heart.x + heart.width - 6, 0, Std.int(infoViewHearts.width - heart.width), "" + player.lives, true, FontAnonymousPro.instance.fontName);
#else
		var lives = new HxlText(heart.x + heart.width - 6, 0, Std.int(infoViewHearts.width - heart.width), Resources.getString( "UI_TIMES" ) + player.lives, true, FontAnonymousPro.instance.fontName);
#end
		player.infoViewLives = lives;
		
		//coins
		var coin = new CoinSprite(23, -2);
		coin.scale = new HxlPoint(0.8, 0.8);
		coin.bakeCurrent();
		
		var coins = new HxlText(coin.x + coin.width-2, 0, Std.int(infoViewHearts.width - coin.width), ""+player.money, true, FontAnonymousPro.instance.fontName);
		player.infoViewMoney = coins;
		
		coins.setSize(11);
		lives.setSize(11);
		
		coin.scrollFactor.x = coin.scrollFactor.y = heart.scrollFactor.x = heart.scrollFactor.y = coins.scrollFactor.x = coins.scrollFactor.y = lives.scrollFactor.x = lives.scrollFactor.y =0;
		infoViewHearts.add(lives);
		infoViewHearts.add(heart);
		infoViewHearts.add(coins);
		infoViewHearts.add(coin);
		add(infoViewHearts);

		//level info
		var viewLevelY:Float = infoViewHearts.y + infoViewHearts.height - 2;
		var viewTextSize:Int = fontSize;
#if japanese
		viewLevelY += 2;
		viewTextSize -= 2;
#end
		infoViewLevel = new HxlText(infoViewXpBar.x, viewLevelY, Std.int(btnInfoView.width), Resources.getString( "UI_LEVEL" ) + " " + player.level, true, FontAnonymousPro.instance.fontName);
		infoViewLevel.zIndex = zIndex+1;
		player.infoViewLevel = infoViewLevel;
		infoViewLevel.setSize(viewTextSize);
		infoViewLevel.scrollFactor.x = infoViewLevel.scrollFactor.y = 0;
		add(infoViewLevel);
		
		var viewFloorY:Float = infoViewLevel.y + infoViewLevel.height - 4;
#if japanese
		viewFloorY += 2;
#end
		infoViewFloor = new HxlText(infoViewXpBar.x, viewFloorY, Std.int(btnInfoView.width), Resources.getString( "UI_FLOOR" ) + " " + (level.index + 1), true, FontAnonymousPro.instance.fontName);
		infoViewFloor.zIndex = zIndex+1;
		player.infoViewFloor = infoViewFloor;
		infoViewFloor.setSize(viewTextSize);
		infoViewFloor.scrollFactor.x = infoViewFloor.scrollFactor.y = 0;
		add(infoViewFloor);
		
		heart = null;
		lives = null;
		coins = null;
		coin = null;
		player = null;
		level  = null;
	}
	
	function getIcon(?Frame:Int=0):HxlSprite{
		var icon = new HxlSprite();
		icon.loadGraphic(SpriteIcons, true, false, 32, 32);
		icon.setFrame(Frame);
		return icon;
	}
	public function updateCharges() {
		for (spell in Registery.player.bag.spells(true)) {
			if (spell.inventoryProxy != null) {
				spell.inventoryProxy.updateCharge();
			}
		}
	}

	public function initGraphicsCache() {
		var size = 54;
		var cellBgKey:CqGraphicKey = CqGraphicKey.InventoryCellBG;
		if ( !GraphicCache.checkBitmapCache(cellBgKey) ) {
			GraphicCache.addBitmapData(HxlGradient.RectData(size, size, [0x333333, 0x555555], null, Math.PI/2, 5.0), cellBgKey);
		}
		
		var cellBgKey:CqGraphicKey = CqGraphicKey.DropCellBG;
		if ( !GraphicCache.checkBitmapCache(cellBgKey) ) {
			GraphicCache.addBitmapData(HxlGradient.RectData(size, size, [0x883333, 0xcc5555], null, Math.PI/2, 5.0), cellBgKey);
		}

		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;
		if ( !GraphicCache.checkBitmapCache(cellBgHighlightKey) ) {
			GraphicCache.addBitmapData(HxlGradient.RectData(size, size, [0x686835, 0xADAB6B], null,[0.8,0.1], Math.PI/2, 5.0), cellBgHighlightKey);
		}
		
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.DropCellBGHighlight;
		if ( !GraphicCache.checkBitmapCache(cellBgHighlightKey) ) {
			GraphicCache.addBitmapData(HxlGradient.RectData(size, size, [0x996835, 0xFDAB6B], null,[0.8,0.1], Math.PI/2, 5.0), cellBgHighlightKey);
		}

		var itemBgKey:CqGraphicKey = CqGraphicKey.ItemBG;
		if ( !GraphicCache.checkBitmapCache(itemBgKey) ) {
			GraphicCache.addBitmapData(HxlGradient.CircleData(25, [0xc1c1c1, 0x9e9e9e],null,[0.5,0.0]),itemBgKey);
		}

		var itemSelectedBgKey:CqGraphicKey = CqGraphicKey.ItemSelectedBG;
		if ( !GraphicCache.checkBitmapCache(itemSelectedBgKey) ) {
			GraphicCache.addBitmapData(HxlGradient.CircleData(25, [0xc1c1c1, 0x9e9e9e],null,[0.5,0.0]),itemSelectedBgKey);
		}

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		if ( !GraphicCache.checkBitmapCache(cellBgKey) ) {
			GraphicCache.addBitmapData(HxlGradient.RectData(size, size, [0x333333, 0x555555], null, [0.0,0.0], Math.PI/2, 5.0), cellBgKey);
		}

		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;
		if ( !GraphicCache.checkBitmapCache(cellBgHighlightKey) ) {
			GraphicCache.addBitmapData(HxlGradient.RectData(size, size, [0xFFCC00, 0xFFFF99], null, [0.5,0.5],Math.PI/2, 5.0), cellBgHighlightKey);
		}

		var tmp:GameUIBMPData = new GameUIBMPData(79, 79, true, 0x0);
		tmp.copyPixels(GraphicCache.getBitmap(CqGraphicKey.InventoryCellBG), new Rectangle(0, 0, size, size), new Point(19, 19), null, null, true);
		var glow:GlowFilter = new GlowFilter(0x00ff00, 0.9, 15.0, 15.0, 1.6, 1, false, true);
		tmp.applyFilter(tmp, new Rectangle(0, 0, 79, 79), new Point(0, 0), glow);
		GraphicCache.addBitmapData(tmp, CqGraphicKey.CellGlow);
		tmp.dispose();
		tmp = null;
		glow = null;
		
		
		if ( !GraphicCache.checkBitmapCache(CqGraphicKey.buttonSprite) ) {
			var btn:ButtonSprite = new ButtonSprite();
			
			var btnPixels:GraphicCacheBMPData = new GraphicCacheBMPData(btn.pixels.width, btn.pixels.height, true, 0x00000000);
			var mtx:Matrix = new Matrix();
			btnPixels.draw(btn.pixels, mtx);
			
			GraphicCache.addBitmapData(btnPixels, CqGraphicKey.buttonSprite);
			
			btnPixels.dispose();
			btnPixels = null;
			btn.pixels.dispose();
			btn = null;
		}
	}
	
	private function initSheets():Void {
		CqSheets.itemSheet = SpriteItems.instance;
		CqSheets.spellSheet = SpriteSpells.instance;
	}
	
	public function disableAllButtons():Void
	{
		btnMainView.setActive(false);
		btnMapView.setActive(false);
		btnInventoryView.setActive(false);
		btnCharacterView.setActive(false);
		btnInfoView.setActive(false);
	}
	public function checkTileItems(player:CqPlayer) {
		if (player == null || Registery.level == null || HxlGraphics.state == null)
			return;
		
		var curPos:HxlPoint = player.getTilePos();
		if (curPos == null)
			return;
		
		var curTile = cast(Registery.level.getTile(Std.int(curPos.x), Std.int(curPos.y)), Tile);
		if (curTile == null || curTile.loots == null)
			return;
		
		if ( curTile.loots.length > 0 ) {
			var item = cast(curTile.loots[curTile.loots.length - 1], CqItem);
			if (!Std.is(item, CqChest)) {
				player.pickup(HxlGraphics.state, item);
			}
		}
	}
	override public function onAdd(state:HxlState) {
		super.onAdd(state);
	}
	override public function onRemove(state:HxlState) {
		super.onRemove(state);
	}

	public function initChests() {
		for ( Item in Registery.level.loots ) {
			if ( Std.is(Item, CqChest) ) {
				cast(Item, CqChest).addOnBust(onBustChestCallBack);
			}
		}
	}
	function onBustChestCallBack(Target:CqChest)
	{
		var eff:CqEffectChest = new CqEffectChest(Target.x + Target.origin.x, Target.y + Target.origin.y);
		eff.zIndex = 6;
		HxlGraphics.state.add(eff);
		eff.start(true, 1.0, 10);
	}
	public function initHealthBars() {
		for ( actor in Registery.level.mobs ) {
			addHealthBar(cast(actor, CqActor));
		}
	}
	
	public function addHealthBar(Actor:CqActor) {
		if (Std.is(Actor, CqPlayer))
			return;
		
		var bar:CqHealthBar = new CqHealthBar(Actor, Actor.x, Actor.y + Actor.height + 2, 16 * Configuration.zoom, 4);
		HxlGraphics.state.add(bar);
		bar = null;
		
		Actor.addOnInjure(function(?dmgTotal:Int=0) { 
			showDamageText(Actor, dmgTotal);
			doInjureEffect(Actor);
		});
		
		Actor.addOnAttackMiss(doAttackMiss);
	}
	public function doAttackMiss(?Attacker:CqActor, ?Defender:CqActor) {
		var attPos:HxlPoint = Attacker.tilePos;
		var defPos:HxlPoint = Defender.tilePos;
		if ( attPos.x > defPos.x ) Defender.runDodge(1); 
		else if ( attPos.x < defPos.x ) Defender.runDodge(3); 
		else if ( attPos.y < defPos.y ) Defender.runDodge(0); 
		else if ( attPos.y > defPos.y ) Defender.runDodge(2);
	}

	public function doPlayerInjureEffect(?dmgTotal:Int) {
		var player = Registery.player;
		if ( (player.hp / player.maxHp) <= 0.2 ) {
			HxlGraphics.flash.start(0xffff0000, 0.2, null, true);
		}
	}

	public static function doInjureEffect(Target:CqActor) {
		var eff:CqEffectInjure = new CqEffectInjure(Target.x + Target.origin.x, Target.y + Target.origin.y);
		eff.zIndex = 6;
		HxlGraphics.state.add(eff);
		eff.start(true, 1.0, 10);
	}

	public static function showDamageText(Actor:CqActor, Damage:Int) {
		showEffectText(Actor, ""+Damage, 0xff2222, true);
	}

	static var effectsActive:Array<CqFloatText> = new Array<CqFloatText>();
	static var effectQueue:Array<CqFloatText> = new Array<CqFloatText>();
	
	static function startEffectText(txt:CqFloatText)
	{
		txt.InitSemiCustomTween(0.6, { y: txt.y - 20,alpha:0.5 }, effectDone);
		txt.zIndex = 4;
		HxlGraphics.state.add(txt);
	}
	
	static function startAvailableEffects()
	{
		for ( e in effectQueue )
		{
			var matched:Bool = false;
			for ( active in effectsActive ) {
				if ( active.actor == e.actor && active.startX == e.startX && active.startY == e.startY ) {
					matched = true;
					break;
				}
			}
			
			if ( !matched ) {
				startEffectText( e );
				effectsActive.push( e );
				effectQueue.remove( e );
			}
		}
	}
	
	static function effectDone() {
		for ( i in 0 ... effectsActive.length ) {
			while ( i < effectsActive.length && effectsActive[i].dead ) {
				effectsActive.remove( effectsActive[i] );
			}
		}

		startAvailableEffects();
	}
	
	public static function showEffectText(actor:CqActor, text:String, color:Int,immediate:Bool = false) {
		if (Std.is(HxlGraphics.state, GameState) && cast(HxlGraphics.state, GameState).started) {
			if (actor.visible) {
#if japanese
				var fltxt:CqFloatText = new CqFloatText(actor, actor.x + (actor.width / 2), actor.y - 16, text, color, FontAnonymousPro.instance.fontName, 18, false);
#else
				var fltxt:CqFloatText = new CqFloatText(actor, actor.x + (actor.width / 2), actor.y - 16, text, color, 24, false);
#end
				
				if ( immediate ) {
					startEffectText(fltxt); // Don't even *track* immediate texts. They'd block important ones.
				} else {
					effectQueue.push(fltxt);
					startAvailableEffects();
				}
			}
		}
	}
	
	public static function clearEffectText() {
		for ( e in effectsActive ) {
			e.destroy();
		}
		
		for ( e in effectQueue ) {
			e.destroy();
		}

		effectsActive.splice( 0, effectsActive.length );
		effectQueue.splice( 0, effectQueue.length );
		
		notifications.clear();
	}

	public static function showTextNotification(message:String, ?color:Int = 0xDE913A) {
		if (Std.is(HxlGraphics.state, GameState) && cast(HxlGraphics.state, GameState).started) {
			notifications.notify(message, color);
		}
	}
	
	public function doPlayerGainXP(?xpTotal:Int=0) {
		infoViewXpBar.updateValue(xpTotal);
		centralXpBar.updateValue(xpTotal);
	}
	
	// targeting module:
	
	
	private var targetColor:UInt;
	private static var hoveredEnemy:CqActor;

	public static var isTargeting (get_isTargeting, never) : Bool;
	
	private static function get_isTargeting():Bool {
		return targetSpell != null;
	}	
	
	public static function setTargeting(spell:CqItem) {
		targetSpell = spell;
		
		// clear the current enemy popup before moving the cursor or we might end up with two!
		if (hoveredEnemy != null) {
			if (hoveredEnemy.popup != null) hoveredEnemy.popup.mouseBound = true;
			hoveredEnemy = null;
		}
		
		if ( spell != null ) {
			var itemTypeName:String = Std.is(spell, CqSpell) ? " spell" : " potion"; // merge -- we've got to find a way to offload this better to resources
			if (spell.targetsEmptyTile) {
				// targetString = "Select a space for your " + spell.name + itemTypeName;
				targetString = Resources.getString( "NOTIFY_PICK_SPACE1" ) + " " + spell.name + " " + Resources.getString( "NOTIFY_PICK_SPACE2" );
			} else {
				targetString = Resources.getString( "NOTIFY_PICK_TARGET1" ) + " " + spell.name + " " + Resources.getString( "NOTIFY_PICK_TARGET2" );
				// targetString = "Select a target for your " + spell.name + itemTypeName;
			}
		} else {
			if (instance.targetSprite != null) instance.targetSprite.visible = false;
			if (instance.targetText != null) instance.targetText.visible = false;
		}
	}
	public static function setTargetingPos(pos:HxlPoint):Void
	{
		if (targetSpell != null) {
			if (instance.targetLastPos == null) instance.targetLastPos = new HxlPoint();
			instance.targetLastPos.x = pos.x;
			instance.targetLastPos.y = pos.y;
			if (instance.targetSprite != null)
			{
				var wPos:HxlPoint = Registery.level.getPixelPositionOfTile(Std.int(pos.x), Std.int(pos.y));
				instance.targetSprite.x = wPos.x;
				instance.targetSprite.y = wPos.y;
			}
			
			instance.updateTargetingTarget(pos.x, pos.y);
		}
	}

	private function setTargetColor(color:UInt) {
		if (!Configuration.mobile) {
			if ( targetSprite == null ) {
				targetSprite = new HxlSprite();
				//targetSprite.setPixels(new GameUIBMPData(Configuration.tileSize, Configuration.tileSize, true, 0x0));
				//targetSprite.scale.x = Configuration.zoom;
				//targetSprite.scale.y = Configuration.zoom;
				
				targetSprite.setPixels(new GameUIBMPData(Configuration.zoomedTileSize(), Configuration.zoomedTileSize(), true, 0x0));
				
				targetSprite.alpha = .5;
				targetSprite.zIndex = 10;
				// targetSprite.color = 0x00ff00;
				HxlGraphics.state.add(targetSprite);
				var wPos:HxlPoint = Registery.level.getPixelPositionOfTile(Std.int(targetLastPos.x), Std.int(targetLastPos.y));
				
				targetSprite.x = wPos.x;
				targetSprite.y = wPos.y;
			} else if ( targetSprite.visible == false ) {
				targetSprite.visible = true;
			}
			
			color |= 0xff000000;
			if (color != targetColor) {
				targetSprite.fill(color);
				targetColor = color;
			}
		}
	}
	
	private function updateTargetingTarget( _tileX:Float, _tileY:Float ) {
		if (hoveredEnemy != null) {
			if (hoveredEnemy.popup != null) hoveredEnemy.popup.mouseBound = true;
			hoveredEnemy = null;
		}
		
		var tile:CqTile = cast(Registery.level.getTile(Std.int(_tileX), Std.int(_tileY)), CqTile);
		if (targetSpell.targetsEmptyTile) {
			if ( tile == null || tile.actors.length > 0 || tile.visibility != Visibility.IN_SIGHT) {
				setTargetColor(0xff0000);
			} else {
				if (!tile.blocksMovement) {
					setTargetColor(0x00ff00);
				} else {
					setTargetColor(0xff0000);
				}
			}
		} else {
			if ( tile == null || tile.actors.length <= 0 || tile.visibility != Visibility.IN_SIGHT) {
				setTargetColor(0xff0000);
			} else {
				var actor:CqActor = cast(tile.actors[0], CqActor);
				if ( actor.visible && actor != Registery.player && (actor.faction == CqPlayer.faction || !actor.specialEffects.exists("invisible")) && !actor.isAGhost()) {
					if ( actor.faction != CqPlayer.faction ) {
						setTargetColor(0x00ff00);
					} else {
						setTargetColor(0xffff00);
					}

					hoveredEnemy = actor;
					if (hoveredEnemy.popup != null) hoveredEnemy.popup.mouseBound = false;
				} else {
					setTargetColor(0xff0000);
				}
			}
		}
	}
	

	private function targetEnemyClosestToMouse(radius:Float):HxlPoint {
		var mx:Float = (HxlGraphics.mouse.x / Configuration.zoomedTileSize());
		var my:Float = (HxlGraphics.mouse.y / Configuration.zoomedTileSize());
		
		var x1 = Math.floor(mx);
		var y1 = Math.floor(my);
		
		var bestDistance:Float = radius * radius; 
		
		var targetX:Float = x1;
		var targetY:Float = y1;
		
		for (dx in -Math.ceil(radius) ... Math.ceil(radius) + 1) {
			for (dy in -Math.ceil(radius) ... Math.ceil(radius) + 1) {
				var tile:CqTile = Registery.level.getTile(x1 + dx, y1 + dy);
				if (tile != null && tile.visibility == Visibility.IN_SIGHT && tile.actors.length > 0) {
					var actor:CqActor = cast(tile.actors[0], CqActor);
					if (actor.faction != CqPlayer.faction && !actor.isGhost && !actor.specialEffects.exists("invisible")) {
						var x_dist:Float = (mx - (.5 + x1 + dx));
						var y_dist:Float = (my - (.5 + y1 + dy));
						var distance:Float = (x_dist * x_dist) + (y_dist * y_dist);
						
						if (distance < bestDistance) {
							targetX = x1 + dx;
							targetY = y1 + dy;
							bestDistance = distance;
						}
					}
				}
			}
		}
		
		return new HxlPoint(targetX, targetY);
	}
	
	public function updateTargeting(mouse:Bool = true) {
		// if we get called here, we are in targeting mode
		if (targetSprite == null || targetSprite.visible == false) {
			setTargetColor(0xffffff);
		}
			
		if ( targetText.visible == false ) {
#if japanese
			targetText.setFormat(FontAnonymousPro.instance.fontName, 18, 0xffffff, "center", 0x010101);
#else
#end
			targetText.visible = true;
			targetText.setText(GameUI.targetString);
		}
		
		var targetX:Float = 0;
		var targetY:Float = 0;
		if (mouse) {
			if (Configuration.mobile && targetSpell.targetsOther) {
				var t = targetEnemyClosestToMouse(1.7);
				targetX = Math.floor(t.x);
				targetY = Math.floor(t.y);
			} else {
				targetX = Math.floor(HxlGraphics.mouse.x / Configuration.zoomedTileSize());
				targetY = Math.floor(HxlGraphics.mouse.y / Configuration.zoomedTileSize());
			}
		} else {
			var newPos:HxlPoint = Registery.level.getCursorTargetAccordingToKeyPress(targetLastPos);
			if (newPos != null) {
				if (newPos.x == 0 && newPos.y == 0) {
					targetLastPos.x += newPos.x;
					targetLastPos.y += newPos.y;
					targetingExecute(false);
					return;
				} else {
					targetX = targetLastPos.x + newPos.x;
					targetY = targetLastPos.y + newPos.y;
				}
			} else {
				targetX = targetLastPos.x;
				targetY = targetLastPos.y;
			}
		}
		
		if (targetLastPos.x != targetX || targetLastPos.y != targetY ) {
			updateTargetingTarget(targetX, targetY);
			
			var worldPos:HxlPoint = Registery.level.getPixelPositionOfTile(Std.int(targetX), Std.int(targetY));
			if (!Configuration.mobile) {
				Actuate.tween(targetSprite, if (mouse) .046 else .125, { x: worldPos.x, y: worldPos.y } );
			}
			
			targetLastPos.x = targetX;
			targetLastPos.y = targetY;
		}
	}

	public function targetingExecute(mouse:Bool) {
		// this line seems to be a guard against something -- but against what?
		if (!exists || !visible) return;
	
		if (hoveredEnemy != null) {
			if (hoveredEnemy.popup != null) hoveredEnemy.popup.mouseBound = true;
			hoveredEnemy = null;
		}		
		
		if ( targetSpell == null ) {
			GameUI.setTargeting(null);
			return;
		}
		
		
		// a lot of redundancy here to clean up:
		var tile:CqTile = null;
		var targetX:Float, targetY:Float;
		if (mouse) {
			if (Configuration.mobile && targetSpell.targetsOther) {
				var t = targetEnemyClosestToMouse(1.7);
				targetX = Math.floor(t.x);
				targetY = Math.floor(t.y);
			} else {
				targetX = Math.floor(HxlGraphics.mouse.x / Configuration.zoomedTileSize());
				targetY = Math.floor(HxlGraphics.mouse.y / Configuration.zoomedTileSize());
			}
		}else {
			targetX = targetLastPos.x;
			targetY = targetLastPos.y;
		}
		
		tile = cast(Registery.level.getTile(Std.int(targetX), Std.int(targetY)), CqTile);
		if (tile != null && tile.visibility == Visibility.IN_SIGHT) {
			if (targetSpell.targetsEmptyTile) {
				if ( tile.actors.length <= 0 && !tile.blocksMovement) {
					targetSpell.activate(Registery.player, null, new HxlPoint(targetX, targetY));
					cast(HxlGraphics.state, GameState).passTurn();
				}
			} else {
				if (tile.actors != null && tile.actors.length > 0) {
					var victim:CqActor = cast(tile.actors[0], CqActor);
					
					if (victim != Registery.player && !victim.isGhost && (victim.faction == 0 || !victim.specialEffects.exists("invisible"))) {
						targetSpell.activate(Registery.player, victim);
						cast(HxlGraphics.state, GameState).passTurn();
					}
				}
			}
		}
		
		GameUI.setTargeting(null);
	}
	
	public function getTargetingPos() : HxlPoint {
		return targetLastPos;
	}
	
	public function removePopups(parents:Array<Dynamic>) {
		var popup:HxlText = null;
		for (p in parents) {
			popup = cast(p, HxlObject).popup;
			popups.remove(popup);
			if(popup!=null){
				popup.destroy();
			}
			p.clearPopup();
			popup = null;
		}
		
		System.gc();
		System.gc();
	}
	
	public function initPopups() {
		for (actor in Registery.level.mobs) {
			var cqMob:CqActor = cast(actor, CqActor);
			var pop:CqPopup = new CqPopup(150, cqMob.name, popups);
			pop.visible = false;
			pop.customBound = new HxlPoint(cqMob.width / 2, cqMob.height);
			cqMob.setPopup(pop);
			popups.add(pop);
		}
	}
	
	public function flashInventoryButton() {
		btnInventoryView.doFlash();
	}
	
	private function getXBallGraphic(ball:HxlSprite, colorSource:BitmapData) {
		var size = Math.floor(Configuration.zoomedTileSize() * (27.0 / 32.0));
		var w = size, h = size;
		var halfdiagonal = .5 * Math.sqrt(w * w + h * h);
		
		var tmp:GameUIBMPData = new GameUIBMPData(w, h, true, 0x0);
		var s:Shape = new Shape();
		var g:Graphics = s.graphics;
		
		for (i in 1...Math.ceil(.09 * w * h)) {
			// this is just a start, but I think it's coming along ok
			var x:Int, y:Int;
			do {
				x = HxlUtil.randomInt(w - 4) + 2;
				y = HxlUtil.randomInt(h - 4) + 2;
			} while (((Math.sqrt(x - w / 2) * (x - w / 2) + (y - h / 2) * (y - h / 2)) / halfdiagonal) > Math.random());
			g.beginFill(CqEffectSpell.randomColorBiased(colorSource, x / w, y / h, .1), 1.0);
			g.drawCircle(x, y, 1 + .5 * HxlUtil.randomInt(5));
		}
		
		tmp.draw(s);
		ball.setPixels(tmp);
		tmp.dispose();
		tmp = null;
	}
	
	public function shootXBall(actor:CqActor, victim:CqActor, colorSource:BitmapData, spell:CqItem):Void {
		var ball:HxlSprite = new HxlSprite();
		
		getXBallGraphic(ball, colorSource);
		
		var fromPixel:HxlPoint = new HxlPoint(actor.x + Configuration.tileSize / 2, actor.y+Configuration.tileSize / 2);
		ball.x = fromPixel.x;
		ball.y = fromPixel.y;
		
		ball.zIndex = 5;
		HxlGraphics.state.add(ball);
		
		var delta = { dt: 0.0, x1: ball.x, y1: ball.y };
		
		var distance = HxlUtil.distance(fromPixel, new HxlPoint(victim.x + Configuration.tileSize / 2, victim.y + Configuration.tileSize / 2));
		var time = distance / 160.0;
		if (time > 0.5) time = 0.5;
		var actuator = Actuate.tween(delta, time, { dt: 1.0 } );
		
		actuator
			.onComplete(onXBallHit, [ball, actor, victim, spell])
			.onUpdate(updateXBall, [ball, victim, actuator]);
	}
	
	private function updateXBall(ball:HxlSprite, victim:CqActor, actuator:GenericActuator) {
		var delta:Dynamic = actuator.target;
		var dt:Float = delta.dt;
		var x1:Float, y1:Float, x2:Float=0.0, y2:Float=0.0;
		
		x1 = delta.x1;
		y1 = delta.y1;
		if (victim!=null) {
			x2 = victim.x + Configuration.tileSize / 2;
			y2 = victim.y + Configuration.tileSize / 2;
		
			if(ball!=null) {
				ball.angle += 20 + 15 * Math.random();
			
				dt = dt + .01 * Math.random();
				ball.x = x1 * (1.0 - dt) + x2 * dt;
				ball.y = y1 * (1.0 - dt) + y2 * dt;
			}
		}
	}
	
	private function onXBallHit(ball:HxlSprite,actor:CqActor,other:CqActor,spell:CqItem) {
		HxlGraphics.state.remove(ball);
		if (ball != null) {
			ball.pixels.dispose();
			ball.pixels = null;
		}
		
		spell.completeUseOn(actor, other);
	}
}



class CqSheets {
	// I feel no love for this code here, but it's as clean a refactoring as I'm going to get to just yet
	public static var itemSheet:HxlSpriteSheet;
	public static var spellSheet:HxlSpriteSheet;
	
	public static function getSpellPixels(spriteIndex:String):BitmapData {
		var spellSheetKey:CqGraphicKey = CqGraphicKey.SpellIconSheet;
		var spellSprite = new HxlSprite(0, 0);
		spellSprite.loadGraphic(SpriteSpells, true, false, Configuration.tileSize, Configuration.tileSize, false, 3.0, 3.0);
		
		spellSprite.setFrame(spellSheet.getSpriteIndex(spriteIndex));
		
		return spellSprite.getFramePixels();
	}
	
	public static function getItemPixels(spriteIndex:String):BitmapData {
		var itemSheetKey:CqGraphicKey = CqGraphicKey.ItemIconSheet;
		var itemSprite = new HxlSprite(0, 0);
		itemSprite.loadGraphic(SpriteItems, true, false, Configuration.tileSize, Configuration.tileSize, false, 3.0, 3.0);

		itemSprite.setFrame(itemSheet.getSpriteIndex(spriteIndex));
		
		return itemSprite.getFramePixels();
	}
}
