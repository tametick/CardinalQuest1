package cq.ui.inventory;
import cq.CqGraphicKey;
import cq.CqItem;
import cq.CqRegistery;
import cq.CqResources;
import cq.GameUI;
import cq.ui.CqItemInfoDialog;
import cq.ui.CqPotionGrid;
import cq.ui.CqSpellGrid;
import data.Configuration;
import data.SoundEffectsManager;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlSpriteSheet;

class CqInventoryItemManager 
{
	private var mainDialog:CqInventoryDialog;
	private var dlgPotionGrid:CqPotionGrid;
	private var dlgInvGrid:CqInventoryGrid;
	private var dlgInfo:CqItemInfoDialog;
	private var dlgEqGrid:CqEquipmentGrid;
	
	private var dlgSpellGrid:CqSpellGrid;
	
	//keyboard check
	var lcellId:Int;
	var cellId:Int;
	var usingKeys:Bool;
	var currentGrid:Int;
	var gridOrder:Array<CqInventoryGrid>;
	var gridOrientation:Array<Int>;
	var markedGrid:Int;
	var markedCellId:Int;
	var isMarkedCell:Bool;
	var barrierMode:Bool;//if true - doesnt allow moving below cell array bounds
	var simpleMovement:Bool;
	var instaEquip:Bool;
	
	public function new(inventoryDialog:CqInventoryDialog) 
	{
		mainDialog = inventoryDialog;
		dlgPotionGrid = mainDialog.dlgPotionGrid;
		dlgInvGrid = mainDialog.dlgInvGrid;
		dlgInfo = mainDialog.dlgInfo;
		dlgEqGrid = mainDialog.dlgEqGrid;
		dlgSpellGrid = mainDialog.dlgSpellGrid;
		gridOrder = [dlgInvGrid, dlgPotionGrid, dlgSpellGrid, dlgEqGrid];
		gridOrientation = [2, 0, 1, 3];
		barrierMode = true;
		simpleMovement = false;
		instaEquip = true;
	}
	/**
	 * True - added to inventory or equipped
	 * False - destroyed or added to potion/spell belts
	 * */
	public function itemPickup(Item:CqItem):Bool {
		// if an equivalent item already in inventory, destory picked up item
		for ( cell in dlgInvGrid.cells ) {
			if ( cell.getCellObj() != null && cell.getCellObj().item.equalTo(Item) && Item.equipSlot != SPELL) {
				GameUI.showTextNotification("I already have this.");
				CqRegistery.player.giveMoney( Item.getMonetaryValue() );
				return false;
			}
		}
		
		// stacking was already done by CqActor.give(...), just updating potion icon
		if ( Item.equipSlot == POTION ) {
			for ( cell in dlgPotionGrid.cells ) {
				if ( cell.getCellObj() != null && cell.getCellObj().item == Item ) {
					cell.getCellObj().updateIcon();
					return false;
				}
			}
		}		
		
		//create ui item
		var uiItem:CqInventoryItem = CqInventoryItem.createUIItem(Item,mainDialog);		
		
		if ( Item.equipSlot != null ) {
			if ( Item.equipSlot == POTION ) {
				dlgInfo.setItem(Item);
				for ( cell in dlgPotionGrid.cells ) {
					if ( cell.getCellObj() == null ) {
						uiItem.setPotionCell(cell.cellIndex);
						uiItem.popup.setText(Item.fullName+"\n[hotkey " + ((cell.cellIndex>3)?cell.cellIndex-4:cell.cellIndex + 6) + "]");
						return false;
					}
				}
			} else if ( Item.equipSlot == SPELL ) {
				dlgInfo.setItem(Item);
				for ( cell in dlgSpellGrid.cells ) {
					if ( cell.getCellObj() == null ) {
						uiItem.setSpellCell(cell.cellIndex);
						uiItem.popup.setText(Item.fullName+"\n[hotkey " + (cell.cellIndex + 1) + "]");
						cell.getCellObj().updateIcon();
						SoundEffectsManager.play(SpellEquipped);
						return false;
					}
				}
			} else {
				//item in equipment
				for ( cell in dlgEqGrid.cells ) {
					//found same quipment cell slot as item
					if (cast(cell, CqEquipmentCell).equipSlot == Item.equipSlot) {
						//if slot was empty - equip
						if (cell.getCellObj() == null) {
							uiItem = equipItem(cell, Item, uiItem);
							cell.getCellObj().updateIcon();
							dlgInfo.setItem(Item);
							return true;
						} else {
							
							var preference:Float = shouldEquipItemInCell(cast(cell, CqEquipmentCell), Item);
							//equip if item is better
							if (preference > 1)	{	
								var old:CqInventoryItem = equipItem(cell, Item, uiItem);
								dlgInfo.setItem(Item);
								if (!old.item.isEnchanted) {	
									// old is plain, so destroy
									GameUI.showTextNotification("I can drop the old one now.", 0xBFE137);
									CqRegistery.player.giveMoney( old.item.getMonetaryValue() );
									mainDialog.remove(old);
									old.destroy();

									return true;
								} else {
									// old is non plain add to inv
									uiItem = old;
								}
							} else if (preference < 1) {
								//if new is worse than old, and is plain - destroy it
								if (!Item.isEnchanted) {
									GameUI.showTextNotification("I don't need this.");
									CqRegistery.player.giveMoney( Item.getMonetaryValue() );
									mainDialog.remove(uiItem);
									uiItem.destroy();
									
									return false;
								}
							} else {	
								//item is the same & plain
								if ( Item.equalTo( cell.getCellObj().item) && !Item.isEnchanted) {
									CqRegistery.player.giveMoney( Item.getMonetaryValue() );
									GameUI.showTextNotification("I already have this.",0xE1CC37);
									mainDialog.remove(uiItem);
									uiItem.destroy();
									return false;
								}
							}
						}
					}
				}
			}
		}
		
		var emptyCell:CqInventoryCell = getEmptyCell();
		if (emptyCell != null ) {
			// add to inventory
			uiItem.setInventoryCell(emptyCell.cellIndex);
			uiItem.popup.setText(Item.fullName);
			return true;
		} else {
			throw "no room in inventory, should not happen because pick up should have not been allowed!";
		}
	}
	/**
	 * <1 yes 1 == equal, >1 no
	 * */
	function shouldEquipItemInCell(Cell:CqEquipmentCell, Item:CqItem):Float {
		if (Cell.equipSlot != Item.equipSlot)
			return 0.0;
		
		if (Cell.getCellObj() == null)
			return 2.0;
		
		return Item.compareTo( Cell.getCellObj().item );
	}
	
