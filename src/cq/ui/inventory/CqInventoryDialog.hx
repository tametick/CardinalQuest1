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
		uiItem.setPopup(new CqPopup(100,Item.name,gameui.doodads));
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
		// if item already in inventory (?)
		for ( cell in dlgInvGrid.cells ) {
			if ( cell.getCellObj() != null && cell.getCellObj().item.equalTo(Item) ) {
				GameUI.showTextNotification("I already have this.");
				CqRegistery.player.giveMoney( Item.getMonetaryValue() );
				return false;
			}
		}
		// because of stacking (?)
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
		
		// If this Item is equippable, and affiliated slot is open, auto equip it
		if ( Item.equipSlot != null ) {
			if ( Item.equipSlot == POTION ) {
				for ( cell in dlgPotionGrid.cells ) {
					if ( cell.getCellObj() == null ) {
						uiItem.setPotionCell(cell.cellIndex);
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
						cell.getCellObj().updateIcon();
						return false;
					}
				}
			} else {
				//item in equipment
				for ( cell in dlgEqGrid.cells ) {
					if (cast(cell, CqEquipmentCell).equipSlot == Item.equipSlot) {
						//found same quipment cell slot as item
						if (cell.getCellObj() == null) {
							//if slot was empty - equip
							//trace("move on mpty");
							uiItem = equipItem(cell, Item, uiItem);
							cell.getCellObj().updateIcon();
							return true;
						} else {
							var preference:Float = shouldEquipItemInCell(cast(cell, CqEquipmentCell), Item);
							//trace("equip cell not empty");
							if (preference > 1)	{	
								//equip if item is better
								var old:CqInventoryItem = equipItem(cell, Item, uiItem);
								
								//if old is non plain add to inv
								if (!old.item.isMagical && !old.item.isSuperb && !old.item.isWondrous) {	
									//trace("old is plain, so destroy");
									CqRegistery.player.giveMoney( old.item.getMonetaryValue() );
									GameUI.showTextNotification("I can drop the old one now.",0xBFE137);
									remove(old);
									old.destroy();
									//return false;
								} else {
									//trace("old is not pln, so add");
									uiItem = old;
								}
							} else if (preference < 1) {	
								var old:CqInventoryItem = cell.getCellObj();
								//trace("new is worse");
								//if new is worse than old, and is plain - destroy it
								if (!Item.isMagical && !Item.isSuperb && !Item.isWondrous) {
									//trace("new is pln, so destroy");
									GameUI.showTextNotification("I don't need this.");
									CqRegistery.player.giveMoney( Item.getMonetaryValue() );
									remove(uiItem);
									uiItem.destroy();
									return false;
								} else if (!old.item.isMagical && !old.item.isSuperb && !old.item.isWondrous) {
										//trace("new is magic, old is plain");
										CqRegistery.player.giveMoney( old.item.getMonetaryValue() );
										GameUI.showTextNotification("I can drop the old one now.",0x3967DF);
										remove(old);
										old.destroy();
								} else {
									//trace("old is not pln, so add");
									uiItem = old;
								}
							} else {	
								//if item is not better, and not plain - add to inventory
								if ( Item.equalTo( cell.getCellObj().item))	{
									//trace("equal, so dstroy");
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
			//trace("endng add to nvt");
			uiItem.setInventoryCell(emptyCell.cellIndex);
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

class CqInventoryGrid extends HxlDialog {

	public var cells:Array<CqInventoryCell>;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?CreateCells:Bool=true) {
		super(X, Y, Width, Height);
		
		cells = new Array();

		if ( !CreateCells ) return;
		var paddingX:Float = 3;
		var paddingY:Float = 10;
		var cellSize:Int = 64;
		var offsetX:Int = 0;

		var rows:Int = 2;
		var cols:Int = 7;
		var btn:ButtonSprite;
		for ( row in 0...rows ) {
			for ( col in 0...cols ) {
				var idx:Int = cells.length;
				var _x:Float = offsetX + ((col) * paddingX) + (col * cellSize);
				var _y:Float = ((row) * paddingY) + (row * cellSize);
				var cell:CqInventoryCell = new CqInventoryCell( _x + 5, _y + 5, cellSize, cellSize, idx);
				btn = new ButtonSprite();
				btn.x = btn.y = -5;//fix glow
				cell.add(btn);
				cell.setGraphicKeys(CqGraphicKey.EquipmentCellBG, CqGraphicKey.EqCellBGHighlight, CqGraphicKey.CellGlow);
				add(cell);
				cells.push(cell);
			}
		}
		var dropCell = cells[cells.length - 1];
		dropCell.dropCell = true;
		dropCell.setGraphicKeys(CqGraphicKey.EquipmentCellBG,CqGraphicKey.DropCellBGHighlight,CqGraphicKey.CellGlow);
	}

	public function getOpenCellIndex():Int {
		for ( i in 0...cells.length ) {
			if ( cells[i].getCellObj() == null ) return i;
		}
		return -1;
	}

	public function getCellItemPos(Cell:Int):HxlPoint {
		if ( !initialized ) {
			return new HxlPoint(x + cells[Cell].x + 2, y + cells[Cell].y + 2);
		}
		return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);

	}

	public function setCellObj(Cell:Int, CellObj:CqInventoryItem) {
		cells[Cell].setCellObj(CellObj);
	}

	public function getCellObj(Cell:Int):CqInventoryItem {
		return cells[Cell].getCellObj();
	}

	public function highlightedCellItemPos():HxlPoint {
		var Cell:CqInventoryCell = CqInventoryCell.highlightedCell;
		return new HxlPoint(Cell.x + 2, Cell.y + 2);

	}

	public function highlightedCell():CqInventoryCell {
		return CqInventoryCell.highlightedCell;
	}

}

class CqEquipmentGrid extends CqInventoryGrid {

	private var eqGridInit:Bool;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);

		cells = new Array();
		eqGridInit = false;

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;
		var cellGlowKey:CqGraphicKey = CqGraphicKey.CellGlow;

		var cellSize:Int = 54;
		var padding:Int = 8;
		var idx:Int = 0;
		var cell:CqEquipmentCell;
	
		var icons_size:Int = 16;
		var icons_x:Int = Std.int( (cellSize / 2)- (icons_size / 2) ) - 3; // -3 offset, to make it look better
		var icons_y:Int = icons_x;
		
		var icons_names:Array<String> = [ "shoes", "gloves", "armor", "jewelry", "weapon", "hat" ];
		var cell_positions:Array<Array<Int>> = [ [8, 183], [8, 100], [8, 12], [159, 183], [159, 100], [159, 12] ];
		var icons_slots:Array<CqEquipSlot> = [SHOES, GLOVES, ARMOR, JEWELRY, WEAPON, HAT];
		
		var btn:ButtonSprite;
		for (idx in 0...icons_names.length)
		{
			cell = new CqEquipmentCell(icons_slots[idx], cell_positions[idx][0]-5, cell_positions[idx][1]-5, cellSize, cellSize, idx);
			btn = new ButtonSprite();
			cell.add(btn);
			btn.x = btn.y = -5;
			cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
			cell.cell_type = CqInvCellType.Equipment;
			var icon = SpriteEquipmentIcons.getIcon(icons_names[idx], icons_size, 2.0);
			cell.add(icon);
			cell.icon = icon;
			icon.x = icons_x-5;
			icon.y = icons_y-5;
			icon.setAlpha(0.3);
			add(cell);
			cells.push(cell);
		}
	}

	public override function getCellItemPos(Cell:Int):HxlPoint {
		if ( !initialized ) {
			return new HxlPoint(x + cells[Cell].x + 2, y + cells[Cell].y + 2);
		}
		return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);
	}

	public function onItemDrag(Item:CqItem) {
		for( i in 0...cells.length ) {
			var Cell:CqEquipmentCell = cast(cells[i], CqEquipmentCell);
			if ( Item.equipSlot == Cell.equipSlot ) {
				Cell.setGlow(true);
			}
		}
	}

	public function onItemDragStop() {
		for ( i in 0...cells.length ) {
			cells[i].setGlow(false);
		}
	}

	public override function update() {
		super.update();
		if ( !eqGridInit ) {
			eqGridInit = true;
		}
	}
}

class CqSpellGrid extends CqInventoryGrid {

	public var buttons:Array<CqSpellButton>;	
	var belt:HxlSprite;

	public function forceClearCharge(Cell:Int) {
		if(buttons[Cell].getSpell()!=null)
			buttons[Cell].getSpell().spiritPoints = 0;
		
		GameUI.instance.updateCharge(buttons[Cell],0);
	}
	public function clearCharge(Cell:Int) {
		buttons[Cell].getSpell().spiritPoints = 0;
		GameUI.instance.updateCharge(buttons[Cell]);
	}
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);
		cells = new Array();

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var btnSize:Int = 64;
		var padding:Int = 8;
		var idx:Int = 0;
		buttons = new Array();
		
		belt = new HxlSprite(6, -13);
		belt.zIndex = 0;
		belt.loadGraphic(UiBeltVertical, true, false, 71, 406, false);
		belt.setFrame(0);
		add(belt);
		
		var btnSprite = new ButtonSprite();
		
		for ( i in 0...5 ) {
			var btnCell:CqSpellButton = new CqSpellButton(10, 10 + ((i * btnSize) + (i * 10)), btnSize, btnSize,i);
			
			btnCell.setBackgroundSprite(btnSprite);
			btnCell.zIndex = 1;
			add(btnCell);
			cells.push(btnCell.cell);
			buttons.push(btnCell);
		}
	}

	public override function getCellItemPos(Cell:Int):HxlPoint {
		if ( !initialized ) {
			return new HxlPoint(cells[Cell].x + 12, cells[Cell].y + 12);

		}
		return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);
	}

	public function onItemDrag(Item:CqItem) {
		for( i in 0...cells.length ) {
			var Cell:CqSpellCell = cast(cells[i], CqSpellCell);
			if ( Item.equipSlot == Cell.equipSlot ) {
				Cell.setGlow(true);
			}
		}
	}

	public function onItemDragStop() {
		for ( i in 0...cells.length ) {
			cells[i].setGlow(false);
		}
	}

}

