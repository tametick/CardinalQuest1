package cq;

import cq.CqActor;
import cq.CqItem;
import cq.CqPotionButton;
import cq.CqResources;
import cq.CqSpell;
import cq.CqSpellButton;

import data.Configuration;
import data.Registery;

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

//import flash.filters.GlowFilter;

class CqInventoryDialog extends HxlSlidingDialog {

	public var dlgCharacter:HxlDialog;
	public var dlgInfo:HxlDialog;
	public var dlgInvGrid:CqInventoryGrid;
	public var dlgEqGrid:CqEquipmentGrid;
	public var dlgSpellGrid:CqSpellGrid;
	public var dlgPotionGrid:CqPotionGrid;
	var itemSheet:HxlSpriteSheet;
	var itemSprite:HxlSprite;
	var spellSheet:HxlSpriteSheet;
	var spellSprite:HxlSprite;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);

		dlgCharacter = new HxlDialog(10, 10, 221, 255);
		dlgCharacter.setBackgroundColor(0xff555555);
		add(dlgCharacter);

		dlgEqGrid = new CqEquipmentGrid(0, 0, 221, 255);
		dlgCharacter.add(dlgEqGrid);

		dlgInfo = new HxlDialog(241, 10, 221, 255);
		dlgInfo.setBackgroundColor(0xff555555);
		add(dlgInfo);

		dlgInvGrid = new CqInventoryGrid(10, 275, 452, 195);
		dlgInvGrid.setBackgroundColor(0xff999999);
		add(dlgInvGrid);

		itemSheet = SpriteItems.instance;
		var itemSheetKey:String = "ItemIconSheet";
		itemSprite = new HxlSprite(0, 0);
		itemSprite.loadGraphic(SpriteItems, true, false, Configuration.tileSize, Configuration.tileSize, false, 3.0, 3.0);

		spellSheet = SpriteSpells.instance;
		var spellSheetKey:String = "SpellIconSheet";
		spellSprite = new HxlSprite(0, 0);
		spellSprite.loadGraphic(SpriteSpells, true, false, Configuration.tileSize, Configuration.tileSize, false, 3.0, 3.0);

		CqInventoryItem.backgroundKey = "ItemBG";	
		CqInventoryItem.backgroundSelectedKey = "ItemSelectedBG";
		
		// This snippet applies a glow filter to a BitmapData object.. whee!
		/*
		var tmp:BitmapData = new BitmapData(70, 70, true, 0x0);
		tmp.copyPixels(HxlGraphics.getBitmap("ItemBG"), new Rectangle(0, 0, 50, 50), new Point(10, 10), null, null, true);
		var glow:GlowFilter = new GlowFilter(0x00ff00, 0.8, 15.0, 15.0, 1.25);
		tmp.applyFilter(tmp, new Rectangle(0, 0, 70, 70), new Point(0, 0), glow);
		HxlGraphics.addBitmapData(tmp, "tester!");
		var tmp2:HxlSprite = new HxlSprite(100, 100);
		tmp2.loadCachedGraphic("tester!");
		tmp2.zIndex = 20;
		add(tmp2);
		*/
	}

	public function itemPickup(Item:CqItem):Void {
		for ( cell in dlgInvGrid.cells ) {
			if ( cell.getCellObj() != null && cell.getCellObj().item == Item ) {
				cell.getCellObj().updateIcon();
				return;
			}
		}
		for ( cell in dlgInvGrid.cells ) {
			if ( cell.getCellObj() == null ) {
				var item:CqInventoryItem = new CqInventoryItem(this, 2, 2);
				item.toggleDrag(true);
				item.zIndex = 5;
				item.item = Item;
				if ( Std.is(Item, CqSpell) ) {
					spellSprite.setFrame(spellSheet.getSpriteIndex(Item.spriteIndex));
					item.setIcon(spellSprite.getFramePixels());
				} else {
					itemSprite.setFrame(itemSheet.getSpriteIndex(Item.spriteIndex));
					item.setIcon(itemSprite.getFramePixels());
				}
				add(item);
				item.setInventoryCell(cell.cellIndex);
				break;
			}
		}
	}

	public override function hide(?HideCallback:Dynamic=null):Void {
		super.hide(HideCallback);
		if ( CqInventoryItem.selectedItem != null ) {
			CqInventoryItem.selectedItem.setSelected(false);
			CqInventoryItem.selectedItem = null;
		}
	}

}

