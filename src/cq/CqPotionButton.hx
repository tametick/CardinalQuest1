package cq;

import cq.CqActor;
import cq.GameUI;
import cq.CqInventoryDialog;
import cq.CqItem;
import cq.CqResources;
import cq.CqGraphicKey;

import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxel.HxlButton;
import haxel.HxlDialog;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;
import haxel.HxlLog;

class CqPotionButton extends HxlDialog {

	var _initialized:Bool;
	public var cell:CqPotionCell;
	var _dlg:CqPotionGrid;

	public function new(Grid:CqPotionGrid, X:Int,Y:Int,?Width:Int=100,?Height:Int=20,?Idx:Int=0) {
		_dlg = Grid; 
		super(X, Y, Width, Height);

		initialized = false;

		cell = new CqPotionCell(this, 5, 5, 54, 54, Idx);
		cell.setGraphicKeys(CqGraphicKey.EquipmentCellBG,CqGraphicKey.EqCellBGHighlight,CqGraphicKey.CellGlow);
		cell.zIndex = 1;
		cell.cell_type = CqInvCellType.Potion;
		add(cell);
	}

	public override function update() {
		if (!_initialized) {
			if (HxlGraphics.stage != null) {
				addEventListener(MouseEvent.MOUSE_DOWN, clickMouseDown, true, 6,true);
				addEventListener(MouseEvent.MOUSE_UP, clickMouseUp, true, 6,true);
				_initialized = true;
			}
		}
		
		super.update();
	}

	function clickMouseDown(event:MouseEvent) {
		if (!exists || !visible || !active || GameUI.currentPanel != null ) return;
		if (overlapsPoint(HxlGraphics.mouse.x,HxlGraphics.mouse.y)) {
			if ( cell.getCellObj() != null ) {
				var cellObj = cell.getCellObj();
				var item:CqItem = cellObj.item;
				HxlLog.append("Using potion");
				event.stopPropagation();
				CqRegistery.player.use(item);
				item.stackSize--;
				if ( item.stackSize <= 0 ) {
					_dlg.remove(cellObj);
					cell.setCellObj(null);
					cellObj.destroy();
					CqRegistery.player.removeInventory(item);
				} else {
					cell.getCellObj().updateIcon();
				}
			}
		}
	}

	function clickMouseUp(event:MouseEvent) {
		if (!exists || !visible || !active || GameUI.currentPanel != null ) return;
		if (overlapsPoint(HxlGraphics.mouse.x,HxlGraphics.mouse.y)) {
			//if ( _callback != null ) _callback();
			//if ( clickSound != null ) clickSound.play();
			//if ( eventStopPropagate ) event.stopPropagation();
			event.stopPropagation();
		}
	}
}

class CqPotionCell extends CqEquipmentCell {

	public static var highlightedCell:CqInventoryCell = null;
	public var potBtn:CqPotionButton;

	public function new(Btn:CqPotionButton, X:Int,Y:Int,?Width:Int=100,?Height:Int=20, ?Idx:Int=0) {
		super(POTION, X, Y, Width, Height, Idx);
		potBtn = Btn;
	}

}
