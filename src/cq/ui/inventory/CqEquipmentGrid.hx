package cq.ui.inventory;

import haxel.HxlPoint;

import cq.CqResources;
import cq.CqItem;

import cq.ui.inventory.CqInventoryCell;

// tmp
import cq.ui.inventory.CqInventoryDialog;

class CqEquipmentGrid extends CqInventoryGrid {

	private var eqGridInit:Bool;

	static var icons_names:Array<String> = [ "shoes", "gloves", "armor", "jewelry", "weapon", "hat" ];
	static var cell_positions:Array<Array<Int>> = [ [8, 183], [8, 100], [8, 12], [159, 183], [159, 100], [159, 12] ];
	static var icons_slots:Array<CqEquipSlot> = [SHOES, GLOVES, ARMOR, JEWELRY, WEAPON, HAT];
		
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height, false);

		cells = new Array();
		eqGridInit = false;

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
			cell.cell_type = CqInvCellType.Equipment;
			var icon = SpriteEquipmentIcons.getIcon(icons_names[idx], icons_size, 2.0);
			cell.add(icon);
			cell.icon = icon;
			icon.x = icons_x-5;
			icon.y = icons_y-5;
			icon.setAlpha(0.3);
			add(cell);
			cells.push(cell);
		}
	}

	public override function getCellItemPos(Cell:Int):HxlPoint {
		if ( !initialized ) {
			return new HxlPoint(x + cells[Cell].x + 2, y + cells[Cell].y + 2);
		}
		return new HxlPoint(cells[Cell].x + 2, cells[Cell].y + 2);
	}

	public function onItemDrag(Item:CqItem) {
		for( i in 0...cells.length ) {
			var Cell:CqEquipmentCell = cast(cells[i], CqEquipmentCell);
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

	public override function update() {
		super.update();
		if ( !eqGridInit ) {
			eqGridInit = true;
		}
	}
}