class CqInventoryGrid extends HxlDialog {

	public var cells:Array<CqInventoryCell>;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?CreateCells:Bool=true) {
		super(X, Y, Width, Height);
		
		cells = new Array();

		if ( !CreateCells ) return;
		
		var cellBgKey:String = "InventoryCellBG";
		var cellBgHighlightKey:String = "CellBGHighlight";

		var padding:Int = 8;
		var cellSize:Int = 54;
		var offsetX:Int = 5;

		var rows:Int = 3;
		var cols:Int = 7;
		for ( row in 0...rows ) {
			for ( col in 0...cols ) {
				var idx:Int = cells.length;
				var cell:CqInventoryCell = new CqInventoryCell( offsetX + ((col+1) * padding) + (col * cellSize), ((row+1) * padding) + (row * cellSize), cellSize, cellSize, idx);
				cell.setGraphicKeys(cellBgKey, cellBgHighlightKey);
				add(cell);
				cells.push(cell);
			}
		}
		cells[cells.length-1].dropCell = true;
	}

	public function getCellItemPos(Cell:Int):HxlPoint {
		if ( !initialized ) {
			return new HxlPoint(x + cells[Cell].x + 2, y + cells[Cell].y + 2);
		}
		return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);

	}

	public function setCellObj(Cell:Int, CellObj:CqInventoryItem):Void {
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

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);

		cells = new Array();

		var cellBgKey:String = "EquipmentCellBG";
		var cellBgHighlightKey:String = "EqCellBGHighlight";
		var cellGlowKey:String = "CellGlow";

		var cellSize:Int = 54;
		var padding:Int = 8;
		var idx:Int = 0;
		var cell:CqEquipmentCell;
	
		cell = new CqEquipmentCell(SHOES, 8, 193, cellSize, cellSize, idx);
		cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
		add(cell);
		cells.push(cell);
		idx++;

		cell = new CqEquipmentCell(GLOVES, 8, 100, cellSize, cellSize, idx);
		cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
		add(cell);
		cells.push(cell);
		idx++;

		cell = new CqEquipmentCell(ARMOR, 8, 8, cellSize, cellSize, idx);
		cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
		add(cell);
		cells.push(cell);
		idx++;

		cell = new CqEquipmentCell(JEWELRY, 159, 193, cellSize, cellSize, idx);
		cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
		add(cell);
		cells.push(cell);
		idx++;

		cell = new CqEquipmentCell(WEAPON, 159, 100, cellSize, cellSize, idx);
		cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
		add(cell);
		cells.push(cell);
		idx++;

		cell = new CqEquipmentCell(HAT, 159, 8, cellSize, cellSize, idx);
		cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
		add(cell);
		cells.push(cell);
		idx++;
	}

	public function onItemDrag(Item:CqItem):Void {
		for( i in 0...cells.length ) {
			var Cell:CqEquipmentCell = cast(cells[i], CqEquipmentCell);
			if ( Item.equipSlot == Cell.equipSlot ) {
				Cell.setGlow(true);
			}
		}
	}

	public function onItemDragStop():Void {
		for ( i in 0...cells.length ) {
			cells[i].setGlow(false);
		}
	}
}

class CqSpellGrid extends CqInventoryGrid {

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);

		cells = new Array();

		var cellBgKey:String = "EquipmentCellBG";
		var cellBgHighlightKey:String = "EqCellBGHighlight";

		var btnSize:Int = 64;
		var cellSize:Int = 54;
		var padding:Int = 8;
		var idx:Int = 0;
	
		for ( i in 0...5 ) {
			var btnCell:CqSpellButton = new CqSpellButton(10, 10 + ((i * btnSize) + (i * 10)), btnSize, btnSize,i);
			btnCell.setBackgroundColor(0xff999999, 0xffcccccc);
			add(btnCell);
			cells.push(btnCell.cell);
		}
	}

	public function onItemDrag(Item:CqItem):Void {
		for( i in 0...cells.length ) {
			var Cell:CqSpellCell = cast(cells[i], CqSpellCell);
			if ( Item.equipSlot == Cell.equipSlot ) {
				Cell.setGlow(true);
			}
		}
	}

	public function onItemDragStop():Void {
		for ( i in 0...cells.length ) {
			cells[i].setGlow(false);
		}
	}

}

