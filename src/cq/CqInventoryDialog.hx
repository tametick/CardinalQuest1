package cq;

import flash.display.BitmapData;
import haxel.HxlDialog;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlSlidingDialog;

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

	}

}

class CqInventoryGrid extends HxlDialog {

	var cells:Array<CqInventoryCell>;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);

		cells = new Array();

		var cellBg:BitmapData = HxlGradient.RectData(53, 53, [0x333333, 0x555555], null, Math.PI/2, 5.0);
		var cellBgKey:String = "InventoryCellBG";
		HxlGraphics.addBitmapData(cellBg, cellBgKey);

		var cell1:CqInventoryCell = new CqInventoryCell(5, 5, 53, 53);
		cell1.setBackgroundKey(cellBgKey);
		add(cell1);
		cells.push(cell1);

		var cell2:CqInventoryCell = new CqInventoryCell(63, 5, 53, 53);
		cell2.setBackgroundKey(cellBgKey);
		add(cell2);
		cells.push(cell2);

		var cell3:CqInventoryCell = new CqInventoryCell(121, 5, 53, 53);
		cell3.setBackgroundKey(cellBgKey);
		add(cell3);
		cells.push(cell3);

		var cell4:CqInventoryCell = new CqInventoryCell(5, 63, 53, 53);
		cell4.setBackgroundKey(cellBgKey);
		add(cell4);
		cells.push(cell4);

		var cell5:CqInventoryCell = new CqInventoryCell(63, 63, 53, 53);
		cell5.setBackgroundKey(cellBgKey);
		add(cell5);
		cells.push(cell5);

		var cell6:CqInventoryCell = new CqInventoryCell(121, 63, 53, 53);
		cell6.setBackgroundKey(cellBgKey);
		add(cell6);
		cells.push(cell6);

	}

}

class CqInventoryCell extends HxlDialog {

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);
	}

}
