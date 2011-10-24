package cq.ui.inventory;
import cq.CqGraphicKey;
import cq.CqItem;
import data.Registery;
import cq.CqResources;
import cq.GameUI;
import cq.ui.CqItemInfoDialog;
import cq.ui.CqPotionGrid;
import cq.ui.CqSpellGrid;
import cq.ui.inventory.CqInventoryItem;
import data.Configuration;
import data.Resources;
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
		dlgInvGrid.update();
		dlgEqGrid.update();
		mainDialog.update();
	}
	/**
	 * True - added to inventory or equipped
	 * False - destroyed or added to potion/spell belts
	 * */
	public function itemPickup(Item:CqItem):Bool {
		// stacking was already done by CqActor.give(...), just updating potion icon
		if ( Item.equipSlot == POTION ) {
			for ( cell in dlgPotionGrid.cells ) {
				if ( cell.getCellObj() != null && cell.getCellObj().item == Item ) {
					cell.getCellObj().updateIcon();
					return false;
				}
			}
			for ( cell in dlgInvGrid.cells ) {
				if ( cell.getCellObj() != null && cell.getCellObj().item == Item ) {
					cell.getCellObj().updateIcon();
					return false;
				}
			}
		}		
		// if an equivalent item already is in inventory, destory picked up item
		for ( cell in dlgInvGrid.cells ) {
			if ( cell.getCellObj() != null && cell.getCellObj().item.equalTo(Item) && Item.equipSlot != SPELL) {
				GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_DUPLICATE" ));
				Registery.player.giveMoney( Item.getMonetaryValue() );
				return false;
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
						return false;
					}
				}
			} else if ( Item.equipSlot == SPELL ) {
				dlgInfo.setItem(Item);
				for ( cell in dlgSpellGrid.cells ) {
					if ( cell.getCellObj() == null ) {
						uiItem.setSpellCell(cell.cellIndex);
						cell.getCellObj().updateIcon();
						SoundEffectsManager.play(SpellEquipped);
						return false;
					}
				}
			} else {
				//item in equipment
				var cell:CqEquipmentCell = dlgEqGrid.getCellWithSlot(Item.equipSlot);
				//if slot was empty - equip
				if (cell.getCellObj() == null) {
					GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_FIRST" ), 0xBFE137);
					uiItem = equipItem(cell, Item, uiItem);
					cell.getCellObj().updateIcon();
					dlgInfo.setItem(Item);
					return true;
				} else {
					
					if ( Item.equalTo( cell.getCellObj().item) ) {// && !Item.isEnchanted && !cell.getCellObj().item.isEnchanted) {
						GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_DUPLICATE" ), 0xE1CC37);
						destroyAndGiveMoney(Item);
						return false;
					}

					if ( Item.makesRedundant( cell.getCellObj().item ) ) {
						// Totally better than the old item.
						var old:CqInventoryItem = equipItem(cell, Item, uiItem);
						dlgInfo.setItem(Item);
						
						GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_SELLOLD1" ) + " " + old.item.name + Resources.getString( "NOTIFY_GET_SELLOLD2" ), 0xBFE137);
						destroyAndGiveMoney(old.item);
						return true;
					} else if ( cell.getCellObj().item.makesRedundant( Item ) ) {
						// Old item is totally better than this one!
						GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_SELLNEW1" ) + " " + cell.getCellObj().item.name + Resources.getString( "NOTIFY_GET_SELLNEW2" ) );
						destroyAndGiveMoney(Item);
						return false;
					} else {
						// It's a valid alternative. But do we want to use it right now?
						var preference:Float = shouldEquipItemInCell(cell, Item);
						
						if ( preference > 1 ) {
							// Yep, let's equip it!
							var old:CqInventoryItem = equipItem(cell, Item, uiItem);
							dlgInfo.setItem(Item);
							
							GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_STASHOLD1" ) + " " + old.item.name + Resources.getString( "NOTIFY_GET_STASHOLD2" ), 0xBFE137);
							uiItem = old;
						} else {
							// Nope. Make sure it's not redundant.
							for ( cell in dlgInvGrid.cells ) {
								if ( cell.getCellObj() != null ) {
									var cellItem:CqItem = cell.getCellObj().item;
									
									if ( cellItem.equipSlot == uiItem.item.equipSlot ) {
										if ( uiItem.item.makesRedundant( cellItem ) ) {
											// Sell the cell item.
											dlgInvGrid.remove(cell.getCellObj());
											destroyAndGiveMoney(cellItem);
										} else if ( cellItem.makesRedundant( uiItem.item ) ) {
											// Sell the item.
											GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_REDUNDANT" ), 0xBFE137);
											destroyAndGiveMoney(uiItem.item);
											return false;
										}
									}
								}
							}							
							
							GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_STASHNEW1" ) + " " + Item.name + Resources.getString( "NOTIFY_GET_STASHNEW2" ), 0xBFE137);
						}
					}
				}
			}
		}

		var emptyCell:CqInventoryCell = getEmptyCell();
		if (emptyCell != null ) {
			// add to inventory
			uiItem.setInventoryCell(emptyCell.cellIndex);
			return true;
		} else {
			throw "no room in inventory, should not happen because pick up should have not been allowed!";
		}
	}
	
	public function hasItemMinusBuffs(item:CqItem):Bool 
	{
		var itr:Iterator<String> = item.buffs.keys();
		while (itr.hasNext())
		{
			var key:String = itr.next();
			if (0 > item.buffs.get(key))
				return true;
		}
		return false;
	}
	function destroyAndGiveMoney(Item:CqItem)
	{
		Registery.player.giveMoney( Item.getMonetaryValue() );
		mainDialog.remove(Item.uiItem);
		Item.uiItem.destroy();
		Item.destroy();
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
		var old:CqInventoryItem = Cell.clearCellObj();
		UiItem.setEquipmentCell(Cell.cellIndex);
		Registery.player.equipItem(Item);
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
		if(GameUI.instance.panels.currentPanel == mainDialog)
			checkKeys();
		else
			onPressedUiItem();
	}
	
	public function dragStart(UiItem:CqInventoryItem):Void 
	{
		//if its moved from an spell cell, make it not clear charge after dragging stops
		if (UiItem.item.equipSlot == CqEquipSlot.SPELL) {
			if (UiItem.isInCell == SPELL)
				UiItem.clearCharge = false;
			else
				UiItem.clearCharge = true;
		}
		mainDialog.remove(UiItem);
		mainDialog.dlgSpellGrid.remove(UiItem);
		mainDialog.dlgPotionGrid.remove(UiItem);
		mainDialog.dlgInvGrid.remove(UiItem);
		mainDialog.dlgEqGrid.remove(UiItem);
		mainDialog.zIndex = 400;
		UiItem.addToDialog(mainDialog);
		switch(UiItem.item.equipSlot) {
			case POTION:
				mainDialog.dlgPotionGrid.setGlowForAll(true);
			case SPELL:
				mainDialog.dlgSpellGrid.setGlowForAll(true);
			default:
				mainDialog.dlgEqGrid.setGlowForSlot(UiItem.item.equipSlot, true);
		}
	}
	
	
	// need to tie this in with the key stuff in Config.
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
			//first finish automove
			//simpleMovement = !simpleMovement;
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
		showInfo(gridOrder[currentGrid].getCellObj(cellId));
		gridOrder[currentGrid].cells[cellId].setGlow(true);
		
		lcellId = cellId;
	}
	
	private function showInfo(cellObj:CqInventoryItem):Void 
	{	if(cellObj != null)
			dlgInfo.setItem(cellObj.item);
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
		//todo
		//currently disabled, becouse automove only works from inv
		return;
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
		if (cellObj != null && instaEquip)
		{
			autoMove(cellObj);
		}else
		{
			autoMarkMove(cellObj);
		}
		GameUI.instance.updateCharges();
	}
	function autoMove(cellObj:CqInventoryItem) {
		if (currentGrid == 0)//if inv
		{
			var toCell:CqInventoryCell = null;
			cellObj.removeFromDialog();
			switch(cellObj.item.equipSlot) {
				case POTION:	
					var open:Int = dlgPotionGrid.getOpenCellIndex();
					if (open < 0)
						return;
					gridOrder[currentGrid].cells[cellId].setCellObj(null);
					cellObj.setPotionCell(open);
				case SPELL:	
					var open:Int = dlgSpellGrid.getOpenCellIndex();
					if (open < 0)
						open = 0;
					toCell = dlgSpellGrid.cells[open];
					var replacedItem:CqInventoryItem = toCell.getCellObj();
					cellObj.setSpellCell(open);
					dlgSpellGrid.clearCharge(open);
					gridOrder[currentGrid].cells[cellId].setCellObj(null);
					if (replacedItem != null)
						replacedItem.setInventoryCell(cellId);
				default:
					//
					toCell = dlgEqGrid.getCellWithSlot(cellObj.item.equipSlot);
					var replacedItem:CqInventoryItem = toCell.clearCellObj();
					cellObj.setEquipmentCell(toCell.cellIndex);
					Registery.player.equipItem(cellObj.item);
					gridOrder[currentGrid].cells[cellId].setCellObj(null);
					toCell.update();
					if(replacedItem != null){
						replacedItem.setInventoryCell(cellId);
						//Registery.player.unequipItem(replacedItem.item);
					}
			}
		}
	}
				
	function autoMarkMove(cellObj:CqInventoryItem) {
		//mark an object then choose other cell where to move it.
		//in progress..
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