class CqPotionGrid extends CqInventoryGrid {

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);

		cells = new Array();

		var cellBgKey:String = "EquipmentCellBG";
		var cellBgHighlightKey:String = "EqCellBGHighlight";

		var btnSize:Int = 64;
		var cellSize:Int = 54;
		var padding:Int = 8;
		var idx:Int = 0;
	
		for ( i in 0...5 ) {
			var btnCell:CqPotionButton = new CqPotionButton(10 + ((i * btnSize) + (i * 10)), 10, btnSize, btnSize,i);

			btnCell.setBackgroundColor(0xff999999, 0xffcccccc);
			add(btnCell);
			cells.push(btnCell.cell);
		}
	}

	public function onItemDrag(Item:CqItem):Void {
		for( i in 0...cells.length ) {
			var Cell:CqPotionCell = cast(cells[i], CqPotionCell);
			if ( Item.equipSlot == Cell.equipSlot ) {
				Cell.setGlow(true);
			}
		}
	}

	public function onItemDragStop():Void {
		for ( i in 0...cells.length ) {
			cells[i].setGlow(false);
		}
	}

}

class CqInventoryCell extends HxlDialog {

	public static var highlightedCell:CqInventoryCell = null;
	var cellObj:CqInventoryItem;
	var bgHighlight:HxlSprite;
	var bgGlow:HxlSprite;
	var isHighlighted:Bool;
	public var cellIndex:Int;
	public var dropCell:Bool;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?CellIndex:Int=0) {
		super(X, Y, Width, Height);
		bgHighlight = null;
		bgGlow = null;
		cellObj = null;
		isHighlighted = false;
		cellIndex = CellIndex;
		dropCell = false;
	}

	public function setGraphicKeys(Normal:String, ?Highlight:String=null, ?Glow:String=null):Void {
		if ( bgHighlight == null ) {
			bgHighlight = new HxlSprite(0, 0);
			bgHighlight.zIndex = -1;
			add(bgHighlight);
			bgHighlight.visible = false;
		}
		if ( bgGlow == null ) {
			bgGlow = new HxlSprite(-19,-19);
			bgGlow.zIndex = -2;
			add(bgGlow);
			bgGlow.visible = false;
		}
		setBackgroundKey(Normal);
		if ( Highlight == null ) Highlight = Normal;
		bgHighlight.loadCachedGraphic(Highlight);
		if ( Glow == null ) Glow = Normal;
		bgGlow.loadCachedGraphic(Glow);
		origin.x = Std.int(background.width / 2);
		origin.y = Std.int(background.height / 2);
	}

	public override function update():Void {
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

	function setHighlighted(Toggle:Bool):Void {
		isHighlighted = Toggle;
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

	public function setGlow(Toggle:Bool):Void {
		if ( Toggle ) {
			bgGlow.visible = true;
		} else {
			bgGlow.visible = false;
		}
	}

	public function setCellObj(CellObj:CqInventoryItem):Void {
		cellObj = CellObj;
	}

	public function getCellObj():CqInventoryItem {
		return cellObj;
	}

}

class CqEquipmentCell extends CqInventoryCell {

	public static var highlightedCell:CqInventoryCell = null;
	public var equipSlot:CqEquipSlot; // This should be read only

	public function new(EquipSlot:CqEquipSlot, ?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?CellIndex:Int=0) {
		super(X, Y, Width, Height, CellIndex);
		equipSlot = EquipSlot;
	}

	override function setHighlighted(Toggle:Bool):Void {
		if ( Toggle && cast(HxlGraphics.mouse.dragSprite, CqInventoryItem).item.equipSlot != equipSlot ) return; 
		super.setHighlighted(Toggle);
	}

}

class CqInventoryItem extends HxlSprite {

	public static var backgroundKey:String;
	public static var backgroundSelectedKey:String;
	public static var selectedItem:CqInventoryItem = null;
	var background:BitmapData;
	var icon:BitmapData;
	var _dlg:CqInventoryDialog;
	var idleZIndex:Int;
	var dragZIndex:Int;
	var cellIndex:Int;
	public var cellEquip:Bool;
	public var cellSpell:Bool;
	public var item:CqItem;
	var selected:Bool;
	//var stackText:HxlText;
	//var stackSize:Int;

	public function new(Dialog:CqInventoryDialog, ?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		icon = null;
		idleZIndex = 5;
		dragZIndex = 6;
		_dlg = Dialog;
		cellIndex = 0;
		cellEquip = false;
		cellSpell = false;
		item = null;
		zIndex = idleZIndex;
		setSelected(false);
		//stackSize = 1;
	}

	public function setSelected(Toggle:Bool):Void {
		selected = Toggle;
		if ( selected ) {
			loadCachedGraphic(backgroundSelectedKey);
			background = HxlGraphics.getBitmap(backgroundSelectedKey);
			if ( icon != null ) setIcon(icon);
		} else {
			loadCachedGraphic(backgroundKey);
			background = HxlGraphics.getBitmap(backgroundKey);
			if ( icon != null ) setIcon(icon);
		}
	}

	public function updateIcon():Void {
		setIcon(icon);
	}

	public function setIcon(Icon:BitmapData):Void {
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
	public function setInventoryCell(Cell:Int):Void {
		_dlg.dlgSpellGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;
		_dlg.add(this);

		cellIndex = Cell;
		setPos(_dlg.dlgInvGrid.getCellItemPos(Cell));
		_dlg.dlgInvGrid.setCellObj(Cell, this);
		cellEquip = false;
		cellSpell = false;
	}

	/**
	 * Sets this object as the CellObj of the target equipment cell, and places this object within that cell.
	 **/
	public function setEquipmentCell(Cell:Int):Void {
		_dlg.dlgSpellGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;
		_dlg.add(this);

		cellIndex = Cell;
		setPos(_dlg.dlgEqGrid.getCellItemPos(Cell));
		_dlg.dlgEqGrid.setCellObj(Cell, this);
		cellEquip = true;
		cellSpell = false;
	}

	/**
	 * Sets this object as the CellObj of the target spell cell, and places this object within that cell.
	 **/
	public function setSpellCell(Cell:Int):Void {
		_dlg.dlgSpellGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;
		_dlg.dlgSpellGrid.add(this);

		cellIndex = Cell;
		setPos(_dlg.dlgSpellGrid.getCellItemPos(Cell));
		_dlg.dlgSpellGrid.setCellObj(Cell, this);
		cellSpell = true;
		cellEquip = false;
	}

	public function setPos(Pos:HxlPoint):Void {
		x = Pos.x;
		y = Pos.y;
	}

	public override function toggleDrag(Toggle:Bool):Void {
		super.toggleDrag(Toggle);
		if ( dragEnabled ) {
			removeEventListener(MouseEvent.MOUSE_DOWN, onDragMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, onDragMouseUp);
			addEventListener(MouseEvent.MOUSE_DOWN, onDragMouseDown, true, 5);
			addEventListener(MouseEvent.MOUSE_UP, onDragMouseUp, true, 5);
		}
	}

	private override function onDragMouseDown(event:MouseEvent):Void {
		if ( GameUI.currentPanel == null ) return;
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

	private override function onDragMouseUp(event:MouseEvent):Void {
		if ( !exists || !visible || !active || !dragEnabled || GameUI.currentPanel == null || HxlGraphics.mouse.dragSprite != this ) return;
		super.onDragMouseUp(event);
		if ( !isDragging ) {
			event.stopPropagation();
		}
	}

	override function dragStart():Void {
		_dlg.remove(this);
		_dlg.dlgSpellGrid.remove(this);
		zIndex = dragZIndex;
		_dlg.add(this);
		_dlg.dlgEqGrid.onItemDrag(this.item);
		_dlg.dlgSpellGrid.onItemDrag(this.item);
		super.dragStart();
	}

	override function dragStop():Void {
		// If the user was hovering an eligable drop target, act on it
		if ( CqInventoryCell.highlightedCell != null ) {
			if ( CqInventoryCell.highlightedCell.getCellObj() != null ) {
				// There was already an item in the target cell, switch places with it
				var other:CqInventoryItem = CqInventoryCell.highlightedCell.getCellObj();
				if ( cellEquip ) {
					// Moving the other item into an equipment cell
					cast(Registery.player, CqActor).unequipItem(this.item);
					other.setEquipmentCell(cellIndex);
					cast(Registery.player, CqActor).equipItem(other.item);
				} else if ( cellSpell ) {
					// Moving the other item into a spell cell
					other.setSpellCell(cellIndex);
					// todo: equip spell
				} else {
					// Moving the other item into an inventory cell
					other.setInventoryCell(cellIndex);
				}
				if ( Std.is(CqInventoryCell.highlightedCell, CqSpellCell) ) {
					// Moving this item into a spell cell
					setSpellCell(CqInventoryCell.highlightedCell.cellIndex);
					// todo: equip spell
				} else if ( Std.is(CqInventoryCell.highlightedCell, CqEquipmentCell) ) {
					// Moving this item into an equipment cell
					setEquipmentCell(CqInventoryCell.highlightedCell.cellIndex);
					cast(Registery.player, CqActor).equipItem(this.item);
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
					cast(Registery.player, CqActor).unequipItem(this.item);
				} else if ( cellSpell ) {
					// Clearing out a spell cell
					_dlg.dlgSpellGrid.setCellObj(cellIndex, null);
				} else {
					// Clearing out an inventory cell
					_dlg.dlgInvGrid.setCellObj(cellIndex, null);
				}
				if ( Std.is(CqInventoryCell.highlightedCell, CqSpellCell) ) {
					// Moving this item into a spell cell
					setSpellCell(CqInventoryCell.highlightedCell.cellIndex);
					// todo: equip spell
				} else if ( Std.is(CqInventoryCell.highlightedCell, CqEquipmentCell) ) {
					// Moving this item into an equipment cell
					setEquipmentCell(CqInventoryCell.highlightedCell.cellIndex);
					cast(Registery.player, CqActor).equipItem(this.item);
				} else {
					// Moving this item into an inventory cell
					if ( CqInventoryCell.highlightedCell.dropCell ) {
						// This item is being dropped
						_dlg.remove(this);
						this.item.setTilePos(Registery.player.getTilePos());
						this.item.visible = true;
						this.item.alpha = 1.0;
						Registery.world.currentLevel.addLootToLevel(HxlGraphics.state, this.item);
						destroy();
						cast(Registery.player, CqPlayer).removeInventory(this.item);
						return;
					} else {
						setInventoryCell(CqInventoryCell.highlightedCell.cellIndex);
					}
				}
				cellIndex = CqInventoryCell.highlightedCell.cellIndex;
			}
		} else {
			if ( item.consumable ) {
				// If this item is a consumable, and was dropped on the doll, use it
				var myX = x + origin.x;
				var myY = y + origin.y;
				var objX = _dlg.dlgCharacter.x;
				var objY = _dlg.dlgCharacter.y;
				var objW = _dlg.dlgCharacter.width;
				var objH = _dlg.dlgCharacter.height;
				if ( (myX >= objX) || (myX <= objX+objW) || (myY >= objY) || (myY <= objY+objH) ) {
					cast(Registery.player, CqActor).use(item);
					item.stackSize--;
					if ( item.stackSize <= 0 ) {
						_dlg.remove(this);
						// Clear out the inventory cell this item previously occupied
						_dlg.dlgInvGrid.setCellObj(cellIndex, null);
						destroy();
						cast(Registery.player, CqPlayer).removeInventory(this.item);
						return;
					} else {
						updateIcon();
					}
				}
			}
			// If there was no eligible drop target, revert to pre drag position
			setPos(dragStartPoint);
		}
		_dlg.dlgEqGrid.onItemDragStop();
		_dlg.dlgSpellGrid.onItemDragStop();

		super.dragStop();
	}
}
