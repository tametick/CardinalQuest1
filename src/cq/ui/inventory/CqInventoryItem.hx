


package cq.ui.inventory;

import cq.GameUI;
import cq.states.GameState;
import data.SoundEffectsManager;
import data.Registery;
import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.MouseEvent;
import haxel.HxlDialog;
import haxel.HxlMouse;
import haxel.HxlPoint;
import haxel.HxlSprite;
import haxel.HxlSpriteSheet;
import haxel.HxlText;
import haxel.HxlGraphics;
import haxel.GraphicCache;

import cq.CqResources;
import cq.CqItem;

import cq.ui.CqSpellButton;
import cq.ui.CqPotionButton;

// tmp
import cq.ui.inventory.CqInventoryDialog;
class CqInventoryItemBMPData extends BitmapData { }
class CqInventoryItem extends HxlSprite {
	public static var backgroundKey:CqGraphicKey;
	public static var backgroundSelectedKey:CqGraphicKey;
	public static var selectedItem:CqInventoryItem = null;
	
	public static var itemSheet:HxlSpriteSheet;
	public static var itemSprite:HxlSprite;
	public static var spellSheet:HxlSpriteSheet;
	public static var spellSprite:HxlSprite;
		
	var background:BitmapData;
	var icon:CqInventoryItemBMPData;
	public var _dlg:CqInventoryDialog;
	public var inDialog:HxlDialog;
	var idleZIndex:Int;
	var dragZIndex:Int;
	var cellIndex:Int;
	public var clearCharge:Bool;

	public var isInCell:CqEquipSlot;
	
	public var item(default, setItem):CqItem;
	private function setItem(value:CqItem):CqItem{
		item = value;
		if (item != null)
			item.uiItem = this;
		return item;
	}
	
	var selected:Bool;
	var isGlowing:Bool;
	var glowSprite:CqInventoryItemBMPData;
	var glowRect:Rectangle;

	public function new(Dialog:CqInventoryDialog, ?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		icon = null;
		idleZIndex = 11;
		dragZIndex = 11;
		_dlg = Dialog;
		cellIndex = 0;
		isInCell = null;
		item = null;
		zIndex = idleZIndex;
		setSelected(false);
		glowRect = new Rectangle(0, 0, 58, 58);
		isGlowing = false;
	}
	
	override public function destroy() {
		super.destroy();
		if(icon!=null) {
			icon.dispose();
			icon = null;
		}
		if(glowSprite!=null) {
			glowSprite.dispose();
			glowSprite = null;
		}
		if(pixels!=null) {
			pixels.dispose();
			pixels = null;
		}
	}
	
	public static function createUIItem(Item:CqItem, dialog:CqInventoryDialog):CqInventoryItem {
		
		//basic stuff
		var uiItem:CqInventoryItem = new CqInventoryItem(dialog, 2, 2);
		uiItem.toggleDrag(true);
		uiItem.zIndex = 5;
		uiItem.item = Item;
		Item.uiItem = uiItem;
		if ( Std.is(Item, CqSpell) ) {
			spellSprite.setFrame(spellSheet.getSpriteIndex(Item.spriteIndex));
			uiItem.setIcon(spellSprite.getFramePixels());
		} else {
			itemSprite.setFrame(itemSheet.getSpriteIndex(Item.spriteIndex));
			uiItem.setIcon(itemSprite.getFramePixels());
		}
		
		//popup
		uiItem.setPopup(new CqPopup(180,Item.fullName,GameUI.instance.popups));
		GameUI.instance.popups.add(uiItem.popup);
		uiItem.popup.zIndex = 15;
		
		//make magical items glow
		if (Item.isSuperb && !Item.isMagical && !Item.isWondrous) {
			uiItem.customGlow(0x206CDF);
			uiItem.setGlow(true);
		} else if (Item.isMagical && !Item.isSuperb)	{
			uiItem.customGlow(0x3CDA25);
			uiItem.setGlow(true);
		} else if (Item.isMagical && Item.isSuperb)	{
			uiItem.customGlow(0x1FE0D7);
			uiItem.setGlow(true);
		} else if (Item.isWondrous && Item.isSuperb)	{
			uiItem.customGlow(0xE7A918);
			uiItem.setGlow(true);
		}
		return uiItem;
	}
	/**
	 * Updates the visuals appearance, to reflect it being selected or not
	 * @param	Toggle
	 */
	public function setSelected(Toggle:Bool) {
		selected = Toggle;
		if ( selected ) {
			loadCachedGraphic(backgroundSelectedKey);
			background = GraphicCache.getBitmap(backgroundSelectedKey);
			if ( icon != null ) setIcon(icon);
			_dlg.dlgInfo.setItem(item);
		} else {
			loadCachedGraphic(backgroundKey);
			background = GraphicCache.getBitmap(backgroundKey);
			if ( icon != null ) setIcon(icon);
		}
	}
	
