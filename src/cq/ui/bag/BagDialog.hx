package cq.ui.bag;

import cq.GameUI;
import cq.ui.CqPopup;
import cq.CqActor;
import cq.CqItem;
import cq.CqResources;
import cq.CqSpell;
import cq.CqGraphicKey;

import cq.CqBag;
import cq.ui.bag.BagGrid;

import data.Registery;
import data.Resources;
import data.Configuration;
import data.SoundEffectsManager;

import haxel.GraphicCache;
import world.Tile;

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.filters.GlowFilter;

import haxel.HxlDialog;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlObject;
import haxel.HxlObjectContainer;
import haxel.HxlPoint;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlSpriteSheet;
import haxel.HxlText;
import haxel.HxlUtil;

class BagDialog {
	public var slidingPart:SlidingBagDialog;
	
	public var paperdollDialog(default, null):HxlDialog;
//	public var itemInfoDialog(default, null):CqItemInfoDialog;
	
	public var backpack(default, null):CqBackpackGrid;
	public var clothingAndRings(default, null):CqClothingGrid;
	public var equippedSpells(default, null):CqSpellGrid;
	public var equippedConsumables(default, null):CqPotionGrid;
	
	private var gameui:GameUI;
	
	private var cellByHotkey:Hash<CqInventoryCell>;
	
	public function new(gameUI:GameUI, spells:Int, potions:Int, packsize:Int, equipSlots:Array<String>) {
		gameui = gameUI;
		
		equippedSpells = new CqSpellGrid(spells, HxlGraphics.width - (HxlGraphics.smallScreen ? 77 : 84), HxlGraphics.smallScreen ? 10 : 30, 84, 380);
		equippedSpells.zIndex = 1;
		gameui.add(equippedSpells);

		var potiongrid_w:Int = HxlGraphics.smallScreen ? 340 : 460;
		var potiongrid_h:Int = HxlGraphics.smallScreen ? 37 : 71;
		
		equippedConsumables = new CqPotionGrid(potions, Configuration.app_width/2-potiongrid_w/2, Configuration.app_height - (HxlGraphics.smallScreen ? potiongrid_h : 72), potiongrid_w, potiongrid_h);
		gameui.add(equippedConsumables);
		
		slidingPart = new SlidingBagDialog(gameui, packsize, equipSlots);
	}
	
	public function addSlotsToBag(bag:CqBag) {
		for (cell in equippedConsumables.cells) {
			bag.addSlot(cell, POTION);
		}
		
		for (cell in equippedSpells.cells) {
			bag.addSlot(cell, SPELL);
		}

		for (cell in slidingPart.clothingAndRings.cells) {
			bag.addSlot(cell, cell.equipType); // ugliness in the name
		}
			
		for (cell in slidingPart.backpack.cells) {
			bag.addSlot(cell, null);
		}
	}
	
	public function hotkeys():Bool {
		return
			equippedSpells.respondToHotkeys(Configuration.bindings.spells)
			|| equippedConsumables.respondToHotkeys(Configuration.bindings.potions);
	}
	
	public function overlapsPoint(X:Float, Y:Float, ?PerPixel:Bool = false):Bool {
		return
			equippedSpells.overlapsPoint(X, Y, PerPixel)
			|| equippedConsumables.overlapsPoint(X, Y, PerPixel);
	}
}

class SlidingBagDialog extends HxlSlidingDialog {
	public var gameui:GameUI;
	public var paperdollDialog:HxlDialog;
	public var itemInfoDialog:CqItemInfoDialog;
	
	public var backpack:CqBackpackGrid;
	public var clothingAndRings:CqClothingGrid;
	public var equippedSpells:CqSpellGrid;
	public var equippedConsumables:CqPotionGrid;
	
	
	//remove refs to any nonsliding dialogs from here
	static inline var OUTER_BORDER:Int 		= 10; 
	static inline var TOP_BORDER:Int 		= 0; 
	static inline var GAP:Int 				= 15; 
	static inline var DIVISOR_H_PERCENT:Int = 75;
	static inline var DIVISOR_V_PERCENT:Int = 55;
	
