package cq;

import cq.GameUI;
import cq.CqInventoryDialog;
import cq.CqItem;
import cq.CqResources;
import cq.CqSpell;
import cq.CqActor;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import data.Registery;

import haxel.HxlButton;
import haxel.HxlDialog;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;
import haxel.HxlLog;
import haxel.HxlSprite;

class CqSpellButton extends HxlDialog {

	var _initialized:Bool;
	public var cell:CqSpellCell;
	var chargeSprite:HxlSprite;

	public function new(X:Int,Y:Int,?Width:Int=100,?Height:Int=20,?Idx:Int=0) {
		super(X, Y, Width, Height);

		initialized = false;

		cell = new CqSpellCell(this,5, 5, 54, 54, Idx);
		cell.setGraphicKeys("EquipmentCellBG", "EqCellBGHighlight", "CellGlow");
		cell.zIndex = 1;
		add(cell);

		chargeSprite = new HxlSprite(x + 5, y + 5);
		chargeSprite.createGraphic(54, 54, 0x00010101);
		chargeSprite.zIndex = 1;
		GameUI.instance.add(chargeSprite);
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

	public function updateChargeSprite(Key:String):Void {
		if ( cell.getCellObj() == null ) {
			chargeSprite.visible = false;
			return;
		}
		chargeSprite.loadCachedGraphic(Key);
		chargeSprite.visible = true;
		chargeSprite.x = x + 5;
		chargeSprite.y = y + 5;	
	}

	public function getSpell():CqSpell {
		if ( cell != null && cell.getCellObj()!= null )
			return cast(cell.getCellObj().item, CqSpell);
		
		return null;
	}
	
	function clickMouseDown(event:MouseEvent):Void {
		if (!exists || !visible || !active || GameUI.currentPanel != null ) return;
		if (overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y)) {
			var spellObj = cell.getCellObj();
			if ( spellObj != null ) {
				var spell = cast(spellObj.item, CqSpell);
				var player = cast(Registery.player, CqPlayer);
				if ( spell.spiritPoints < 360 ) {
					event.stopPropagation();
					return;
				}
				
		
				if ( spell.targetsOther ) {
					GameUI.setTargeting(true, spell.name);
					GameUI.setTargetingSpell(this);
				} else {
					cast(Registery.player,CqPlayer).use(spellObj.item, null);
					spell.spiritPoints = 0;
					GameUI.instance.updateCharge(this);
				}

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
	public var btn:CqSpellButton;
	
	public function new(Btn:CqSpellButton, X:Int,Y:Int,?Width:Int=100,?Height:Int=20, ?Idx:Int=0) {
		super(SPELL, X, Y, Width, Height, Idx);
		btn = Btn;
	}

}