	public function customGlow(color:Int) {
		var tmp:CqInventoryItemBMPData = new CqInventoryItemBMPData(48, 48, true, 0x0);
		tmp.copyPixels(getFramePixels(), new Rectangle(0, 0, 48, 48), new Point(0, 0), null, null, true);
		var glow:GlowFilter = new GlowFilter(color, 0.9, 16.0, 16.0, 1.6, 1, false, false);
		tmp.applyFilter(tmp, glowRect, new Point(0, 0), glow);
		glowSprite = tmp;
		glow = null;
		tmp = null;
	}
	
	public function setGlow(Toggle:Bool) {
		isGlowing = Toggle;
		if (isGlowing)
			renderGlow();
	}
	
	function renderGlow() {
		getScreenXY(_point);
		_flashPoint.x = _point.x - 8;
		_flashPoint.y = _point.y - 8;
		_pixels.copyPixels(glowSprite, glowRect, _flashPoint, null, null, true);
		setPixels(glowSprite);
	}
	
	override public function update() 
	{
		super.update();
		var m:HxlMouse = HxlGraphics.mouse;
		if ( overlapsPoint(m.x, m.y) && visible)
		{
			GameUI.instance.panels.panelInventory.dlgInfo.setItem(item);
		}
	}
	public function updateIcon() {
		setIcon(icon);
	}

	public function setIcon(Icon:BitmapData) {
		icon = new CqInventoryItemBMPData(Icon.width, Icon.height, true, 0x0);
		icon.copyPixels(Icon, new Rectangle(0, 0, Icon.width, Icon.height), new Point(0,0), null, null, true);
		var X:Int = Std.int((width / 2) - (icon.width / 2));
		var Y:Int = Std.int((height / 2) - (icon.height / 2));
		var temp:CqInventoryItemBMPData = new CqInventoryItemBMPData(background.width, background.height, true, 0x0);
		temp.copyPixels(background, new Rectangle(0, 0, background.width, background.height), new Point(0, 0), null, null, true);
		temp.copyPixels(icon, new Rectangle(0, 0, icon.width, icon.height), new Point(X, Y), null, null, true);
		if ( item.stackSize > 1 ) {
			var txt:HxlText = new HxlText(0, 0, Std.int(width), ""+item.stackSize);
			txt.setProperties(false, false, false);
			txt.setFormat(null, 18, 0xffffff, "right", 0x010101);
			temp.copyPixels(txt.pixels, new Rectangle(0, 0, txt.width, txt.height), new Point(0, (height-2-txt.height)), null, null, true);
		}
		pixels = temp;
		if (isGlowing)
			renderGlow();
			
		temp = null;
	}

	/**
	 * Sets this object as the CellObj of the target inventory cell, and places this object within that cell.
	 **/
	public function setInventoryCell(Cell:Int) {		
		if (isInCell == POTION) {
			Registery.player.equippedSpells[cellIndex] = null;
			_dlg.dlgSpellGrid.clearCharge(cellIndex);
		}
		popup.setText(item.fullName);
		zIndex = idleZIndex;
		addToDialog(_dlg);
		cellIndex = Cell;
		setPos(_dlg.dlgInvGrid.getCellItemPos(Cell));
		_dlg.dlgInvGrid.setCellObj(Cell, this);
		isInCell = null;
	}
	
	/**
	 * Sets this object as the CellObj of the target equipment cell, and places this object within that cell.
	 **/
	public function setEquipmentCell(Cell:Int):Bool {
		zIndex = idleZIndex;
		var cellRef:CqEquipmentCell = cast(_dlg.dlgEqGrid.cells[Cell], CqEquipmentCell);
		if ( cellRef.equipSlot != this.item.equipSlot ) {
			Cell = _dlg.dlgInvGrid.getOpenCellIndex();
			setInventoryCell(Cell);
			return false;
		}
		addToDialog(_dlg);

		SoundEffectsManager.play(ItemEquipped);
		cellRef.icon.visible = false;
		cellIndex = Cell;
		setPos(_dlg.dlgEqGrid.getCellItemPos(Cell));
		_dlg.dlgEqGrid.setCellObj(Cell, this);
		isInCell = cellRef.equipSlot;
		return true;
	}

