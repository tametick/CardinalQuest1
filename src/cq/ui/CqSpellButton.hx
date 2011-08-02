package cq.ui;

import cq.CqRegistery;
import cq.states.GameState;
import cq.ui.inventory.CqEquipmentCell;
import cq.ui.inventory.CqInventoryCell;
import cq.ui.inventory.CqInventoryDialog;
import cq.GameUI;
import cq.CqItem;
import cq.CqResources;
import cq.CqSpell;
import cq.CqActor;
import cq.CqGraphicKey;

import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import data.SoundEffectsManager;

import haxel.HxlButton;
import haxel.HxlDialog;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;
import haxel.HxlLog;
import haxel.HxlSprite;

class CqSpellButton extends HxlDialog {
	public static var clearChargeRect = new Rectangle(0, 0, 94, 94);
	
	var _initialized:Bool;
	public var cell:CqSpellCell;
	var chargeSprite:HxlSprite;
	public var chrageBmpData:BitmapData;

	public function new(X:Int,Y:Int,?Width:Int=100,?Height:Int=20,?Idx:Int=0) {
		super(X, Y, Width, Height);

		initialized = false;

		cell = new CqSpellCell(this,5, 5, 54, 54, Idx);
		cell.setGraphicKeys(CqGraphicKey.EquipmentCellBG,CqGraphicKey.EqCellBGHighlight,CqGraphicKey.CellGlow);
		cell.zIndex = 1;
		add(cell);

		chargeSprite = new HxlSprite(x + 5, y + 5);
		chargeSprite.createGraphic(54, 54, 0x00010101);
		GameUI.instance.doodads.add(chargeSprite);
		
		chrageBmpData = new BitmapData(94, 94, true, 0x0);
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

	public function updateChargeSprite(Key:CqGraphicKey) {
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
	
	function clickMouseDown(event:MouseEvent) {
		if (!exists || !visible || !active || Std.is(GameUI.currentPanel,CqInventoryDialog) ) 
			return;
		if (overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y))
			useSpell(event);
	}
	public function useSpell(?event:MouseEvent = null)
	{
		var spellObj = cell.getCellObj();
		if ( spellObj != null ) {
			var spell = cast(spellObj.item, CqSpell);
			var player = CqRegistery.player;
			if ( spell.spiritPoints < spell.spiritPointsRequired ) {
				if(event!=null)event.stopPropagation();
				return;
			}
			
			if ( spell.targetsOther ) {
				GameUI.setTargeting(true, spell.name);
				GameUI.setTargetingSpell(this);
			} else if (spell.targetsEmptyTile) {
				GameUI.setTargeting(true, spell.name, true);
				GameUI.setTargetingSpell(this);					
			} else {
				GameUI.setTargeting(false);
				GameState.inst.passTurn();
				CqRegistery.player.use(spellObj.item, null);
				spell.spiritPoints = 0;
				GameUI.instance.updateCharge(this);
				SoundEffectsManager.play(SpellCast);
			}
			//event == null means it was called by keypress. which in turn means we want to start targeting from players pos.
			if (event == null) GameUI.setTargetingPos(player.tilePos);
			if (event != null) event.stopPropagation();
		}
	}
	function clickMouseUp(event:MouseEvent) {
		if (!exists || !visible || !active || Std.is(GameUI.currentPanel,CqInventoryDialog) ) 
			return;
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
