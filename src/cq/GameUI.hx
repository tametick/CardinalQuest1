package cq;

import cq.CqActor;
import cq.CqEffectChest;
import cq.CqFloatText;
import cq.CqInventoryDialog;
import cq.CqItem;
import cq.CqSpell;
import cq.CqSpellButton;
import cq.CqVitalBar;

import data.Registery;

import world.Player;
import world.World;

import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxel.HxlButton;
import haxel.HxlButtonContainer;
import haxel.HxlDialog;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlText;
import haxel.HxlTextContainer;
import haxel.HxlUIBar;

class GameUI extends HxlDialog {

	// Main UI containers
	var leftButtons:HxlButtonContainer;
	var dlgSpellGrid:CqSpellGrid;

	// View state panels
	var panelMap:CqMapDialog;
	var panelInventory:CqInventoryDialog;
	var panelCharacter:HxlSlidingDialog;
	var panelLog:CqMessageDialog;

	// Left side button panel
	var btnMainView:HxlButton;
	var btnMapView:HxlButton;
	var btnInventoryView:HxlButton;
	var btnCharacterView:HxlButton;
	var btnLogView:HxlButton;

	// Misc UI elements
	var xpBar:HxlUIBar;

	// State & helper vars
	public static var currentPanel:HxlSlidingDialog = null;