	/**
	 * Sets this object as the CellObj of the target spell cell, and places this object within that cell.
	 **/
	public function setSpellCell(Cell:Int):Bool {
		if (!Std.is(this.item, CqSpell))
			return false;
		
		if (isInCell == SPELL) {
			// if it was already in a different spell cell before moving to the new spell cell
			Registery.player.equippedSpells[cellIndex] = null;
		}
		
		zIndex = idleZIndex;
		if (_dlg.dlgSpellGrid.cells.length <= Cell)
			return false;
		
		/*if ( cast(_dlg.dlgSpellGrid.cells[Cell], CqEquipmentCell).equipSlot != this.item.equipSlot ) {
			Cell = _dlg.dlgInvGrid.getOpenCellIndex();
			setInventoryCell(Cell);
			return false;
		}*/
		SoundEffectsManager.play(SpellEquipped);
		popup.setText(item.fullName+"\n[hotkey " + (Cell + 1) + "]");
		addToDialog(_dlg.dlgSpellGrid);
		cellIndex = Cell;
		setPos(_dlg.dlgSpellGrid.getCellItemPos(Cell));
		_dlg.dlgSpellGrid.setCellObj(Cell, this);
		isInCell = SPELL;
		
		Registery.player.equippedSpells[cellIndex] = cast(this.item,CqSpell);
		
		return true;
	}
	
	public function removeFromCell():Void 
	{
		if (isInCell == null) {
			_dlg.dlgInvGrid.cells[cellIndex].setCellObj(null);
		}else{
		switch(isInCell) {
			case POTION:
				_dlg.dlgPotionGrid.cells[cellIndex].setCellObj(null);
			case SPELL:
				_dlg.dlgSpellGrid.cells[cellIndex].setCellObj(null);
			default:
				_dlg.dlgEqGrid.cells[cellIndex].setCellObj(null);
			
		}
		}
		cellIndex = -1;
	}

	/**
	 * Sets this object as the CellObj of the target potion cell, and places this object within that cell.
	 **/
	public function setPotionCell(Cell:Int):Bool {
		zIndex = idleZIndex;

		if ( cast(_dlg.dlgPotionGrid.cells[Cell], CqEquipmentCell).equipSlot != this.item.equipSlot ) {
			Cell = _dlg.dlgInvGrid.getOpenCellIndex();
			setInventoryCell(Cell);
			return false;
		}
		SoundEffectsManager.play(PotionEquipped);
		popup.setText(item.fullName+"\n[hotkey " + ((Cell>3)?Cell-4:Cell + 6) + "]");
		addToDialog(_dlg.dlgPotionGrid);
		cellIndex = Cell;
		setPos(_dlg.dlgPotionGrid.getCellItemPos(Cell));
		_dlg.dlgPotionGrid.setCellObj(Cell, this);
		isInCell = POTION;
		return true;
	}
	public function setPos(Pos:HxlPoint) {
		x = Pos.x;
		y = Pos.y;
	}

	public override function toggleDrag(Toggle:Bool) {
		super.toggleDrag(Toggle);
		if ( dragEnabled ) {
			removeEventListener(MouseEvent.MOUSE_DOWN, onDragMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, onDragMouseUp);
			addEventListener(MouseEvent.MOUSE_DOWN, onDragMouseDown, true, 5,true);
			addEventListener(MouseEvent.MOUSE_UP, onDragMouseUp, true, 4,true);
		}
	}
	private override function onDragMouseDown(event:MouseEvent) {
		if (GameUI.instance==null ||  !Std.is(GameUI.instance.panels.currentPanel,CqInventoryDialog) || !exists || !visible || !active || !dragEnabled || !Std.is(HxlGraphics.state,GameState)) 
			return;
		super.onDragMouseDown(event);
		if ( isDragging ) {
			event.stopPropagation();
			if ( selectedItem != null ) {
				// Unset the old selected item if one was set
				selectedItem.setSelected(false);
				selectedItem = null;
			}
			// I now become the selected item
			selectedItem = this;
			GameUI.instance.invItemManager.onPressedUiItem();
			setSelected(true);
		}
	}

