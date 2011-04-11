package cq;

import cq.CqInventoryDialog;
import cq.CqItem;
import cq.CqResources;
import cq.CqSpell;

import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxel.HxlButton;
import haxel.HxlDialog;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;

class CqSpellButton extends HxlDialog {

	public var cell:CqSpellCell;

	public function new(X:Int,Y:Int,?Width:Int=100,?Height:Int=20,?Idx:Int=0) {
		super(X, Y, Width, Height);

		cell = new CqSpellCell(5, 5, 54, 54, Idx);
		cell.setGraphicKeys("EquipmentCellBG", "EqCellBGHighlight");
		cell.zIndex = 1;
		add(cell);
	}

}

class CqSpellCell extends CqEquipmentCell {

	public static var highlightedCell:CqInventoryCell = null;

	public function new(X:Int,Y:Int,?Width:Int=100,?Height:Int=20, ?Idx:Int=0) {
		super(SPELL, X, Y, Width, Height, Idx);
	}

}