class CqPotionGrid extends CqInventoryGrid {
	var belt:HxlSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);
		
		belt = new HxlSprite(-13, 8);
		belt.zIndex = -1;
		belt.loadGraphic(UiBeltHorizontal, false, false, 406, 71);
		add(belt);
		
		cells = new Array();

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var btnSize:Int = 64;
		var padding:Int = 8;
		var idx:Int = 0;
			
		var btnSprite = new ButtonSprite();
		
		for ( i in 0...5 ) {
			var btnCell:CqPotionButton = new CqPotionButton(this, 10 + ((i * btnSize) + (i * 10)), 10, btnSize, btnSize,i);
			btnCell.setBackgroundSprite(btnSprite);
			add(btnCell);
			cells.push(btnCell.cell);
		}

	}

	public function onItemDrag(Item:CqItem) {
		for( i in 0...cells.length ) {
			var Cell:CqPotionCell = cast(cells[i], CqPotionCell);
			if ( Item.equipSlot == Cell.equipSlot ) {
				Cell.setGlow(true);
			}
		}
	}

	public function onItemDragStop() {
		for ( i in 0...cells.length ) {
			cells[i].setGlow(false);
		}
	}

	public override function getCellItemPos(Cell:Int):HxlPoint {
		if ( !initialized ) {
			return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);
		}
		return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);
	}
}

