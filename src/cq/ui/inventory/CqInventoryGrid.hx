package cq.ui.inventory;

import haxel.HxlDialog;
import haxel.HxlPoint;

import cq.CqResources;

// tmp
import cq.ui.inventory.CqInventoryDialog;

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
	override public function kill():Void
	{
		for ( i in 0...cells.length ) {
			if ( cells[i].getCellObj() != null ) cells[i].getCellObj().destroy();
			cells[i].clearCellObj();
			cells[i].kill();
			remove(cells[i]);
		}
		cells = new Array();
		super.destroy();
		super.kill();
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