	private override function onDragMouseUp(event:MouseEvent) {
		if ( !exists || !visible || !active || !dragEnabled || !Std.is(GameUI.instance.panels.currentPanel,CqInventoryDialog) || HxlGraphics.mouse.dragSprite != this ) 
			return;
		super.onDragMouseUp(event);
		if ( !isDragging ) {
			event.stopPropagation();
		}
	}

	override function dragStart() {
		if (isInCell != null && isInCell != POTION && isInCell != SPELL) {
			var cellRef:CqEquipmentCell = cast(_dlg.dlgEqGrid.cells[cellIndex], CqEquipmentCell);
			cellRef.icon.visible = true;
		}
		GameUI.instance.invItemManager.dragStart(this);
		super.dragStart();
	}
	
	// If the user was hovering an eligable drop target, act on it
	override function dragStop() {
		//todo: merge gotosamecell and revert methods.
		removeFromDialog();
		//collect info
		var dragStopCell:CqInventoryCell = CqInventoryCell.highlightedCell;
		var dragStopCell_class:Dynamic = Type.getClass(dragStopCell);
		
		if ( dragStopCell != null ) {
			
			var dragStop_cell_obj:CqInventoryItem = dragStopCell.getCellObj();	
			if ( dragStop_cell_obj != null )
			{
				if(dragStop_cell_obj == this)
					stopdrag_gotoSameCell(dragStopCell_class, dragStopCell);
				else
					stopdrag_revert(); // gotoOccupiedCell simply doesn't work.  Pity.
					// stopdrag_gotoOccupiedCell(dragStopCell_class, dragStopCell,dragStop_cell_obj);
			}else {
				stopdrag_gotoEmptyCell(dragStopCell_class, dragStopCell);
			}
			
		} else {
			stopdrag_revert();
		}
		_dlg.dlgEqGrid.setGlowForAll(false);
		_dlg.dlgSpellGrid.setGlowForAll(false);
		_dlg.dlgPotionGrid.setGlowForAll(false);
		super.dragStop();
	}
	//when user drops item in same place he picked it up
	private function stopdrag_gotoSameCell(dragStopCell_class:Dynamic, dragStopCell:CqInventoryCell):Void 
	{
		switch(dragStopCell_class) {
			case CqSpellCell:
				// Moving this item into a spell cell
				setSpellCell(dragStopCell.cellIndex);
			case CqPotionCell:
				// Moving this item into a potion cell
				setPotionCell(dragStopCell.cellIndex);
			case CqEquipmentCell:
				// Moving this item into an equipment cell
				setEquipmentCell(dragStopCell.cellIndex);
			case CqInventoryCell:
				// Moving this item into an inventory cell
				setInventoryCell(dragStopCell.cellIndex);
		}
	}
	//when user drops item on another item
	private function stopdrag_gotoOccupiedCell(dragStopCell_class:Dynamic, dragStopCell:CqInventoryCell, dragStop_cell_obj:CqInventoryItem) {
		// There was already an item in the target cell, switch places with it
		if (isInCell == null)
		{
			// Moving the other item into an inventory cell
			dragStop_cell_obj.setInventoryCell(cellIndex);	
		}else{
			switch(isInCell) {
				case SPELL:
					// Moving the other item into a spell cell
					dragStop_cell_obj.setSpellCell(cellIndex);
					var spellBtn = _dlg.dlgSpellGrid.getSpellCell(cellIndex).btn;
					if (dragStop_cell_obj != this)
						GameUI.instance.updateCharge(spellBtn);
				case POTION:
					// Moving the other item into a potion cell
					dragStop_cell_obj.setPotionCell(cellIndex);
				default:
					dragStop_cell_obj.setInventoryCell(cellIndex);	
			}
		}
		//from equip to inv
		if (isInCellEquip()) {
			Registery.player.unequipItem(item);
			Registery.player.equipItem(dragStop_cell_obj.item);
			dragStop_cell_obj.setEquipmentCell(cellIndex);
		}
		
		
		switch(dragStopCell_class) {
			case CqSpellCell:
				// item into a spell cell
				setSpellCell(dragStopCell.cellIndex);
			case CqPotionCell:
				// tem into a potion cell
				setPotionCell(dragStopCell.cellIndex);
			case CqEquipmentCell:
				// into an equipment cell
				Registery.player.unequipItem(dragStop_cell_obj.item);
				Registery.player.equipItem(this.item);
				//move new to other's place
				setEquipmentCell(dragStopCell.cellIndex);
				popup.setText(item.fullName);
				setInventoryCell(dragStopCell.cellIndex);
			default:
				// Moving this item into an inventory cell
				popup.setText(item.fullName);
				setInventoryCell(dragStopCell.cellIndex);
		}
		cellIndex = dragStopCell.cellIndex;
	}
	//return to pre drag position, when item dropped on invalid area
	private function stopdrag_revert() {
		setPos(dragStartPoint);
		
		//if last cell was of type == item equipslot, means its from that dialog, so add there
		if (item.equipSlot == CqEquipSlot.POTION && isInCell == POTION) {
			addToDialog(_dlg.dlgPotionGrid);
		} else if (item.equipSlot == CqEquipSlot.SPELL && isInCell == SPELL) {
			addToDialog(_dlg.dlgSpellGrid);
		} else {
			//else add to inv
			addToDialog(_dlg);
		}
	}
	
