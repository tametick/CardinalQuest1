package cq.ui;
import cq.ui.inventory.CqInventoryGrid;
import haxel.HxlPoint;
import haxel.HxlSprite;

import cq.CqSpell;
import cq.CqResources;
import cq.ui.CqSpellButton;

// tmp
import cq.ui.inventory.CqInventoryDialog;

class CqSpellGrid extends CqInventoryGrid {

	public var buttons:Array<CqSpellButton>;	
	var belt:HxlSprite;

	public function forceClearCharge(Cell:Int) {
		if(buttons[Cell].getSpell()!=null)
			buttons[Cell].getSpell().spiritPoints = 0;
		
		GameUI.instance.updateCharge(buttons[Cell],0);
	}
	public function clearCharge(Cell:Int) {
		buttons[Cell].getSpell().spiritPoints = 0;
		GameUI.instance.updateCharge(buttons[Cell]);
	}
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);
		cells = new Array();

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var btnSize:Int = 64;
		var padding:Int = 8;
		var idx:Int = 0;
		buttons = new Array();
		
		belt = new HxlSprite(6, -13);
		belt.zIndex = 0;
		belt.loadGraphic(UiBeltVertical, true, false, 71, 406, false);
		belt.setFrame(0);
		add(belt);
		
		var btnSprite = new ButtonSprite();
		
		for ( i in 0...5 ) {
			var btnCell:CqSpellButton = new CqSpellButton(10, 10 + ((i * btnSize) + (i * 10)), btnSize, btnSize,i);
			
			btnCell.setBackgroundSprite(btnSprite);
			btnCell.zIndex = 1;
			add(btnCell);
			cells.push(btnCell.cell);
			buttons.push(btnCell);
		}
	}

	public override function getCellItemPos(Cell:Int):HxlPoint {
		if ( !initialized ) {
			return new HxlPoint(cells[Cell].x + 12, cells[Cell].y + 12);

		}
		return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);
	}

	public function onItemDrag(Item:CqItem) {
		for( i in 0...cells.length ) {
			var Cell:CqSpellCell = cast(cells[i], CqSpellCell);
			if ( Item.equipSlot == Cell.equipSlot ) {
				Cell.setGlow(true);
			}
		}
	}

	public function onItemDragStop() {
		for ( i in 0...cells.length ) {
			cells[i].setGlow(false);
		}
	}

}