	public function new(_GameUI:GameUI, packsize:Int, equipSlots:Array<String>) {
		// Size: 481 x 480
		// Mobile size: 338 x 283
		
		var panelInv_w:Int = HxlGraphics.smallScreen ? 480 - 142 : 481;
		var X = Configuration.app_width / 2 - panelInv_w / 2 - 10;
		var Y = 4;
		var Width = panelInv_w;
		var Height = HxlGraphics.smallScreen ? 320 - 37: 403;
		var Direction = 0;
		super(X, Y, Width, Height, Direction);
		
		gameui = _GameUI;
		
		var div_l:Int = Math.floor((Width * (DIVISOR_V_PERCENT / 100)) - OUTER_BORDER*2);
		var div_r:Int = Math.floor((Width * ((100 - DIVISOR_V_PERCENT) / 100)) - OUTER_BORDER*2);
		var div_u:Int = Math.floor((Height * (DIVISOR_H_PERCENT / 100)) - TOP_BORDER*2);
		var div_b:Int = Math.floor((Height * ((100 - DIVISOR_H_PERCENT) / 100)) - TOP_BORDER*2);
		
		paperdollDialog = new HxlDialog(OUTER_BORDER, TOP_BORDER, div_l - OUTER_BORDER, div_u - OUTER_BORDER);
		add(paperdollDialog);
		
		if (HxlGraphics.smallScreen ) {
			paperdollDialog.setBackgroundGraphic(MobileUiInventoryBox);
		} else {
			paperdollDialog.setBackgroundGraphic(UiInventoryBox);
		}
		

		if (HxlGraphics.smallScreen) {
			backpack = new CqBackpackGrid(packsize, 13, div_u - 38 - 8, div_l + div_r, div_b);
			backpack.zIndex = 2;
			add(backpack);		
			
			clothingAndRings = new CqClothingGrid(equipSlots, 9, 2, paperdollDialog.width, paperdollDialog.height);
			paperdollDialog.add(clothingAndRings);

			itemInfoDialog = new CqItemInfoDialog(div_l + GAP - 27, TOP_BORDER, div_r + 50, 12 + div_u - OUTER_BORDER);
			itemInfoDialog.zIndex = 3;
			add(itemInfoDialog);
		} else {
			backpack = new CqBackpackGrid(packsize, OUTER_BORDER + 5, div_u - 38, div_l + div_r, div_b);
			backpack.zIndex = 2;
			add(backpack);
			
			clothingAndRings = new CqClothingGrid(equipSlots, 14, 10, paperdollDialog.width, paperdollDialog.height);
			paperdollDialog.add(clothingAndRings);
			
			itemInfoDialog = new CqItemInfoDialog(div_l + GAP, TOP_BORDER, div_r, div_u - OUTER_BORDER);
			itemInfoDialog.zIndex = 3;
			add(itemInfoDialog);
		}
		

		// why the HELL is this HERE?
		CqInventoryProxy.backgroundKey = CqGraphicKey.ItemBG;
		CqInventoryProxy.backgroundSelectedKey = CqGraphicKey.ItemSelectedBG;
	}
	
	override public function destroy() {
		paperdollDialog.destroy();
		itemInfoDialog.destroy();

		gameui = null;
		paperdollDialog = null;
		itemInfoDialog = null;
		
		super.destroy();
	}	
	
	public override function show(?ShowCallback:Dynamic=null) {
		Registery.player.bag.setInventoryChargeArcsVisible(true);
		
		super.show(ShowCallback);
		
		itemInfoDialog.clearInfo();
	}
	
	public override function hide(?HideCallback:Dynamic = null) {
		super.hide(HideCallback);
		
		/*if ( CqInventoryItem.selectedItem != null ) {
			CqInventoryItem.selectedItem.setSelected(false);
			CqInventoryItem.selectedItem = null;
		}*/
		itemInfoDialog.clearInfo();
		
		CqInventoryProxy.theProxyBeingDragged = null;
	}
	
	private override function hidden() {
		super.hidden();
		
		Registery.player.bag.setInventoryChargeArcsVisible(false);
	}
}
