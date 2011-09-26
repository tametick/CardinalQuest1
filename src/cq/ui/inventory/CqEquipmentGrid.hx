package cq.ui.inventory;

import cq.states.GameState;
import haxel.HxlGraphics;
import haxel.HxlPoint;

import cq.CqResources;
import cq.CqItem;


// tmp
import cq.ui.inventory.CqInventoryDialog;

class CqEquipmentGrid extends CqInventoryGrid {

	static var icons_names:Array<String> = [ "shoes", "gloves", "armor", "jewelry", "weapon", "hat" ];
	static var cell_positions:Array<Array<Int>> = [ [8, 183], [8, 100], [8, 12], [159, 183], [159, 100], [159, 12] ];
	static var icons_slots:Array<CqEquipSlot> = [SHOES, GLOVES, ARMOR, JEWELRY, WEAPON, HAT];
		
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);

		cells = new Array();

		var cellBgKey:CqGraphicKey = CqGraphicKey.EquipmentCellBG;
		var cellBgHighlightKey:CqGraphicKey = CqGraphicKey.EqCellBGHighlight;
		var cellGlowKey:CqGraphicKey = CqGraphicKey.CellGlow;

		var cellSize:Int = 54;
		var padding:Int = 8;
		var idx:Int = 0;
		var cell:CqEquipmentCell;
	
		var icons_size:Int = 16;
		var icons_x:Int = Std.int( (cellSize / 2)- (icons_size / 2) ) - 3; // -3 offset, to make it look better
		var icons_y:Int = icons_x;
		
		var btn:ButtonSprite;
		for (idx in 0...icons_names.length)	{
			cell = new CqEquipmentCell(icons_slots[idx], cell_positions[idx][0]-5, cell_positions[idx][1]-5, cellSize, cellSize, idx);
			btn = new ButtonSprite();
			cell.add(btn);
			btn.x = btn.y = -5;
			cell.setGraphicKeys(cellBgKey, cellBgHighlightKey, cellGlowKey);
			var icon = SpriteEquipmentIcons.getIcon(icons_names[idx], icons_size, 2.0);
			cell.add(icon);
			cell.icon = icon;
			icon.x = icons_x-5;
			icon.y = icons_y-5;
			icon.setAlpha(0.3);
			add(cell);
			cells.push(cell);
			
			icon = null;
			btn = null;
			cell = null;
		}
	}
	
	public function setGlowForSlot(slot:CqEquipSlot,value:Bool) {
		var Cell:CqEquipmentCell = null;
		for( i in 0...cells.length ) {
			Cell  = cast(cells[i], CqEquipmentCell);
			if ( slot == Cell.equipSlot ) {
				Cell.setGlow(value);
			}
			Cell = null;
		}
	}
	
	public function getCellWithSlot(slot:CqEquipSlot):CqEquipmentCell {
		var Cell:CqEquipmentCell = null;
		for( i in 0...cells.length ) {
			Cell = cast(cells[i], CqEquipmentCell);
			if ( slot == Cell.equipSlot ) {
				return Cell;
			}
			Cell = null;
		}
		return null;
	}
}