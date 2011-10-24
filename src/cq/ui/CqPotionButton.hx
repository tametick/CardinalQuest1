package cq.ui;

import data.Registery;
import data.Resources;

import cq.states.GameState;
import cq.ui.inventory.CqEquipmentCell;
import cq.ui.inventory.CqInventoryCell;
import cq.ui.inventory.CqInventoryDialog;
import cq.CqActor;
import cq.GameUI;
import cq.CqItem;
import cq.CqResources;
import cq.CqGraphicKey;

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxel.HxlButton;
import haxel.HxlDialog;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;
import haxel.HxlLog;
import haxel.HxlUtil;

import data.Configuration;

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

	override public function overlapsPoint(X:Float,Y:Float,?PerPixel:Bool = false):Bool {

		//This is totally messed up, but it works..
		//I suspect this is for the same reason that I cannot trust
		//HxlGraphics.mouse.x/y to have the right value
		if( !Configuration.mobile ) {
			X += HxlUtil.floor(HxlGraphics.scroll.x);
			Y += HxlUtil.floor(HxlGraphics.scroll.y);
		}

		getScreenXY(_point);
		if ((X <= _point.x) || (X >= _point.x+width) || (Y <= _point.y) || (Y >= _point.y+height)) {
			return false;
		}
		return true;
	}

	function clickMouseDown(event:MouseEvent) {
		if (!exists || !visible || !active || Std.is(GameUI.instance.panels.currentPanel,CqInventoryDialog) || !Std.is(HxlGraphics.state,GameState) )
			return;

		if( Configuration.mobile ) {

			HxlGraphics.mouse.x = Std.int(event.localX);
			HxlGraphics.mouse.y = Std.int(event.localY);
		}

		if (overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) {
			event.stopPropagation();
			usePotion();
		}
	}
	public function usePotion()
	{
		if ( cell.getCellObj() != null ) {
			var cellObj = cell.getCellObj();
			var item:CqItem = cellObj.item;
			HxlLog.append(Resources.getString( "LOG_POTION" ));
			Registery.player.use(item);
			item.stackSize--;
			if ( item.stackSize <= 0 ) {
				_dlg.remove(cellObj);
				cell.setCellObj(null);
				cellObj.destroy();
				Registery.player.removeInventory(item);
			} else {
				cell.getCellObj().updateIcon();
			}
		}
	}

	function clickMouseUp(event:MouseEvent) {
		if (!exists || !visible || !active || Std.is(GameUI.instance.panels.currentPanel,CqInventoryDialog) )
			return;
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