	private function equipItem(Cell:CqInventoryCell, Item:CqItem, UiItem:CqInventoryItem):CqInventoryItem {
		var old:CqInventoryItem = cast(Cell, CqEquipmentCell).clearCellObj();
		UiItem.setEquipmentCell(Cell.cellIndex);
		CqRegistery.player.equipItem(Item);
		return old;
	}
	
	public function getEmptyCell():CqInventoryCell {
		var emptyCell:CqInventoryCell = null;
		for ( cell in dlgInvGrid.cells ) {
			if ( cell.getCellObj() == null && !cell.dropCell ) {
				emptyCell = cell;
				break;
			}
		}
		
		return emptyCell;
	}
	public function onPressedUiItem() {
		isMarkedCell = false;
		usingKeys = false;
		gridOrder[currentGrid].cells[lcellId].setGlow(false);
		gridOrder[currentGrid].cells[cellId].setGlow(false);
		currentGrid = cellId = lcellId = 0;
	}
	public function update()
	{
		if ( HxlGraphics.mouse.dragSprite != null ) 
			return;
		//checkKeys();
	}
	function checkKeys() {
		if (gridOrder == null){
			gridOrder = [dlgInvGrid, dlgPotionGrid, dlgSpellGrid, dlgEqGrid];
			gridOrientation = [2, 0, 1, 3];
		}
		cellId = lcellId;
		gridOrder[currentGrid].cells[lcellId].setGlow(false);
		if (HxlGraphics.keys.justPressed("UP") || HxlGraphics.keys.justPressed("W"))
		{
			if (simpleMovement)
				changeCurrentGrid(1);
			else
				onPress("u", gridOrientation[currentGrid]);
		}else if (HxlGraphics.keys.justPressed("DOWN") || HxlGraphics.keys.justPressed("S"))
		{
			if (simpleMovement)
				changeCurrentGrid(-1);
			else
				onPress("d", gridOrientation[currentGrid]);
		}else if (HxlGraphics.keys.justPressed("LEFT") || HxlGraphics.keys.justPressed("A"))
		{
			if (simpleMovement)
				cellId--;
			else
				onPress("l", gridOrientation[currentGrid]);
		}else if (HxlGraphics.keys.justPressed("RIGHT") || HxlGraphics.keys.justPressed("D"))
		{
			if (simpleMovement)
				cellId++;
			else
				onPress("r", gridOrientation[currentGrid]);
		}else if (HxlGraphics.keys.justPressed("ENTER") || HxlGraphics.keys.justPressed("NONUMLOCK_5"))
		{
			invKeyAction();
		}else if (HxlGraphics.keys.justPressed("TAB"))
		{
			if(HxlGraphics.keys.ALT)
				changeCurrentGrid(1);
			else
				changeCurrentGrid(-1);
		}else if (HxlGraphics.keys.justPressed("TAB") && HxlGraphics.keys.SHIFT)
		{
			simpleMovement = !simpleMovement;
		}
		
		if (cellId != lcellId)
			usingKeys = true;
		if (!usingKeys) return;
		if (cellId < 0)
			if (simpleMovement)
				changeCurrentGrid(-1);
			else
				cellId = 0;
		if (cellId >= gridOrder[currentGrid].cells.length) 
			if (simpleMovement)
				changeCurrentGrid(1);
			else
				cellId = gridOrder[currentGrid].cells.length-1;

		if (isMarkedCell)
		{
			gridOrder[markedGrid].cells[markedCellId].setGlow(true);
		}
		gridOrder[currentGrid].cells[cellId].setGlow(true);
		
		lcellId = cellId;
	}
	function onPress(dir:String, orient:Int)
	{
		var rowVal:Int = Std.int(gridOrder[currentGrid].cells.length / 2);
		switch(orient) {
			case 0://hor
				switch(dir) {
				case "r", "u":
					cellId++;
				case "l", "d":
					cellId--;
				}
			case 1://vertical
				switch(dir) {
				case "l", "u":
					cellId--;
				case "r", "d":
					cellId++;
				}
			case 2://hor multiline
				switch(dir) {
				case "l":
					cellId--;
				case "r":
					cellId++;
				case "u":
					if(!(barrierMode&& cellId - rowVal < 0))
						cellId -= rowVal;
				case "d":
					if(!(barrierMode && cellId + rowVal >= gridOrder[currentGrid].cells.length))
						cellId += rowVal;
				}
			case 3://vert multiline
				switch(dir) {
				case "d":
					cellId--;
				case "u":
					cellId++;
				case "l":
					if(!(barrierMode && cellId - rowVal < 0))
						cellId -= rowVal;
				case "r":
					if(!(barrierMode && cellId + rowVal >= gridOrder[currentGrid].cells.length))
						cellId += rowVal;
				}
		}
	}
	function changeCurrentGrid(direction:Int)
	{
		switch(direction)
		{
			case 1:
				if (currentGrid == gridOrder.length-1)
				{
					currentGrid = 0;
					cellId = 0;
				}else {
					currentGrid++;
					cellId = 0;
				}
			case -1:
				if (currentGrid == 0)
				{
					currentGrid = gridOrder.length-1;
					cellId = gridOrder[currentGrid].cells.length-1;
				}else {
					currentGrid--;
					cellId = gridOrder[currentGrid].cells.length-1;
				}
			default:
				return;
		}
	}
	function invKeyAction() {
		var cellObj:CqInventoryItem = gridOrder[currentGrid].getCellObj(cellId);
		if (cellObj != null)
		{
			if (instaEquip)
			{
				if (currentGrid == 0)//if inv
				{
					switch(cellObj.item.equipSlot) {
						case POTION:	
						case SPELL:
							var emptySpellCell:Int = dlgSpellGrid.getOpenCellIndex();
							if (emptySpellCell == -1)//just replace the first one if there no empty ones.
								emptySpellCell = 0;
							var replacedItem:CqInventoryItem = dlgSpellGrid.getCellObj(emptySpellCell);
							if (replacedItem != null)
							{
								replacedItem.setInventoryCell(cellId);
								replacedItem.popup.setText(replacedItem.item.fullName);		
							}
							
						default:
							//
							var newCell:CqInventoryCell = null; 
							for (cl in dlgEqGrid.cells) {
								if (cast(cl, CqEquipmentCell).equipSlot == cellObj.item.equipSlot)
								{	newCell = cl;   break;		}
							}
							gridOrder[currentGrid].cells[cellId].clearCellObj();
							
							var replacedItem:CqInventoryItem = equipItem(newCell, cellObj.item, cellObj);
							newCell.update();
							if(replacedItem != null){
								replacedItem.setInventoryCell(cellId);
								replacedItem.popup.setText(replacedItem.item.fullName);
							}
					}
				}
			}
		}
		/*
		if (isMarkedCell)
		{
			if (currentGrid == 0 && cellId == 13)
			{
				trace("destroy item");
				isMarkedCell = false;
				gridOrder[markedGrid].cells[markedCellId].setGlow(false);
			} else if (cellObj != null)
			{
				trace("switch items");
				isMarkedCell = false;
				gridOrder[markedGrid].cells[markedCellId].setGlow(false);
			}else {
				trace("move item");
				isMarkedCell = false;
				gridOrder[markedGrid].cells[markedCellId].setGlow(false);
			}
		}else{
			if (cellObj != null)
			{
				markedGrid = currentGrid;
				markedCellId = cellId;
				isMarkedCell = true;
			}
		}*/
	}
}