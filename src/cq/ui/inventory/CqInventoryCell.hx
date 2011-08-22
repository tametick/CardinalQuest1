package cq.ui.inventory;

import haxel.HxlDialog;
import haxel.HxlSprite;
import haxel.HxlText;
import haxel.HxlGraphics;

import cq.CqResources;

import data.Registery;

// tmp
import cq.ui.inventory.CqInventoryDialog;

enum CqInvCellType {
	Equipment;
	Spell;
	Potion;
}

class CqInventoryCell extends HxlDialog {

	public static var highlightedCell:CqInventoryCell = null;
	var cellObj:CqInventoryItem;
	var bgHighlight:HxlSprite;
	var bgGlow:HxlSprite;
	var isHighlighted:Bool;
	public var cellIndex:Int;
	public var dropCell:Bool;
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?CellIndex:Int=0) {
		super(X, Y, Width, Height);
		bgHighlight = null;
		bgGlow = null;
		cellObj = null;
		isHighlighted = false;
		cellIndex = CellIndex;
		dropCell = false;
	}

	public function setGraphicKeys(Normal:CqGraphicKey, ?Highlight:CqGraphicKey = null, ?Glow:CqGraphicKey = null) {
		if ( bgHighlight == null ) {
			bgHighlight = new HxlSprite(0, 0);
			bgHighlight.zIndex = 1;
			add(bgHighlight);
			bgHighlight.visible = false;
		}
		
		if ( bgGlow == null ) {
			bgGlow = new HxlSprite(-19,-19);
			bgGlow.zIndex = -3;
			add(bgGlow);
			bgGlow.visible = false;
		}
		
		setBackgroundKey(Normal);
		
		if ( Highlight == null ) 
			Highlight = Normal;
			
		bgHighlight.loadCachedGraphic(Highlight);
		
		if ( Glow == null ) 
			Glow = Normal;
			
		bgGlow.loadCachedGraphic(Glow);
		origin.x = Std.int(background.width / 2);
		origin.y = Std.int(background.height / 2);
		
		if ( dropCell )
			initDropCell();
	}
	
	function initDropCell()	{
		var icon = SpriteEquipmentIcons.getIcon("destroy", 16, 2.0);
		icon.setAlpha(0.3);
		add(icon);
		icon.x += 13;
		icon.y += 3;
			
		var droptext:HxlText = new HxlText(-5, 35, Std.int(width), "Destroy");
		droptext.setFormat(FontAnonymousPro.instance.fontName, 12, 0xffffff, "center", 0x010101);
		droptext.zIndex = 10;
		droptext.setAlpha(0.3);
		add(droptext);
	}
	
	public override function update() {
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

	function setHighlighted(Toggle:Bool) {
		isHighlighted = Toggle;
		//setGlow(Toggle);
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

	public function setGlow(Toggle:Bool) {
		bgGlow.visible = Toggle;
	}

	public function setCellObj(CellObj:CqInventoryItem) {
		cellObj = CellObj;
	}

	public function getCellObj():CqInventoryItem {
		return cellObj;
	}
	public function clearCellObj():CqInventoryItem {
		var oldItem:CqInventoryItem = null;
		if (cellObj != null) {
			oldItem = cellObj;
			Registery.player.unequipItem(cellObj.item);
			cellObj.removeFromDialog();
			cellObj = null;
		}
		return oldItem;
	}
}