enum CqInvCellType {
	Equipment;
	Spell;
	Potion;
}

class CqInventoryCell extends HxlDialog {

	public static var highlightedCell:CqInventoryCell = null;
	var cellObj:CqInventoryItem;
	var bgHighlight:HxlSprite;
	var bgGlow:HxlSprite;
	var isHighlighted:Bool;
	public var cellIndex:Int;
	public var dropCell:Bool;
	public var cell_type:CqInvCellType;
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?CellIndex:Int=0) {
		super(X, Y, Width, Height);
		bgHighlight = null;
		bgGlow = null;
		cellObj = null;
		isHighlighted = false;
		cellIndex = CellIndex;
		dropCell = false;
	}

	public function setGraphicKeys(Normal:CqGraphicKey, ?Highlight:CqGraphicKey = null, ?Glow:CqGraphicKey = null) {
		if ( bgHighlight == null ) {
			bgHighlight = new HxlSprite(0, 0);
			bgHighlight.zIndex = 1;
			add(bgHighlight);
			bgHighlight.visible = false;
		}
		
		if ( bgGlow == null ) {
			bgGlow = new HxlSprite(-19,-19);
			bgGlow.zIndex = -3;
			add(bgGlow);
			bgGlow.visible = false;
		}
		
		setBackgroundKey(Normal);
		
		if ( Highlight == null ) 
			Highlight = Normal;
			
		bgHighlight.loadCachedGraphic(Highlight);
		
		if ( Glow == null ) 
			Glow = Normal;
			
		bgGlow.loadCachedGraphic(Glow);
		origin.x = Std.int(background.width / 2);
		origin.y = Std.int(background.height / 2);
		
		if ( dropCell )
			initDropCell();
	}
	
	function initDropCell()	{
		var icon = SpriteEquipmentIcons.getIcon("destroy", 16, 2.0);
		icon.setAlpha(0.3);
		add(icon);
		icon.x += 13;
		icon.y += 3;
			
		var droptext:HxlText = new HxlText(-5, 35, Std.int(width), "Destroy");
		droptext.setFormat(FontAnonymousPro.instance.fontName, 12, 0xffffff, "center", 0x010101);
		droptext.zIndex = 10;
		droptext.setAlpha(0.3);
		add(droptext);
	}
	
	public override function update() {
		super.update();
		if ( isHighlighted ) {
			if ( !visible || HxlGraphics.mouse.dragSprite == null || !itemOverlap() ) {	
				setHighlighted(false);
			}
		} else if ( visible && HxlGraphics.mouse.dragSprite != null && itemOverlap() ) {
			setHighlighted(true);
		}
	}

	function itemOverlap():Bool {
		var myX = x + origin.x;
		var myY = y + origin.y;
		var objX = HxlGraphics.mouse.dragSprite.x;
		var objY = HxlGraphics.mouse.dragSprite.y;
		var objW = HxlGraphics.mouse.dragSprite.width;
		var objH = HxlGraphics.mouse.dragSprite.height;
		if ( (myX <= objX) || (myX >= objX+objW) || (myY <= objY) || (myY >= objY+objH) ) {
			return false;
		}
		return true;
	}

	function setHighlighted(Toggle:Bool) {
		isHighlighted = Toggle;
		//setGlow(Toggle);
		if ( isHighlighted ) {
			background.visible = false;
			bgHighlight.visible = true;
			highlightedCell = this;
		} else {
			background.visible = true;
			bgHighlight.visible = false;
			if ( highlightedCell == this ) highlightedCell = null;
		}
	}

	public function setGlow(Toggle:Bool) {
		bgGlow.visible = Toggle;
	}

	public function setCellObj(CellObj:CqInventoryItem) {
		cellObj = CellObj;
	}

	public function getCellObj():CqInventoryItem {
		return cellObj;
	}
	
	public function clearCellObj():CqInventoryItem {
		var oldItem:CqInventoryItem = null;
		if (cellObj != null) {
			oldItem = cellObj;
			CqRegistery.player.unequipItem(cellObj.item);
			cellObj.removeFromDialog();
			cellObj = null;
		}
		return oldItem;
	}
}