	public override function new() {
		super(0, 0, HxlGraphics.width, HxlGraphics.height);

		currentPanel = null;
		var self = this;

		/**
		 * Create and cache graphics for use by UI widgets
		 **/
		initUIGraphics();

		/**
		 * Create and init main containers
		 **/
		leftButtons = new HxlButtonContainer(0, 50, 84, 380, HxlButtonContainer.VERTICAL, HxlButtonContainer.TOP_TO_BOTTOM, 10, 10);
		//leftButtons.setBackgroundColor(0x99555555, 10);
		leftButtons.scrollFactor.x = leftButtons.scrollFactor.y = 0;
		add(leftButtons);

		//dlgSpellGrid = new CqSpellGrid(HxlGraphics.width-84, 50, 84, 380, HxlButtonContainer.VERTICAL, HxlButtonContainer.TOP_TO_BOTTOM, 10, 10);
		dlgSpellGrid = new CqSpellGrid(HxlGraphics.width-84, 50, 84, 380);
		//dlgSpellGrid.setBackgroundColor(0x88555555);
		add(dlgSpellGrid);

		/**
		 * View state panels
		 **/
		panelMap = new CqMapDialog(84, 0, 472, 480);
		panelMap.setBackgroundColor(0xff9A9DBC);
		panelMap.zIndex = 2;
		add(panelMap);

		panelInventory = new CqInventoryDialog(84, 0, 472, 480);
		panelInventory.setBackgroundColor(0xffBC9A9A);
		panelInventory.zIndex = 2;
		add(panelInventory);

		panelCharacter = new HxlSlidingDialog(84, 0, 472, 480);
		panelCharacter.setBackgroundColor(0xff9ABC9D);
		panelCharacter.zIndex = 2;
		add(panelCharacter);

		panelLog = new CqMessageDialog(84, 0, 472, 480);
		panelLog.setBackgroundColor(0xffBCB59A);
		panelLog.zIndex = 2;
		add(panelLog);

		/**
		 * Left side panel buttons
		 **/
		btnMainView = new HxlButton(0, 0, 64, 64);
		btnMainView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnMainView.loadText(new HxlText(0, 23, 64, "Main", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnMainView.setCallback(function() {
			self.showPanel(null, self.btnMainView);
		});
		btnMainView.configEvent(5, true, true);
		btnMainView.setActive(true);
		leftButtons.addButton(btnMainView);

		btnMapView = new HxlButton(0, 0, 64, 64);
		btnMapView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnMapView.loadText(new HxlText(0, 23, 64, "Map", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnMapView.setCallback(function() {
			self.showPanel(self.panelMap, self.btnMapView);
		});
		btnMapView.configEvent(5, true, true);
		leftButtons.addButton(btnMapView);

		btnInventoryView = new HxlButton(0, 0, 64, 64);
		btnInventoryView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnInventoryView.loadText(new HxlText(0, 23, 64, "Inv", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnInventoryView.setCallback(function() {
			self.showPanel(self.panelInventory, self.btnInventoryView);
		});
		btnInventoryView.configEvent(5, true, true);
		leftButtons.addButton(btnInventoryView);

		btnCharacterView = new HxlButton(0, 0, 64, 64);
		btnCharacterView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnCharacterView.loadText(new HxlText(0, 23, 64, "Char", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnCharacterView.setCallback(function() {
			self.showPanel(self.panelCharacter, self.btnCharacterView);
		});
		btnCharacterView.configEvent(5, true, true);
		leftButtons.addButton(btnCharacterView);

		btnLogView = new HxlButton(0, 0, 64, 64);
		btnLogView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnLogView.loadText(new HxlText(0, 23, 64, "Log", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnLogView.setCallback(function() {
			self.showPanel(self.panelLog, self.btnLogView);
		});
		btnLogView.configEvent(5, true, true);
		leftButtons.addButton(btnLogView);

		panelInventory.dlgSpellGrid = dlgSpellGrid;

		xpBar = new HxlUIBar(84, 460, 472, 10);
		xpBar.setBarColor(0xff59C65E);
		add(xpBar);

	}

	function showPanel(Panel:HxlSlidingDialog, ?Button:HxlButton=null):Void {
		if ( Button != null ) {
			btnMainView.setActive(false);
			btnMapView.setActive(false);
			btnInventoryView.setActive(false);
			btnCharacterView.setActive(false);
			btnLogView.setActive(false);
			Button.setActive(true);
		}
		if ( Panel == null ) {
			if ( currentPanel != null ) {
				currentPanel.hide(function() { GameUI.currentPanel = null; });
			}
		} else {
			if ( currentPanel == null ) {
				currentPanel = Panel;
				Panel.show();
			} else {
				if ( currentPanel != Panel ) {
					// A view state other than main is already active.. Hide that one first before showing the selected one
					currentPanel.hide(function() {
						GameUI.currentPanel = Panel;
						GameUI.currentPanel.show();
					});
				} else {
					// User clicked on a view state button which is already active, switch back to main view state
					if ( currentPanel != null ) {
						currentPanel.hide(function() { GameUI.currentPanel = null; });
						btnMainView.setActive(true);
						btnMapView.setActive(false);
						btnInventoryView.setActive(false);
						btnCharacterView.setActive(false);
						btnLogView.setActive(false);
					}
				}
			}
		}
	}

	public function initUIGraphics():Void {
		var cellBgKey:String = "InventoryCellBG";
		if ( !HxlGraphics.checkBitmapCache(cellBgKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0x333333, 0x555555], null, Math.PI/2, 5.0), cellBgKey);
		}

		var cellBgHighlightKey:String = "CellBGHighlight";
		if ( !HxlGraphics.checkBitmapCache(cellBgHighlightKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0x686835, 0xADAB6B], null, Math.PI/2, 5.0), cellBgHighlightKey);
		}

		var itemBgKey:String = "ItemBG";
		if ( !HxlGraphics.checkBitmapCache(itemBgKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(50, 50, [0xc1c1c1, 0x9e9e9e], null, Math.PI/2, 8.0), itemBgKey);
		}

		var itemSelectedBgKey:String = "ItemSelectedBG";
		if ( !HxlGraphics.checkBitmapCache(itemSelectedBgKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(50, 50, [0xEFEDBC, 0xB9B99A], null, Math.PI/2, 8.0), itemSelectedBgKey);
		}

		var cellBgKey:String = "EquipmentCellBG";
		if ( !HxlGraphics.checkBitmapCache(cellBgKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0x333333, 0x555555], null, Math.PI/2, 5.0), cellBgKey);
		}

		var cellBgHighlightKey:String = "EqCellBGHighlight";
		if ( !HxlGraphics.checkBitmapCache(cellBgHighlightKey) ) {
			HxlGraphics.addBitmapData(HxlGradient.RectData(54, 54, [0x686835, 0xADAB6B], null, Math.PI/2, 5.0), cellBgHighlightKey);
		}

		var tmp:BitmapData = new BitmapData(79, 79, true, 0x0);
		tmp.copyPixels(HxlGraphics.getBitmap("InventoryCellBG"), new Rectangle(0, 0, 54, 54), new Point(19, 19), null, null, true);
		var glow:GlowFilter = new GlowFilter(0x00ff00, 0.9, 15.0, 15.0, 1.6, 1, false, true);
		tmp.applyFilter(tmp, new Rectangle(0, 0, 79, 79), new Point(0, 0), glow);
		HxlGraphics.addBitmapData(tmp, "CellGlow");
		/*
		var tmp2:HxlSprite = new HxlSprite(100, 100);
		tmp2.loadCachedGraphic("tester!");
		tmp2.zIndex = 20;
		add(tmp2);
		*/

	}

	public function itemPickup(Item:CqItem):Void {
		panelInventory.itemPickup(Item);
	}

	public function initChests():Void {
		for ( Item in Registery.world.currentLevel.loots ) {
			if ( Std.is(Item, CqChest) ) {
				cast(Item, CqChest).addOnBust(function(Target:CqChest) {
					var eff:CqEffectChest = new CqEffectChest(Target.x + Target.origin.x, Target.y + Target.origin.y);
					eff.zIndex = 6;
					HxlGraphics.state.add(eff);
					eff.start(true, 1.0, 10);
				});
			}
		}
	}

	public function initHealthBars():Void {
		for ( actor in Registery.world.currentLevel.mobs ) {
			addHealthBar(cast(actor, CqActor));
		}
	}

	public function addHealthBar(Actor:CqActor):Void {
		var bar:CqHealthBar = new CqHealthBar(Actor, Actor.x, Actor.y + Actor.height + 2, 32, 4);
		HxlGraphics.state.add(bar);
		var self = this;
		Actor.addOnInjure(function(?dmgTotal:Int=0) { 
			self.showDamageText(Actor, dmgTotal);
		});
	}

	public function doPlayerInjureEffect(?dmgTotal:Int):Void {
		HxlGraphics.flash.start(0xffff0000, 0.3, null, true);
	}

	public function showDamageText(Actor:CqActor, Damage:Int):Void {
		var txt:CqFloatText = new CqFloatText(Actor.x + (Actor.width/2), Actor.y - 16, ""+Damage, 0xff2222, 18);
		txt.zIndex = 4;
		HxlGraphics.state.add(txt);
	}
	
	public function doPlayerGainXP(?xpGained:Int=0):Void {
		var _player:CqPlayer = cast(Registery.player, CqPlayer);
		xpBar.setPercent( _player.xp / _player.nextLevel() );
	}
}
