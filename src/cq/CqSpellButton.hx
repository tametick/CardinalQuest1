package cq;

import cq.GameUI;
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
import haxel.HxlLog;

class CqSpellButton extends HxlDialog {

	var _initialized:Bool;
	public var cell:CqSpellCell;

	public function new(X:Int,Y:Int,?Width:Int=100,?Height:Int=20,?Idx:Int=0) {
		super(X, Y, Width, Height);

		initialized = false;

		cell = new CqSpellCell(5, 5, 54, 54, Idx);
		cell.setGraphicKeys("EquipmentCellBG", "EqCellBGHighlight", "CellGlow");
		cell.zIndex = 1;
		add(cell);
	}

	public override function update():Void {
		if (!_initialized) {
			if (HxlGraphics.stage != null) {
				addEventListener(MouseEvent.MOUSE_DOWN, clickMouseDown, true, 6);
				addEventListener(MouseEvent.MOUSE_UP, clickMouseUp, true, 6);
				_initialized = true;
			}
		}
		
		super.update();
	}

	function clickMouseDown(event:MouseEvent):Void {
		if (!exists || !visible || !active || GameUI.currentPanel != null ) return;
		if (overlapsPoint(HxlGraphics.mouse.x,HxlGraphics.mouse.y)) {
			if ( cell.getCellObj() != null ) {
				HxlLog.append("Activating spell!!");
				event.stopPropagation();
			}
		}
	}

	function clickMouseUp(event:MouseEvent):Void {
		if (!exists || !visible || !active || GameUI.currentPanel != null ) return;
		if (overlapsPoint(HxlGraphics.mouse.x,HxlGraphics.mouse.y)) {
			//if ( _callback != null ) _callback();
			//if ( clickSound != null ) clickSound.play();
			//if ( eventStopPropagate ) event.stopPropagation();
			event.stopPropagation();
		}
	}

}

class CqSpellCell extends CqEquipmentCell {

	public static var highlightedCell:CqInventoryCell = null;

	public function new(X:Int,Y:Int,?Width:Int=100,?Height:Int=20, ?Idx:Int=0) {
		super(SPELL, X, Y, Width, Height, Idx);
	}

}