class CqEquipmentCell extends CqInventoryCell {

	public static var highlightedCell:CqInventoryCell = null;
	public var equipSlot:CqEquipSlot; // This should be read only
	public var eqCellInit:Bool;
	public var icon:HxlSprite;
	public function new(EquipSlot:CqEquipSlot, ?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?CellIndex:Int=0) {
		super(X, Y, Width, Height, CellIndex);
		equipSlot = EquipSlot;
		eqCellInit = false;
	}

	override function setHighlighted(Toggle:Bool) {
		if ( Toggle && cast(HxlGraphics.mouse.dragSprite, CqInventoryItem).item.equipSlot != equipSlot ) return; 
		super.setHighlighted(Toggle);
	}

	public override function update() {
		super.update();
		if ( !eqCellInit ) {
			eqCellInit = true;
		}
	}

}

class CqInventoryItem extends HxlSprite {
	public static var backgroundKey:CqGraphicKey;
	public static var backgroundSelectedKey:CqGraphicKey;
	public static var selectedItem:CqInventoryItem = null;
	var background:BitmapData;
	var icon:BitmapData;
	public var _dlg:CqInventoryDialog;
	var idleZIndex:Int;
	var dragZIndex:Int;
	var cellIndex:Int;
	var clearCharge:Bool;
	//these are true only when the item is in that particular cell, to see if goes where use cQitem.equipSlot
	public var cellEquip:Bool;
	public var cellSpell:Bool;
	public var cellPotion:Bool;
	public var item:CqItem;
	var selected:Bool;
	//var stackText:HxlText;
	//var stackSize:Int;
	var isGlowing:Bool;
	var glowSprite:BitmapData;
	var glowRect:Rectangle;

	public function new(Dialog:CqInventoryDialog, ?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		icon = null;
		idleZIndex = 11;
		dragZIndex = 11;
		_dlg = Dialog;
		cellIndex = 0;
		cellEquip = false;
		cellSpell = false;
		cellPotion = false;
		item = null;
		zIndex = idleZIndex;
		setSelected(false);
		//stackSize = 1;
		glowRect = new Rectangle(0, 0, 58, 58);
		isGlowing = false;
	}

