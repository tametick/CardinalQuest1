package cq;

import flash.display.BitmapData;
import haxel.HxlDialog;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlObject;
import haxel.HxlPoint;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlUtil;

class CqInventoryDialog extends HxlSlidingDialog {

	var dlgCharacter:HxlDialog;
	var dlgInfo:HxlDialog;
	var dlgGrid:CqInventoryGrid;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);

		dlgCharacter = new HxlDialog(10, 10, 221, 220);
		dlgCharacter.setBackgroundColor(0xff333333);
		add(dlgCharacter);

		dlgInfo = new HxlDialog(241, 10, 221, 220);
		dlgInfo.setBackgroundColor(0xff333333);
		add(dlgInfo);

		dlgGrid = new CqInventoryGrid(10, 240, 452, 230);
		dlgGrid.setBackgroundColor(0xff999999);
		add(dlgGrid);

		var itemBg:BitmapData = HxlGradient.RectData(49, 49, [0xc1c1c1, 0x9e9e9e], null, Math.PI/2, 8.0);
		var itemBgKey:String = "ItemBG";
		HxlGraphics.addBitmapData(itemBg, itemBgKey);

		var item1:CqInventoryItem = new CqInventoryItem(dlgGrid, 2, 2);
		item1.loadCachedGraphic(itemBgKey);
		item1.toggleDrag(true);
		item1.zIndex = 5;
		var cellpos:HxlPoint = dlgGrid.getCellItemPos(1);
		item1.x = cellpos.x;
		item1.y = cellpos.y;
		add(item1);
	}

}

class CqInventoryGrid extends HxlDialog {

	public var cells:Array<CqInventoryCell>;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);

		cells = new Array();

		var cellBg:BitmapData = HxlGradient.RectData(53, 53, [0x333333, 0x555555], null, Math.PI/2, 5.0);
		var cellBgKey:String = "InventoryCellBG";
		HxlGraphics.addBitmapData(cellBg, cellBgKey);

		var cellBgHighlight:BitmapData = HxlGradient.RectData(53, 53, [0x686835, 0xADAB6B], null, Math.PI/2, 5.0);
		var cellBgHighlightKey:String = "CellBGHighlight";
		HxlGraphics.addBitmapData(cellBgHighlight, cellBgHighlightKey);

		var cell1:CqInventoryCell = new CqInventoryCell(5, 5, 53, 53);
		cell1.setGraphicKeys(cellBgKey, cellBgHighlightKey);
		add(cell1);
		cells.push(cell1);

		var cell2:CqInventoryCell = new CqInventoryCell(63, 5, 53, 53);
		cell2.setGraphicKeys(cellBgKey, cellBgHighlightKey);
		add(cell2);
		cells.push(cell2);

		var cell3:CqInventoryCell = new CqInventoryCell(121, 5, 53, 53);
		cell3.setGraphicKeys(cellBgKey, cellBgHighlightKey);
		add(cell3);
		cells.push(cell3);

		var cell4:CqInventoryCell = new CqInventoryCell(5, 63, 53, 53);
		cell4.setGraphicKeys(cellBgKey, cellBgHighlightKey);
		add(cell4);
		cells.push(cell4);

		var cell5:CqInventoryCell = new CqInventoryCell(63, 63, 53, 53);
		cell5.setGraphicKeys(cellBgKey, cellBgHighlightKey);
		add(cell5);
		cells.push(cell5);

		var cell6:CqInventoryCell = new CqInventoryCell(121, 63, 53, 53);
		cell6.setGraphicKeys(cellBgKey, cellBgHighlightKey);
		add(cell6);
		cells.push(cell6);

	}

	public function getCellItemPos(Cell:Int):HxlPoint {
		if ( !initialized ) {
			return new HxlPoint(x + cells[Cell].x + 2, y + cells[Cell].y + 2);
		}
		return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);

	}

	public function highlightedCellItemPos():HxlPoint {
		var Cell:CqInventoryCell = CqInventoryCell.highlightedCell;
		return new HxlPoint(Cell.x + 2, Cell.y + 2);

	}

}

class CqInventoryCell extends HxlDialog {

	public static var highlightedCell:CqInventoryCell = null;
	var cellObj:HxlObject;
	var bgHighlight:HxlSprite;
	var isHighlighted:Bool;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);
		bgHighlight = null;
		cellObj = null;
		isHighlighted = false;
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

}

class CqInventoryItem extends HxlSprite {

	var _grid:CqInventoryGrid;
	var idleZIndex:Int;
	var dragZIndex:Int;

	public function new(Grid:CqInventoryGrid, ?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		idleZIndex = 5;
		dragZIndex = 6;
		_grid = Grid;
	}

	override function dragStart():Void {
		zIndex = dragZIndex;
		_grid.sortMembersByZIndex();
		super.dragStart();
	}

	override function dragStop():Void {
		if ( CqInventoryCell.highlightedCell != null ) {
			var cellpos:HxlPoint = _grid.highlightedCellItemPos();
			x = cellpos.x;
			y = cellpos.y;
		}
		// If there was no eligible drop target, revert to pre drag position
		zIndex = idleZIndex;
		_grid.sortMembersByZIndex();
		super.dragStop();
	}
}
