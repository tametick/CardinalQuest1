package cq.ui.inventory;

import haxel.HxlDialog;
import haxel.HxlSprite;
import haxel.HxlText;
import haxel.HxlGraphics;

import cq.CqResources;
import cq.CqItem;

// tmp
import cq.ui.inventory.CqInventoryDialog;

class CqEquipmentCell extends CqInventoryCell {

	public static var highlightedCell:CqInventoryCell = null;
	public var equipSlot:CqEquipSlot; // This should be read only
	public var eqCellInit:Bool;
	public var icon:HxlSprite;
	public function new(EquipSlot:CqEquipSlot, ?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?CellIndex:Int=0) {
		super(X, Y, Width, Height, CellIndex);
		equipSlot = EquipSlot;
		eqCellInit = false;
	}

	override function setHighlighted(Toggle:Bool) {
		if ( Toggle && cast(HxlGraphics.mouse.dragSprite, CqInventoryItem).item.equipSlot != equipSlot ) 
			return; 
		super.setHighlighted(Toggle);
	}

	public override function update() {
		super.update();
		if ( !eqCellInit ) {
			eqCellInit = true;
		}
	}
	
	override public function destroy() {
		highlightedCell = null;
		//equipSlot = null;
		icon = null;
		
		super.destroy();
	}

}