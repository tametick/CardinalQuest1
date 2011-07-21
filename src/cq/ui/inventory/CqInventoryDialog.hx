package cq.ui.inventory;

import cq.ui.CqItemInfoDialog;
import cq.ui.CqPotionButton;
import cq.ui.CqSpellButton;
import cq.ui.CqPopup;
import cq.CqActor;
import cq.CqItem;
import cq.CqResources;
import cq.CqSpell;
import cq.CqGraphicKey;
import cq.CqRegistery;
import data.Resources;
import data.Configuration;
import haxel.GraphicCache;
import world.Tile;

import flash.display.BitmapData;
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


class CqInventoryDialog extends HxlSlidingDialog {
	public var gameui:GameUI;
	public var dlgCharacter:HxlDialog;
	public var dlgInfo:CqItemInfoDialog;
	public var dlgInvGrid:CqInventoryGrid;
	public var dlgEqGrid:CqEquipmentGrid;
	public var dlgSpellGrid:CqSpellGrid;
	public var dlgPotionGrid:CqPotionGrid;
	var itemSheet:HxlSpriteSheet;
	var itemSprite:HxlSprite;
	var spellSheet:HxlSpriteSheet;
	var spellSprite:HxlSprite;

	static inline var DLG_OUTER_BORDER:Int 		= 10; 
	static inline var DLG_TOP_BORDER:Int 		= 0; 
	static inline var DLG_GAP:Int 				= 15; 
	static inline var DLG_DIVISOR_H_PERCENT:Int = 75;
	static inline var DLG_DIVISOR_V_PERCENT:Int = 55;
	
	public function new(_GameUI:GameUI, ?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0) {
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);
		
		gameui = _GameUI;
		
		var div_l:Float = (Width * (DLG_DIVISOR_V_PERCENT / 100)) - DLG_OUTER_BORDER*2;
		var div_r:Float = (Width * ((100-DLG_DIVISOR_V_PERCENT) / 100))-DLG_OUTER_BORDER*2;
		var div_u:Float  = (Height * (DLG_DIVISOR_H_PERCENT / 100))-DLG_TOP_BORDER*2;
		var div_b:Float  = (Height * ((100 - DLG_DIVISOR_H_PERCENT) / 100))-DLG_TOP_BORDER*2;
		
		//on the left
		dlgCharacter = new HxlDialog(DLG_OUTER_BORDER, DLG_TOP_BORDER, div_l-DLG_OUTER_BORDER, div_u-DLG_OUTER_BORDER);
		add(dlgCharacter);
		dlgCharacter.setBackgroundGraphic(UiInventoryBox);
		
		//in dlgCharacter
		dlgEqGrid = new CqEquipmentGrid(14, 10, dlgCharacter.width, dlgCharacter.height);
		dlgCharacter.add(dlgEqGrid);

		//on the right
		dlgInfo = new CqItemInfoDialog(div_l + DLG_GAP, DLG_TOP_BORDER, div_r, div_u - DLG_OUTER_BORDER);
		dlgInfo.zIndex = 3;
		add(dlgInfo);

		//on the bottom
		dlgInvGrid = new CqInventoryGrid(DLG_OUTER_BORDER + 5, div_u - 38, div_l + div_r, div_b);
		dlgInvGrid.zIndex = 2;
		add(dlgInvGrid);

		itemSheet = SpriteItems.instance;
		var itemSheetKey:CqGraphicKey = CqGraphicKey.ItemIconSheet;
		itemSprite = new HxlSprite(0, 0);
		itemSprite.loadGraphic(SpriteItems, true, false, Configuration.tileSize, Configuration.tileSize, false, 3.0, 3.0);
		dlgInfo.itemSheet = itemSheet;
		dlgInfo.itemSprite = itemSprite;

		spellSheet = SpriteSpells.instance;
		var spellSheetKey:CqGraphicKey = CqGraphicKey.SpellIconSheet;
		spellSprite = new HxlSprite(0, 0);
		spellSprite.loadGraphic(SpriteSpells, true, false, Configuration.tileSize, Configuration.tileSize, false, 3.0, 3.0);
		dlgInfo.spellSheet = spellSheet;
		dlgInfo.spellSprite = spellSprite;