	public function removeFromDialog() {
		_dlg.remove(this);
	}
	
	public function setSelected(Toggle:Bool) {
		selected = Toggle;
		if ( selected ) {
			loadCachedGraphic(backgroundSelectedKey);
			background = GraphicCache.getBitmap(backgroundSelectedKey);
			if ( icon != null ) setIcon(icon);
			_dlg.dlgInfo.setItem(item);
		} else {
			loadCachedGraphic(backgroundKey);
			background = GraphicCache.getBitmap(backgroundKey);
			if ( icon != null ) setIcon(icon);
		}
	}
	
	public function customGlow(color:Int) {
		var tmp:BitmapData = new BitmapData(48, 48, true, 0x0);
		tmp.copyPixels(getFramePixels(), new Rectangle(0, 0, 48, 48), new Point(0, 0), null, null, true);
		var glow:GlowFilter = new GlowFilter(color, 0.9, 16.0, 16.0, 1.6, 1, false, false);
		tmp.applyFilter(tmp, glowRect, new Point(0, 0), glow);
		glowSprite = tmp;
		glow = null;
	}
	
	public function setGlow(Toggle:Bool) {
		isGlowing = Toggle;
		if (isGlowing)
			renderGlow();
	}
	
	function renderGlow() {
		//return;
		getScreenXY(_point);
		_flashPoint.x = _point.x - 8;
		_flashPoint.y = _point.y - 8;
		_pixels.copyPixels(glowSprite, glowRect, _flashPoint, null, null, true);
		setPixels(glowSprite);
	}
	
	public function updateIcon() {
		setIcon(icon);
	}

	public function setIcon(Icon:BitmapData) {
		icon = new BitmapData(Icon.width, Icon.height, true, 0x0);
		icon.copyPixels(Icon, new Rectangle(0, 0, Icon.width, Icon.height), new Point(0,0), null, null, true);
		var X:Int = Std.int((width / 2) - (icon.width / 2));
		var Y:Int = Std.int((height / 2) - (icon.height / 2));
		var temp:BitmapData = new BitmapData(background.width, background.height, true, 0x0);
		temp.copyPixels(background, new Rectangle(0, 0, background.width, background.height), new Point(0, 0), null, null, true);
		temp.copyPixels(icon, new Rectangle(0, 0, icon.width, icon.height), new Point(X, Y), null, null, true);
		if ( item.stackSize > 1 ) {
			var txt:HxlText = new HxlText(0, 0, Std.int(width), ""+item.stackSize);
			txt.setProperties(false, false, false);
			txt.setFormat(null, 18, 0xffffff, "right", 0x010101);
			temp.copyPixels(txt.pixels, new Rectangle(0, 0, txt.width, txt.height), new Point(0, (height-2-txt.height)), null, null, true);
		}
		pixels = temp;
		if (isGlowing)
			renderGlow();
	}

	/**
	 * Sets this object as the CellObj of the target inventory cell, and places this object within that cell.
	 **/
	public function setInventoryCell(Cell:Int) {		
		if (cellSpell) {
			CqRegistery.player.equippedSpells[cellIndex] = null;
			_dlg.dlgSpellGrid.forceClearCharge(cellIndex);
		}
		
		_dlg.dlgSpellGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;
		_dlg.add(this);

		cellIndex = Cell;
		setPos(_dlg.dlgInvGrid.getCellItemPos(Cell));
		_dlg.dlgInvGrid.setCellObj(Cell, this);
		cellEquip = false;
		cellSpell = false;
		cellPotion = false;
	}

	function getEquipmentCell(Index:Int):CqEquipmentCell {
		return cast(_dlg.dlgEqGrid.cells[Index], CqEquipmentCell);
	}
	
	function getSpellCell(Index:Int):CqSpellCell {
		return cast(_dlg.dlgSpellGrid.cells[Index], CqSpellCell);
	}
	
	/**
	 * Sets this object as the CellObj of the target equipment cell, and places this object within that cell.
	 **/
	public function setEquipmentCell(Cell:Int):Bool {
		_dlg.dlgSpellGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;
		_dlg.add(this);
		var cellRef:CqEquipmentCell = cast(_dlg.dlgEqGrid.cells[Cell], CqEquipmentCell);
		if ( cellRef.equipSlot != this.item.equipSlot ) {
			Cell = _dlg.dlgInvGrid.getOpenCellIndex();
			setInventoryCell(Cell);
			return false;
		}
		cellRef.icon.visible = false;
		cellIndex = Cell;
		setPos(_dlg.dlgEqGrid.getCellItemPos(Cell));
		_dlg.dlgEqGrid.setCellObj(Cell, this);
		cellEquip = true;
		cellSpell = false;
		cellPotion = false;
		return true;
	}

