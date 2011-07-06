package cq;

import cq.CqActor;
import cq.CqItem;
import cq.CqItemInfoDialog;
import cq.CqPotionButton;
import cq.CqResources;
import cq.CqSpell;
import cq.CqSpellButton;
import cq.ui.CqPopup;
import cq.ui.ItemCellGroups;
import data.Resources;
import haxel.GraphicCache;

import data.Configuration;
import cq.CqRegistery;
import world.Tile;

import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

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
import cq.CqGraphicKey;

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
	//
	static public var itemCell_groups:ItemCellGroups = new ItemCellGroups();
	
	public function new(_GameUI:GameUI, ?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
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

	/**
	 * True - added to inventory or equipped
	 * False - destroyed or added to potion/spell belts
	 * */
	
	public function itemPickup(Item:CqItem):Bool {
		// if item already in inventory (?)
		for ( cell in dlgInvGrid.cells ) {
			if ( cell.getCellObj() != null && cell.getCellObj().item == Item ) {
				cell.getCellObj().updateIcon();
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
		
		var uiItem:CqInventoryItem = new CqInventoryItem(this, 2, 2);
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
		add(uiItem);
		uiItem.setPopup(new CqPopup(100,Item.name,this ));
		add(uiItem.popup);
		uiItem.popup.zIndex = 600;
				
		// If this uiItem is equippable, and affiliated slot is open, auto equip it
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
						
						//GameUI.instance.updateCharge(cast(cell, CqSpellCell).btn);
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
							equipItem(cell, Item, uiItem);
							return true;
						} else {
							var preference:Float = shouldEquipItemInCell(cast(cell, CqEquipmentCell), Item);
							
							if (preference > 1)
							{	//equip if item is better
								var old:CqInventoryItem = equipItem(cell, Item, uiItem);
								//if old is non plain add to inv
								if (!old.item.isMagical && !old.item.isSuperb && !old.item.isWondrous)
									return false;
							}else if (!Item.isMagical && !Item.isSuperb && !Item.isWondrous && preference <1)
							{	//if item is worse than current, and is plain - destroy it
								remove(uiItem);
								return false;
							}else
							{	//if item is not better, and not plain - add to inventory
								if ( Item.equalTo( cell.getCellObj().item))
								{
									//remove old
									remove(uiItem);
									return false;
								}
							}
						}
					}
				}
			}
		}

		var emptyCell:CqInventoryCell = getEmptyCell();
		if(emptyCell != null ){
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
		CqInventoryDialog.itemCell_groups.add("equipment", cells);
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
		CqInventoryDialog.itemCell_groups.add("potions", cells);

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
		var icon = SpriteEquipmentIcons.getIcon("destory", 16, 2.0);
		icon.setAlpha(0.3);
		add(icon);
		icon.x += 13;
		icon.y += 3;
			
		var droptext:HxlText = new HxlText(-5, 35, Std.int(width), "Destory");
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
	public var cellEquip:Bool;
	public var cellSpell:Bool;
	public var cellPotion:Bool;
	public var item:CqItem;
	var selected:Bool;
	//var stackText:HxlText;
	//var stackSize:Int;

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
		if (cellEquip)
		{
			var cellRef:CqEquipmentCell = cast(_dlg.dlgEqGrid.cells[cellIndex], CqEquipmentCell);
			cellRef.icon.visible = true;
		}
		//if its moved from an spell cell, make it not clear charge after dragging stops
		if (item.equipSlot == CqEquipSlot.SPELL)
		{
			if (cellSpell)
			{
				clearCharge = false;
			}else
			{
				clearCharge = true;
			}
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

	override function dragStop() {
		// If the user was hovering an eligable drop target, act on it
		if ( CqInventoryCell.highlightedCell != null ) {
			if ( CqInventoryCell.highlightedCell.getCellObj() != null ) {
				// There was already an item in the target cell, switch places with it
				var other:CqInventoryItem = CqInventoryCell.highlightedCell.getCellObj();
				
				if ( cellEquip ) {
					// Unequipping current item (?)
					CqRegistery.player.unequipItem(item);
					// Moving the other item into an equipment cell (?)
					if ( other.setEquipmentCell(cellIndex) && other!=this) 
						CqRegistery.player.equipItem(other.item);
				} else if ( cellSpell ) {
					// Moving the other item into a spell cell
					other.setSpellCell(cellIndex);
					var spellBtn = cast(getSpellCell(cellIndex), CqSpellCell).btn;
					if (other != this)
						GameUI.instance.updateCharge(spellBtn);
					// todo: equip spell
				} else if ( cellPotion ) {
					// Moving the other item into a potion cell
					other.setPotionCell(cellIndex);
				} else {
					// Moving the other item into an inventory cell
					other.setInventoryCell(cellIndex);
				}
				
				if ( Std.is(CqInventoryCell.highlightedCell, CqSpellCell) ) {
					// Moving this item into a spell cell
					setSpellCell(CqInventoryCell.highlightedCell.cellIndex);
					// todo: equip spell
				} else if ( Std.is(CqInventoryCell.highlightedCell, CqPotionCell) ) {
					// Moving this item into a potion cell
					setPotionCell(CqInventoryCell.highlightedCell.cellIndex);
				} else if ( Std.is(CqInventoryCell.highlightedCell, CqEquipmentCell) ) {
					// Moving this item into an equipment cell
					setEquipmentCell(CqInventoryCell.highlightedCell.cellIndex);
					CqRegistery.player.equipItem(this.item);
				} else {
					// Moving this item into an inventory cell
					setInventoryCell(CqInventoryCell.highlightedCell.cellIndex);
				}
				
				cellIndex = CqInventoryCell.highlightedCell.cellIndex;
			} else {
				// The target cell was empty.. clear out my old cell and fill the new one
				if ( cellEquip ) {
					// Clearing out an equipment cell
					_dlg.dlgEqGrid.setCellObj(cellIndex, null);
					CqRegistery.player.unequipItem(this.item);
				} else if ( cellSpell ) {
					// Clearing out a spell cell
					var cellIndexNew = CqInventoryCell.highlightedCell.cellIndex;
					var spellCell = getSpellCell(cellIndex); 
					var spellBtn = spellCell.btn;
					_dlg.dlgSpellGrid.setCellObj(cellIndex, null);
					setSpellCell(CqInventoryCell.highlightedCell.cellIndex);
					GameUI.instance.updateCharge(spellBtn);
				} else if ( cellPotion ) {
					// Clearing out a potion cell
					_dlg.dlgPotionGrid.setCellObj(cellIndex, null);
				} else {
					// Clearing out an inventory cell
					_dlg.dlgInvGrid.setCellObj(cellIndex, null);
					
				}
				if ( Std.is(CqInventoryCell.highlightedCell, CqSpellCell) ) {
					// Moving this item into a spell cell
					setSpellCell(CqInventoryCell.highlightedCell.cellIndex);
					var spellCell = getSpellCell(CqInventoryCell.highlightedCell.cellIndex); 
					var spellBtn = spellCell.btn;
					GameUI.instance.updateCharge(spellBtn);
					if(clearCharge)_dlg.dlgSpellGrid.forceClearCharge(CqInventoryCell.highlightedCell.cellIndex);
					// todo: equip spell
				} else if ( Std.is(CqInventoryCell.highlightedCell, CqPotionCell) ) {
					// Moving this item into a potion cell
					setPotionCell(CqInventoryCell.highlightedCell.cellIndex);
				} else if ( Std.is(CqInventoryCell.highlightedCell, CqEquipmentCell) ) {
					// Moving this item into an equipment cell
					setEquipmentCell(CqInventoryCell.highlightedCell.cellIndex);
					CqRegistery.player.equipItem(this.item);
				} else {
					if ( CqInventoryCell.highlightedCell.dropCell ) {
						// This item is being dropped
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
						setInventoryCell(CqInventoryCell.highlightedCell.cellIndex);
					}
				}
				cellIndex = CqInventoryCell.highlightedCell.cellIndex;
			}
		} else {
			if (cellPotion)
			{
				_dlg.remove(this);
				_dlg.dlgPotionGrid.add(this);
			}
			if ( cellSpell )
			{
				_dlg.remove(this);
				_dlg.dlgSpellGrid.add(this);
			}
			if ( item.consumable || cellPotion ) {
				// If this item is a consumable, and was dropped on the doll, use it
				//TODO: make this more accurate.
				var myX = x + origin.x;
				var myY = y + origin.y;
				var objX = _dlg.dlgCharacter.x+80;
				var objY = _dlg.dlgCharacter.y+40;
				var objW = 80;
				var objH = 200;
				if ( (myX >= objX) || (myX <= objX+objW) || (myY >= objY) || (myY <= objY+objH) ) {
					CqRegistery.player.use(item);
					item.stackSize--;
					if ( item.stackSize <= 0 ) {
						_dlg.remove(this);
						// Clear out the inventory cell this item previously occupied
						_dlg.dlgInvGrid.setCellObj(cellIndex, null);
						destroy();
						CqRegistery.player.removeInventory(this.item);
						_dlg.dlgEqGrid.onItemDragStop();
						_dlg.dlgSpellGrid.onItemDragStop();
						_dlg.dlgPotionGrid.onItemDragStop();
						return;
					} 
				}
			}
			// If there was no eligible drop target, revert to pre drag position
			setPos(dragStartPoint);
		}
		_dlg.dlgEqGrid.onItemDragStop();
		_dlg.dlgSpellGrid.onItemDragStop();
		_dlg.dlgPotionGrid.onItemDragStop();
		super.dragStop();
	}
}