		CqInventoryItem.backgroundKey = CqGraphicKey.ItemBG;
		CqInventoryItem.backgroundSelectedKey = CqGraphicKey.ItemSelectedBG;
	}

	function createUIItem(Item:CqItem, dialog:CqInventoryDialog):CqInventoryItem {
		
		//basic stuff
		var uiItem:CqInventoryItem = new CqInventoryItem(dialog, 2, 2);
		uiItem.toggleDrag(true);
		uiItem.zIndex = 5;
		uiItem.item = Item;
		
		if ( Std.is(Item, CqSpell) ) {
			spellSprite.setFrame(spellSheet.getSpriteIndex(Item.spriteIndex));
			uiItem.setIcon(spellSprite.getFramePixels());
		} else {
			itemSprite.setFrame(itemSheet.getSpriteIndex(Item.spriteIndex));
			uiItem.setIcon(itemSprite.getFramePixels());
		}
		
		//popup
		uiItem.setPopup(new CqPopup(120,Item.fullName,gameui.doodads));
		gameui.doodads.add(uiItem.popup);
		uiItem.popup.zIndex = 15;
		
		//make magical items glow
		if (Item.isSuperb && !Item.isMagical && !Item.isWondrous) {
			uiItem.customGlow(0x206CDF);
			uiItem.setGlow(true);
		} else if (Item.isMagical && !Item.isSuperb)	{
			uiItem.customGlow(0x3CDA25);
			uiItem.setGlow(true);
		} else if (Item.isMagical && Item.isSuperb)	{
			uiItem.customGlow(0x1FE0D7);
			uiItem.setGlow(true);
		} else if (Item.isWondrous && Item.isSuperb)	{
			uiItem.customGlow(0xE7A918);
			uiItem.setGlow(true);
		}
		return uiItem;
	}
	
	/**
	 * True - added to inventory or equipped
	 * False - destroyed or added to potion/spell belts
	 * */
	public function itemPickup(Item:CqItem):Bool {
		// if an equivalent item already in inventory, destory picked up item
		for ( cell in dlgInvGrid.cells ) {
			if ( cell.getCellObj() != null && cell.getCellObj().item.equalTo(Item) && Item.equipSlot != SPELL) {
				GameUI.showTextNotification("I already have this.");
				CqRegistery.player.giveMoney( Item.getMonetaryValue() );
				return false;
			}
		}
		
		// stacking was already done by CqActor.give(...), just updating potion icon
		if ( Item.equipSlot == POTION ) {
			for ( cell in dlgPotionGrid.cells ) {
				if ( cell.getCellObj() != null && cell.getCellObj().item == Item ) {
					cell.getCellObj().updateIcon();
					return false;
				}
			}
		}
		
		// select picked up item
		dlgInfo.setItem(Item);
		
		//create ui item
		var uiItem:CqInventoryItem = createUIItem(Item,this);
		add(uiItem);
		
		
		if ( Item.equipSlot != null ) {
			if ( Item.equipSlot == POTION ) {
				for ( cell in dlgPotionGrid.cells ) {
					if ( cell.getCellObj() == null ) {
						uiItem.setPotionCell(cell.cellIndex);
						uiItem.popup.setText(Item.fullName+"\n[hotkey " + ((cell.cellIndex>3)?cell.cellIndex-4:cell.cellIndex + 6) + "]");
						if ( !cast(cell, CqPotionCell).eqCellInit ) {
							// Mysterious things happen with positioning before the ui
							// stuff gets updated for the first time.. just accommodate for it
							// now.
							uiItem.x = uiItem.x + cast(cell, CqPotionCell).potBtn.x;
							uiItem.y = uiItem.y + cast(cell, CqPotionCell).potBtn.y;
						}
						return false;
					}
				}
			} else if ( Item.equipSlot == SPELL ) {
				for ( cell in dlgSpellGrid.cells ) {
					if ( cell.getCellObj() == null ) {
						uiItem.setSpellCell(cell.cellIndex);
						uiItem.popup.setText(Item.fullName+"\n[hotkey " + (cell.cellIndex + 1) + "]");
						cell.getCellObj().updateIcon();
						return false;
					}
				}
			} else {
				//item in equipment
				for ( cell in dlgEqGrid.cells ) {
					//found same quipment cell slot as item
					if (cast(cell, CqEquipmentCell).equipSlot == Item.equipSlot) {

						//if slot was empty - equip
						if (cell.getCellObj() == null) {
							uiItem = equipItem(cell, Item, uiItem);
							cell.getCellObj().updateIcon();
							return true;
						} else {
							
							var preference:Float = shouldEquipItemInCell(cast(cell, CqEquipmentCell), Item);
							
							//equip if item is better
							if (preference > 1)	{	
								var old:CqInventoryItem = equipItem(cell, Item, uiItem);
								
								if (!old.item.isEnchanted) {	
									// old is plain, so destroy
									GameUI.showTextNotification("I can drop the old one now.", 0xBFE137);
									CqRegistery.player.giveMoney( old.item.getMonetaryValue() );
									remove(old);
									old.destroy();

									return true;
								} else {
									// old is non plain add to inv
									uiItem = old;
								}
							} else if (preference < 1) {
								//if new is worse than old, and is plain - destroy it
								if (!Item.isEnchanted) {
									GameUI.showTextNotification("I don't need this.");
									CqRegistery.player.giveMoney( Item.getMonetaryValue() );
									remove(uiItem);
									uiItem.destroy();
									
									return false;
								}
							} else {	
								//item is the same & plain
								if ( Item.equalTo( cell.getCellObj().item) && !Item.isEnchanted) {
									CqRegistery.player.giveMoney( Item.getMonetaryValue() );
									GameUI.showTextNotification("I already have this.",0xE1CC37);
									remove(uiItem);
									uiItem.destroy();
									return false;
								}
							}
						}
					}
				}
			}
		}
		
		var emptyCell:CqInventoryCell = getEmptyCell();
		if (emptyCell != null ) {
			// add to inventory
			uiItem.setInventoryCell(emptyCell.cellIndex);
			uiItem.popup.setText(Item.fullName);
			return true;
		} else {
			throw "no room in inventory, should not happen because pick up should have not been allowed!";
		}
	}
	
	private function equipItem(Cell:CqInventoryCell, Item:CqItem, UiItem:CqInventoryItem):CqInventoryItem {
		var old:CqInventoryItem = cast(Cell, CqEquipmentCell).clearCellObj();
		
		UiItem.setEquipmentCell(Cell.cellIndex);
		if ( !cast(Cell, CqEquipmentCell).eqCellInit ) {
			// Mysterious things happen with positioning before the ui
			// stuff gets updated for the first time.. just accommodate for it
			// now.
			UiItem.x = UiItem.x + 10;
		}
		
		CqRegistery.player.equipItem(Item);
		return old;
	}
	
	
	/**
	 * <1 yes 1 == equal, >1 no
	 * */
	function shouldEquipItemInCell(Cell:CqEquipmentCell, Item:CqItem):Float {
		if (Cell.equipSlot != Item.equipSlot)
			return 0.0;
		
		if (Cell.getCellObj() == null)
			return 2.0;
		
		return Item.compareTo( Cell.getCellObj().item );
	}
	
	public function getEmptyCell():CqInventoryCell {
		var emptyCell:CqInventoryCell = null;
		for ( cell in dlgInvGrid.cells ) {
			if ( cell.getCellObj() == null && !cell.dropCell ) {
				emptyCell = cell;
				break;
			}
		}
		
		return emptyCell;
	}
	

	public override function hide(?HideCallback:Dynamic=null) {
		super.hide(HideCallback);
		if ( CqInventoryItem.selectedItem != null ) {
			CqInventoryItem.selectedItem.setSelected(false);
			CqInventoryItem.selectedItem = null;
		}
		dlgInfo.clearInfo();
	}

}