	/**
	 * Sets this object as the CellObj of the target spell cell, and places this object within that cell.
	 **/
	public function setSpellCell(Cell:Int):Bool {
		if (cellSpell) {
			// if it was already in a different spell cell before moving to the new spell cell
			CqRegistery.player.equippedSpells[cellIndex] = null;
			//_dlg.dlgSpellGrid.forceClearCharge(cellIndex);
		}
		
		_dlg.dlgSpellGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;
		if (_dlg.dlgSpellGrid.cells.length <= Cell)
			return false;
		
		if ( cast(_dlg.dlgSpellGrid.cells[Cell], CqEquipmentCell).equipSlot != this.item.equipSlot ) {
			Cell = _dlg.dlgInvGrid.getOpenCellIndex();
			setInventoryCell(Cell);
			return false;
		}

		_dlg.dlgSpellGrid.add(this);
		cellIndex = Cell;
		setPos(_dlg.dlgSpellGrid.getCellItemPos(Cell));
		_dlg.dlgSpellGrid.setCellObj(Cell, this);
		cellSpell = true;
		cellEquip = false;
		cellPotion = false;
		
		CqRegistery.player.equippedSpells[cellIndex] = cast(this.item,CqSpell);
		
		return true;
	}

	/**
	 * Sets this object as the CellObj of the target potion cell, and places this object within that cell.
	 **/
	public function setPotionCell(Cell:Int):Bool {
		_dlg.dlgPotionGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;

		if ( cast(_dlg.dlgPotionGrid.cells[Cell], CqEquipmentCell).equipSlot != this.item.equipSlot ) {
			Cell = _dlg.dlgInvGrid.getOpenCellIndex();
			setInventoryCell(Cell);
			return false;
		}

		_dlg.dlgPotionGrid.add(this);
		cellIndex = Cell;
		setPos(_dlg.dlgPotionGrid.getCellItemPos(Cell));
		_dlg.dlgPotionGrid.setCellObj(Cell, this);
		cellSpell = false;
		cellEquip = false;
		cellPotion = true;
		return true;
	}
	public function setPos(Pos:HxlPoint) {
		x = Pos.x;
		y = Pos.y;
	}

	public override function toggleDrag(Toggle:Bool) {
		super.toggleDrag(Toggle);
		if ( dragEnabled ) {
			removeEventListener(MouseEvent.MOUSE_DOWN, onDragMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, onDragMouseUp);
			addEventListener(MouseEvent.MOUSE_DOWN, onDragMouseDown, true, 5,true);
			addEventListener(MouseEvent.MOUSE_UP, onDragMouseUp, true, 4,true);
		}
	}

	private override function onDragMouseDown(event:MouseEvent) {
		if ( !Std.is(GameUI.currentPanel,CqInventoryDialog) ) 
			return;
		super.onDragMouseDown(event);
		if ( isDragging ) {
			event.stopPropagation();
			if ( selectedItem != null ) {
				// Unset the old selected item if one was set
				selectedItem.setSelected(false);
				selectedItem = null;
			}
			// I now become the selected item
			selectedItem = this;
			setSelected(true);
		}
	}

	private override function onDragMouseUp(event:MouseEvent) {
		if ( !exists || !visible || !active || !dragEnabled || !Std.is(GameUI.currentPanel,CqInventoryDialog) || HxlGraphics.mouse.dragSprite != this ) 
			return;
		super.onDragMouseUp(event);
		if ( !isDragging ) {
			event.stopPropagation();
		}
	}

	override function dragStart() {
		if (cellEquip) {
			var cellRef:CqEquipmentCell = cast(_dlg.dlgEqGrid.cells[cellIndex], CqEquipmentCell);
			cellRef.icon.visible = true;
		}
		
		//if its moved from an spell cell, make it not clear charge after dragging stops
		if (item.equipSlot == CqEquipSlot.SPELL) {
			if (cellSpell)
				clearCharge = false;
			else
				clearCharge = true;
		}
		
		_dlg.remove(this);
		_dlg.dlgSpellGrid.remove(this);
		_dlg.dlgPotionGrid.remove(this);
		zIndex = 400;
		_dlg.add(this);
		_dlg.dlgEqGrid.onItemDrag(this.item);
		_dlg.dlgSpellGrid.onItemDrag(this.item);
		_dlg.dlgPotionGrid.onItemDrag(this.item);
		super.dragStart();
	}
	
