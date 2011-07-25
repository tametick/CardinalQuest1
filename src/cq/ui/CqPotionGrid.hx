package cq.ui;
import cq.ui.inventory.CqInventoryGrid;
import haxel.HxlPoint;
import haxel.HxlSprite;

import cq.CqItem;
import cq.CqResources;
import cq.ui.CqPotionButton;

// tmp
import cq.ui.inventory.CqInventoryDialog;

class CqPotionGrid extends CqInventoryGrid {
	var belt:HxlSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);
		
		belt = new HxlSprite(-40, 8);
		belt.zIndex = -1;
		belt.loadGraphic(UiBeltHorizontal, false, false, 460, 71);
		add(belt);
		
		cells = new Array();

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var btnSize:Int = 64;
		var padding:Int = 8;
		var idx:Int = 0;
			
		var btnSprite = new ButtonSprite();
		
		for ( i in 0...5 ) {
			var btnCell:CqPotionButton = new CqPotionButton(this, 10 + ((i * btnSize) + (i * 10)), 10, btnSize, btnSize,i);
			btnCell.setBackgroundSprite(btnSprite);
			add(btnCell);
			cells.push(btnCell.cell);
		}

	}
	public function onItemDrag(Item:CqItem) {
		for( i in 0...cells.length ) {
			var Cell:CqPotionCell = cast(cells[i], CqPotionCell);
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

	public override function getCellItemPos(Cell:Int):HxlPoint {
		if ( !initialized ) {
			return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);
		}
		return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);
	}
}