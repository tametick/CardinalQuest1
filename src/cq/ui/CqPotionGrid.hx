package cq.ui;
import cq.ui.inventory.CqInventoryGrid;
import haxel.HxlButton;
import haxel.HxlPoint;
import haxel.HxlSprite;
import haxel.HxlText;

import cq.CqItem;
import cq.CqResources;
import cq.ui.CqPotionButton;


class CqPotionGrid extends CqInventoryGrid {
	var belt:HxlSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);
		
		belt = new HxlSprite(-12, 8);
		belt.zIndex = -1;
		belt.loadGraphic(UiBeltHorizontal, false, false, 460, 71);
		add(belt);
		
		cells = new Array();

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;

		var offsetX:Int = 28;
		var btnSize:Int = 64;
		var padding:Int = 8;
		var idx:Int = 0;
			
		var btnSprite = new ButtonSprite();
		
		for ( i in 0...5 ) {
			var btnCell:CqPotionButton = new CqPotionButton(this, offsetX+10 + ((i * btnSize) + (i * 10)), 10, btnSize, btnSize,i);
			btnCell.setBackgroundSprite(btnSprite);
			add(btnCell);
			cells.push(btnCell.cell);
		}

	}
}