	// when item dropped on a empty cell
	private function stopdrag_gotoEmptyCell(dragStopCell_class:Dynamic, dragStopCell:CqInventoryCell) {
		if (isInCell == null)
		{
			// Clearing out an inventory cell
			_dlg.dlgInvGrid.setCellObj(cellIndex, null);
		}else{
			switch(isInCell) {
				//where it came from
				case SPELL:
					// Clearing out a spell cell
					var cellIndexNew = dragStopCell.cellIndex;
					var spellCell = _dlg.dlgSpellGrid.getSpellCell(cellIndex); 
					var spellBtn = spellCell.btn;
					_dlg.dlgSpellGrid.setCellObj(cellIndex, null);
					setSpellCell(dragStopCell.cellIndex);
					GameUI.instance.updateCharge(spellBtn);
				case POTION:
					// Clearing out a potion cell
					_dlg.dlgPotionGrid.setCellObj(cellIndex, null);
				default:
					// Clearing out an equipment cell
					_dlg.dlgEqGrid.setCellObj(cellIndex, null);
					Registery.player.unequipItem(this.item);
			}
		}
		switch(dragStopCell_class){
			case CqSpellCell:
				// Moving this item into a spell cell
				setSpellCell(dragStopCell.cellIndex);
				var spellCell = _dlg.dlgSpellGrid.getSpellCell(dragStopCell.cellIndex); 
				var spellBtn = spellCell.btn;
				GameUI.instance.updateCharge(spellBtn);
				if (clearCharge)_dlg.dlgSpellGrid.clearCharge(dragStopCell.cellIndex);
			case CqPotionCell:
				// Moving this item into a potion cell
				setPotionCell(dragStopCell.cellIndex);
			case CqEquipmentCell:
				// Moving this item into an equipment cell
				setEquipmentCell(dragStopCell.cellIndex);
				Registery.player.equipItem(this.item);
			default:
				popup.setText(item.fullName);
				if ( dragStopCell.dropCell ) {
					// This item is being dropped
					Registery.player.giveMoney( item.getMonetaryValue() );
					removeFromDialog();
					destroy();
					kill();
					Registery.player.removeInventory(this.item);
					_dlg.dlgInfo.clearInfo();
					CqInventoryItem.selectedItem = null;
					return;
				} else {
					setInventoryCell(dragStopCell.cellIndex);
				}
		}
		cellIndex = dragStopCell.cellIndex;
	}
	
	public function isInCellEquip():Bool
	{
		return (isInCell != null && isInCell != POTION && isInCell != SPELL);
	}
	public function addToDialog(dialog:HxlDialog)
	{
		inDialog = dialog;
		dialog.add(this);
	}
	public function removeFromDialog():Void 
	{
		if (inDialog == null)
			return;
		inDialog.remove(this);
	}
	//check if this CQinventoryItem is over the char equipment silhouette
	inline function isOnCharSilhouette():Bool {
		var myX = x + origin.x;
		var myY = y + origin.y;
		var objX = _dlg.dlgCharacter.x+80;
		var objY = _dlg.dlgCharacter.y+40;
		var objW = 80;
		var objH = 200;
		return  ( (myX >= objX) || (myX <= objX + objW) || (myY >= objY) || (myY <= objY + objH) );
	}
}