	// If the user was hovering an eligable drop target, act on it
	override function dragStop() {
		//collect info
		var dragStopCell:CqInventoryCell = CqInventoryCell.highlightedCell;
		var dragStopCell_class:Dynamic = Type.getClass(dragStopCell);
		var dragStopCell_type:String = (cellEquip?"equip":"") + (cellSpell?"spell":"") + (cellPotion?"potion":"");
		
		
		if ( dragStopCell != null ) {
			
			var dragStop_cell_obj:CqInventoryItem = dragStopCell.getCellObj();	
			if ( dragStop_cell_obj != null )
			{
				if(dragStop_cell_obj == this)
					stopdrag_gotoSameCell(dragStopCell_class, dragStopCell_type, dragStopCell);
				else
					stopdrag_gotoOccupiedCell(dragStopCell_class, dragStopCell_type, dragStopCell,dragStop_cell_obj);
			}else
				stopdrag_gotoEmptyCell(dragStopCell_class, dragStopCell_type, dragStopCell);
			
		} else {
			stopdrag_revert();
		}
		_dlg.dlgEqGrid.onItemDragStop();
		_dlg.dlgSpellGrid.onItemDragStop();
		_dlg.dlgPotionGrid.onItemDragStop();
		super.dragStop();
	}
	
	//when user drops item in same place he picked it up
	private function stopdrag_gotoSameCell(dragStopCell_class:Dynamic, dragStopCell_type:String, dragStopCell:CqInventoryCell):Void 
	{
		//trace("s c");
		switch(dragStopCell_class) {
			case CqSpellCell:
				// Moving this item into a spell cell
				setSpellCell(dragStopCell.cellIndex);
			case CqPotionCell:
				// Moving this item into a potion cell
				setPotionCell(dragStopCell.cellIndex);
			case CqEquipmentCell:
				// Moving this item into an equipment cell
				setEquipmentCell(dragStopCell.cellIndex);
			case CqInventoryCell:
				// Moving this item into an inventory cell
				setInventoryCell(dragStopCell.cellIndex);
		}
	}
	
	//when user drops item on another item
	private function stopdrag_gotoOccupiedCell(dragStopCell_class:Dynamic, dragStopCell_type:String, dragStopCell:CqInventoryCell,dragStop_cell_obj:CqInventoryItem) {
		//trace("o c");
		// There was already an item in the target cell, switch places with it
		switch(dragStopCell_type) {
			case "equip":
				// Unequipping current item (?)
				//trace("from eq cell");
			case "spell":
				// Moving the other item into a spell cell
				dragStop_cell_obj.setSpellCell(cellIndex);
				var spellBtn = cast(getSpellCell(cellIndex), CqSpellCell).btn;
				if (dragStop_cell_obj != this)
					GameUI.instance.updateCharge(spellBtn);
			case "potion":
				// Moving the other item into a potion cell
				dragStop_cell_obj.setPotionCell(cellIndex);
			default:
			
				// Moving the other item into an inventory cell
				dragStop_cell_obj.setInventoryCell(cellIndex);
		}
		
		if (item.equipSlot != CqEquipSlot.POTION &&  item.equipSlot != CqEquipSlot.SPELL) {
			if (cellEquip || dragStop_cell_obj.cellEquip)
			{
				//trace("equip aboom");
				if (dragStop_cell_obj.item != item)
					CqRegistery.player.unequipItem(item);
					CqRegistery.player.equipItem(dragStop_cell_obj.item);
					dragStop_cell_obj.setEquipmentCell(cellIndex);
					//trace("old over new");
			}
			//else trace("equip new, unequip old not ceq");
			//trace("equip block");
			
			// Moving the other item into an equipment cell (?)
			//CqRegistery.player.unequipItem(other.item);
			//if ( other.setEquipmentCell(cellIndex) && other!=this) 
			//	CqRegistery.player.equipItem(item);
		}
		
		// here i need the cases.
		//moving from inv to equip:
		
		switch(dragStopCell_class) {
			case CqSpellCell:
				// Moving this item into a spell cell
				setSpellCell(dragStopCell.cellIndex);
			case CqPotionCell:
				// Moving this item into a potion cell
				setPotionCell(dragStopCell.cellIndex);
			case CqEquipmentCell:
				// Moving this item into an equipment cell
				//trace("move to eqcell");
				if (dragStop_cell_obj != this)
				{
					CqRegistery.player.unequipItem(dragStop_cell_obj.item);
					CqRegistery.player.equipItem(this.item);
					//trace("move up");
				}
				//trace("move new to others place");
				setEquipmentCell(dragStopCell.cellIndex);
				
			case CqInventoryCell:
				// Moving this item into an inventory cell
				setInventoryCell(dragStopCell.cellIndex);
			default:
				//trace("unknown cell class");
		}
		cellIndex = dragStopCell.cellIndex;
	}
	
