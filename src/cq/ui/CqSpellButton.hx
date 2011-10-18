package cq.ui;

import data.Registery;
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
import flash.display.Shape;
import flash.geom.ColorTransform;
import haxel.HxlState;
import haxel.HxlUtil;

import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import data.SoundEffectsManager;
import data.Configuration;

import haxel.HxlButton;
import haxel.HxlDialog;
import haxel.HxlGraphics;
import haxel.HxlObjectContainer;
import haxel.HxlLog;
import haxel.HxlSprite;

class CqSpellButtonBMPData extends BitmapData {}
class CqSpellButton extends HxlDialog {
	public static var clearChargeRect = new Rectangle(0, 0, 94, 94);

	var _initialized:Bool;
	public var cell:CqSpellCell;
	var chargeSprite:HxlSprite;
	var chargeBmpData:CqSpellButtonBMPData;

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

		chargeBmpData = new CqSpellButtonBMPData(94, 94, true, 0x0);
	}

	override public function destroy() {
		super.destroy();

		if(chargeBmpData!=null)
			chargeBmpData.dispose();
		chargeBmpData = null;

		if(cell!=null)
			cell.destroy();
		cell = null;

		if(chargeSprite!=null)
			chargeSprite.destroy();
		chargeSprite = null;

		ctrans = null;
	}

	//function addEventListener(Type:String, Listener:Dynamic, UseCapture:Bool=false, Priority:Int=0, UseWeakReference:Bool=true) {
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

	static var ctrans:ColorTransform;
	public function updateChargeSprite(chargeShape:Shape) {
		chargeBmpData.fillRect(clearChargeRect, 0x0);
		chargeBmpData.draw(chargeShape, null, ctrans);

		if (ctrans == null) {
			ctrans = new ColorTransform();
			ctrans.alphaMultiplier = 0.5;
		}

		if ( cell.getCellObj() == null ) {
			chargeSprite.visible = false;
			return;
		}

		chargeSprite.loadSuppliedGraphic(chargeBmpData);
		chargeSprite.visible = true;
		chargeSprite.x = x + 5;
		chargeSprite.y = y + 5;
	}
	public function getSpell():CqSpell {
		if ( cell != null && cell.getCellObj()!= null )
			return cast(cell.getCellObj().item, CqSpell);

		return null;
	}

	override public function overlapsPoint(X:Float,Y:Float,?PerPixel:Bool = false):Bool {

		//This is totally messed up, but it works..
		//I suspect this is for the same reason that I cannot trust
		//HxlGraphics.mouse.x/y to have the right value
		if( !Configuration.mobile ) {
			X += HxlUtil.floor(HxlGraphics.scroll.x);
			Y += HxlUtil.floor(HxlGraphics.scroll.y);
		}

		/*
		var tapMessage = "Comparing ";
		tapMessage = tapMessage + "(" + Std.string( Std.int( X ) ) +"," + Std.string( Std.int( Y ) ) + ") ";
		tapMessage = tapMessage + "(" + Std.string( Std.int( _point.x  ) ) +"," + Std.string( Std.int( _point.y ) ) + ") ";
		tapMessage = tapMessage + "(" + Std.string( Std.int( _point.x+width ) ) +"," + Std.string( Std.int( _point.y+height ) ) + ") ";
		GameUI.showTextNotification( tapMessage );
		*/

		getScreenXY(_point);
		if ((X <= _point.x) || (X >= _point.x+width) || (Y <= _point.y) || (Y >= _point.y+height)) {
			return false;
		}
		return true;
	}

	function clickMouseDown(event:MouseEvent) {
		if (!exists || !visible || !active || Std.is(GameUI.instance.panels.currentPanel, CqInventoryDialog) ) {
			if (!exists)
				clearEventListeners();
			return;
		}

		if( Configuration.mobile ) {
			HxlGraphics.mouse.x = Std.int(event.localX);
			HxlGraphics.mouse.y = Std.int(event.localY);
		}

		if (overlapsPoint(HxlGraphics.mouse.x, HxlGraphics.mouse.y))
			useSpell(event);
	}

	function clickMouseUp(event:MouseEvent) {
		if (!exists || !visible || !active || Std.is(GameUI.instance.panels.currentPanel, CqInventoryDialog) ) {
			if (!exists)
				clearEventListeners();
			return;
		}
		if (overlapsPoint(HxlGraphics.mouse.x,HxlGraphics.mouse.y)) {
			//if ( _callback != null ) _callback();
			//if ( clickSound != null ) clickSound.play();
			//if ( eventStopPropagate ) event.stopPropagation();
			event.stopPropagation();
		}
	}

	public function useSpell(?event:MouseEvent = null)
	{
		var spellObj = cell.getCellObj();
		if ( spellObj != null ) {
			var spell = cast(spellObj.item, CqSpell);
			var player = Registery.player;
			if ( spell.statPoints < spell.statPointsRequired ) {
				if (event != null)
					event.stopPropagation();
				return;
			}

			if ( spell.targetsOther ) {
				GameUI.setTargeting(true, spell.name);
				GameUI.setTargetingSpell(this);
			} else if (spell.targetsEmptyTile) {
				GameUI.setTargeting(true, spell.name, true);
				GameUI.setTargetingSpell(this);
			} else {
				if (!Std.is(HxlGraphics.state, GameState))
					return;

				GameUI.setTargeting(false);
				Registery.player.use(spellObj.item, null);
				cast(HxlGraphics.state, GameState).passTurn();
				spell.statPoints = 0;
				GameUI.instance.updateCharge(this);
				SoundEffectsManager.play(SpellCast);
			}
			//event == null means it was called by keypress. which in turn means we want to start targeting from players pos.
			if (event == null) GameUI.setTargetingPos(player.tilePos);
			if (event != null) event.stopPropagation();
		}
	}

}

class CqSpellCell extends CqEquipmentCell {
	public static var highlightedCell:CqInventoryCell = null;
	// pointer to the parent
	public var btn:CqSpellButton;

	public function new(Btn:CqSpellButton, X:Int,Y:Int,?Width:Int=100,?Height:Int=20, ?Idx:Int=0) {
		super(SPELL, X, Y, Width, Height, Idx);
		btn = Btn;
	}

	override public function destroy()	{
		highlightedCell = null;
		btn = null;

		super.destroy();
	}

}
