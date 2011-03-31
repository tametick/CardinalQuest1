package cq;

import cq.CqResources;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxel.HxlDialog;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlObject;
import haxel.HxlPoint;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlSpriteSheet;
import haxel.HxlUtil;

class CqInventoryDialog extends HxlSlidingDialog {

	var dlgCharacter:HxlDialog;
	var dlgInfo:HxlDialog;
	public var dlgGrid:CqInventoryGrid;
	var itemSheet:HxlSpriteSheet;
	var itemSprite:HxlSprite;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);

		dlgCharacter = new HxlDialog(10, 10, 221, 255);
		dlgCharacter.setBackgroundColor(0xff333333);
		add(dlgCharacter);

		dlgInfo = new HxlDialog(241, 10, 221, 255);
		dlgInfo.setBackgroundColor(0xff333333);
		add(dlgInfo);

		dlgGrid = new CqInventoryGrid(10, 275, 452, 195);
		dlgGrid.setBackgroundColor(0xff999999);
		add(dlgGrid);

		itemSheet = new SpriteItems(0);
		var itemSheetKey:String = "ItemIconSheet";
		//HxlGraphics.addBitmap(SpriteItems, false, false, itemSheetKey, 2.0, 2.0);
		itemSprite = new HxlSprite(0, 0);
		itemSprite.loadGraphic(SpriteItems, true, false, CqConfiguration.tileSize, CqConfiguration.tileSize, false, 3.0, 3.0);

		var itemBg:BitmapData = HxlGradient.RectData(50, 50, [0xc1c1c1, 0x9e9e9e], null, Math.PI/2, 8.0);
		var itemBgKey:String = "ItemBG";
		HxlGraphics.addBitmapData(itemBg, itemBgKey);
		CqInventoryItem.backgroundKey = itemBgKey;

		var item1:CqInventoryItem = new CqInventoryItem(this, 2, 2);
		itemSprite.setFrame(itemSheet.getSpriteIndex("winged_sandles"));
		item1.setIcon(itemSprite.getFramePixels());
		item1.toggleDrag(true);
		item1.zIndex = 5;
		item1.setCell(1);
		add(item1);

		var item2:CqInventoryItem = new CqInventoryItem(this, 2, 2);
		itemSprite.setFrame(itemSheet.getSpriteIndex("leather_armor"));
		item2.setIcon(itemSprite.getFramePixels());
		item2.toggleDrag(true);
		item2.zIndex = 5;
		item2.setCell(4);
		add(item2);
	
	}

}

class CqInventoryGrid extends HxlDialog {

	public var cells:Array<CqInventoryCell>;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);

		cells = new Array();

		var cellBg:BitmapData = HxlGradient.RectData(54, 54, [0x333333, 0x555555], null, Math.PI/2, 5.0);
		var cellBgKey:String = "InventoryCellBG";
		HxlGraphics.addBitmapData(cellBg, cellBgKey);

		var cellBgHighlight:BitmapData = HxlGradient.RectData(54, 54, [0x686835, 0xADAB6B], null, Math.PI/2, 5.0);
		var cellBgHighlightKey:String = "CellBGHighlight";
		HxlGraphics.addBitmapData(cellBgHighlight, cellBgHighlightKey);

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

class CqInventoryCell extends HxlDialog {

	public static var highlightedCell:CqInventoryCell = null;
	var cellObj:CqInventoryItem;
	var bgHighlight:HxlSprite;
	var isHighlighted:Bool;
	public var cellIndex:Int;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?CellIndex:Int=0) {
		super(X, Y, Width, Height);
		bgHighlight = null;
		cellObj = null;
		isHighlighted = false;
		cellIndex = CellIndex;
	}

	public function setGraphicKeys(Normal:String, ?Highlight:String=null):Void {
		if ( bgHighlight == null ) {
			bgHighlight = new HxlSprite(0, 0);
			bgHighlight.zIndex = -1;
			add(bgHighlight);
			bgHighlight.visible = false;
		}
		setBackgroundKey(Normal);
		if ( Highlight == null ) Highlight = Normal;
		bgHighlight.loadCachedGraphic(Highlight);
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

	public function setCellObj(CellObj:CqInventoryItem):Void {
		cellObj = CellObj;
	}

	public function getCellObj():CqInventoryItem {
		return cellObj;
	}

}

class CqInventoryItem extends HxlSprite {

	public static var backgroundKey:String;
	var background:BitmapData;
	var icon:BitmapData;
	var _dlg:CqInventoryDialog;
	var idleZIndex:Int;
	var dragZIndex:Int;
	var cellIndex:Int;

	public function new(Dialog:CqInventoryDialog, ?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		loadCachedGraphic(backgroundKey);
		background = HxlGraphics.getBitmap(backgroundKey);
		icon = null;
		idleZIndex = 5;
		dragZIndex = 6;
		_dlg = Dialog;
		cellIndex = 0;
		//pixels = background;
		//width = background.width;
		//height = background.height;
	}

	public function setIcon(Icon:BitmapData):Void {
		icon = Icon;
		var X:Int = Std.int((width / 2) - (icon.width / 2));
		var Y:Int = Std.int((height / 2) - (icon.height / 2));
		var temp:BitmapData = new BitmapData(background.width, background.height, true, 0x0);
		temp.copyPixels(background, new Rectangle(0, 0, background.width, background.height), new Point(0, 0), null, null, true);
		temp.copyPixels(icon, new Rectangle(0, 0, icon.width, icon.height), new Point(X, Y), null, null, true);
		pixels = temp;
	}

	public function setCell(Cell:Int):Void {
		cellIndex = Cell;
		setPos(_dlg.dlgGrid.getCellItemPos(Cell));
		_dlg.dlgGrid.setCellObj(Cell, this);
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
			addEventListener(MouseEvent.MOUSE_DOWN, onDragMouseDown, false, 5);
			addEventListener(MouseEvent.MOUSE_UP, onDragMouseUp, false, 5);
			//trace("mouse down event listener set with priority 5");
		}
	}

	private override function onDragMouseDown(event:MouseEvent):Void {
		super.onDragMouseDown(event);
		//trace("stopping propagation");
		if ( isDragging ) event.stopPropagation();
	}

	private override function onDragMouseUp(event:MouseEvent):Void {
		if ( !exists || !visible || !active || !dragEnabled || HxlGraphics.mouse.dragSprite != this ) return;
		super.onDragMouseUp(event);
		event.stopPropagation();
	}

	override function dragStart():Void {
		zIndex = dragZIndex;
		_dlg.sortMembersByZIndex();
		super.dragStart();
	}

	override function dragStop():Void {
		if ( CqInventoryCell.highlightedCell != null ) {
			if ( CqInventoryCell.highlightedCell.getCellObj() != null ) {
				var other:CqInventoryItem = CqInventoryCell.highlightedCell.getCellObj();
				other.setCell(cellIndex);
				setCell(CqInventoryCell.highlightedCell.cellIndex);
				cellIndex = CqInventoryCell.highlightedCell.cellIndex;
			} else {
				_dlg.dlgGrid.setCellObj(cellIndex, null);
				setCell(CqInventoryCell.highlightedCell.cellIndex);
				cellIndex = CqInventoryCell.highlightedCell.cellIndex;
			}
		} else {
			// If there was no eligible drop target, revert to pre drag position
			setPos(dragStartPoint);
		}
		zIndex = idleZIndex;
		_dlg.sortMembersByZIndex();
		super.dragStop();
	}
}