	//return to pre drag position, when item dropped on invalid area
	private function stopdrag_revert() {
		//trace("rv");
		_dlg.remove(this);
		setPos(dragStartPoint);
		
		//if last cell was of type == item equipslot, means its from that dialog, so add there
		if (item.equipSlot == CqEquipSlot.POTION && cellPotion)
		{
			_dlg.dlgPotionGrid.add(this);
		}else if (item.equipSlot == CqEquipSlot.SPELL && cellSpell)
		{
			_dlg.dlgSpellGrid.add(this);
		}else {
			//else add to inv
			_dlg.dlgInvGrid.add(this);
		}
	}
	
	// when item dropped on a empty cell
	private function stopdrag_gotoEmptyCell(dragStopCell_class:Dynamic,dragStopCell_type:String,dragStopCell:CqInventoryCell) {
		//trace("e c");
		
		switch(dragStopCell_type) {
			//where it came from
			
			case "equip":
				// Clearing out an equipment cell
				_dlg.dlgEqGrid.setCellObj(cellIndex, null);
				CqRegistery.player.unequipItem(this.item);
			case "spell":
				// Clearing out a spell cell
				var cellIndexNew = dragStopCell.cellIndex;
				var spellCell = getSpellCell(cellIndex); 
				var spellBtn = spellCell.btn;
				_dlg.dlgSpellGrid.setCellObj(cellIndex, null);
				setSpellCell(dragStopCell.cellIndex);
				GameUI.instance.updateCharge(spellBtn);
			case "potion":
				// Clearing out a potion cell
				_dlg.dlgPotionGrid.setCellObj(cellIndex, null);
				//setPotionCell(cellIndex); //might help with the bug, investigate more.
			default:
				// Clearing out an inventory cell
				_dlg.dlgInvGrid.setCellObj(cellIndex, null);
		}
		
		switch(dragStopCell_class){
			case CqSpellCell:
				// Moving this item into a spell cell
				setSpellCell(dragStopCell.cellIndex);
				var spellCell = getSpellCell(dragStopCell.cellIndex); 
				var spellBtn = spellCell.btn;
				GameUI.instance.updateCharge(spellBtn);
				if(clearCharge)_dlg.dlgSpellGrid.forceClearCharge(dragStopCell.cellIndex);
			case CqPotionCell:
				// Moving this item into a potion cell
				setPotionCell(dragStopCell.cellIndex);
			case CqEquipmentCell:
				// Moving this item into an equipment cell
				setEquipmentCell(dragStopCell.cellIndex);
				CqRegistery.player.equipItem(this.item);
			default:
				if ( dragStopCell.dropCell ) {
					// This item is being dropped
					CqRegistery.player.giveMoney( item.getMonetaryValue() );
					_dlg.remove(this);
					destroy();
					CqRegistery.player.removeInventory(this.item);
					_dlg.dlgEqGrid.onItemDragStop();
					_dlg.dlgSpellGrid.onItemDragStop();
					_dlg.dlgPotionGrid.onItemDragStop();
					_dlg.dlgInfo.clearInfo();
					//_dlg.gameui.checkTileItems(CqRegistery.player);
					return;
				} else {
					setInventoryCell(dragStopCell.cellIndex);
				}
		}
		cellIndex = dragStopCell.cellIndex;
	}
	
	//check if this CQinventoryItem is over the char equipment silhouette
	inline function isOnCharSilhouette():Bool {
		var myX = x + origin.x;
		var myY = y + origin.y;
		var objX = _dlg.dlgCharacter.x+80;
		var objY = _dlg.dlgCharacter.y+40;
		var objW = 80;
		var objH = 200;
		return  ( (myX >= objX) || (myX <= objX + objW) || (myY >= objY) || (myY <= objY + objH) );
	}
}
