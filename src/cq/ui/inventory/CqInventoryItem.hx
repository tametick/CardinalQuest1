package cq.ui.inventory;

import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.MouseEvent;
import haxel.HxlDialog;
import haxel.HxlPoint;
import haxel.HxlSprite;
import haxel.HxlText;
import haxel.HxlGraphics;
import haxel.GraphicCache;

import cq.CqResources;
import cq.CqItem;

import cq.ui.CqSpellButton;
import cq.ui.CqPotionButton;

// tmp
import cq.ui.inventory.CqInventoryDialog;

class CqInventoryItem extends HxlSprite {
	public static var backgroundKey:CqGraphicKey;
	public static var backgroundSelectedKey:CqGraphicKey;
	public static var selectedItem:CqInventoryItem = null;
	var background:BitmapData;
	var icon:BitmapData;
	public var _dlg:CqInventoryDialog;
	var idleZIndex:Int;
	var dragZIndex:Int;
	var cellIndex:Int;
	var clearCharge:Bool;
	
	//these are true only when the item is in that particular cell, to see if goes where use cQitem.equipSlot
	public var cellEquip:Bool;
	public var cellSpell:Bool;
	public var cellPotion:Bool;
	public var item:CqItem;
	
	var selected:Bool;
	var isGlowing:Bool;
	var glowSprite:BitmapData;
	var glowRect:Rectangle;

	public function new(Dialog:CqInventoryDialog, ?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		icon = null;
		idleZIndex = 11;
		dragZIndex = 11;
		_dlg = Dialog;
		cellIndex = 0;
		cellEquip = false;
		cellSpell = false;
		cellPotion = false;
		item = null;
		zIndex = idleZIndex;
		setSelected(false);
		glowRect = new Rectangle(0, 0, 58, 58);
		isGlowing = false;
	}

	public function removeFromDialog() {
		_dlg.remove(this);
	}
	
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
		var tmp:BitmapData = new BitmapData(48, 48, true, 0x0);
		tmp.copyPixels(getFramePixels(), new Rectangle(0, 0, 48, 48), new Point(0, 0), null, null, true);
		var glow:GlowFilter = new GlowFilter(color, 0.9, 16.0, 16.0, 1.6, 1, false, false);
		tmp.applyFilter(tmp, glowRect, new Point(0, 0), glow);
		glowSprite = tmp;
		glow = null;
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
	
	public function updateIcon() {
		setIcon(icon);
	}

	public function setIcon(Icon:BitmapData) {
		icon = new BitmapData(Icon.width, Icon.height, true, 0x0);
		icon.copyPixels(Icon, new Rectangle(0, 0, Icon.width, Icon.height), new Point(0,0), null, null, true);
		var X:Int = Std.int((width / 2) - (icon.width / 2));
		var Y:Int = Std.int((height / 2) - (icon.height / 2));
		var temp:BitmapData = new BitmapData(background.width, background.height, true, 0x0);
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
	}

	/**
	 * Sets this object as the CellObj of the target inventory cell, and places this object within that cell.
	 **/
	public function setInventoryCell(Cell:Int) {		
		if (cellSpell) {
			CqRegistery.player.equippedSpells[cellIndex] = null;
			_dlg.dlgSpellGrid.forceClearCharge(cellIndex);
		}
		
		_dlg.dlgSpellGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;
		_dlg.add(this);

		cellIndex = Cell;
		setPos(_dlg.dlgInvGrid.getCellItemPos(Cell));
		_dlg.dlgInvGrid.setCellObj(Cell, this);
		cellEquip = false;
		cellSpell = false;
		cellPotion = false;
	}

	function getEquipmentCell(Index:Int):CqEquipmentCell {
		return cast(_dlg.dlgEqGrid.cells[Index], CqEquipmentCell);
	}
	
	function getSpellCell(Index:Int):CqSpellCell {
		return cast(_dlg.dlgSpellGrid.cells[Index], CqSpellCell);
	}
	
	/**
	 * Sets this object as the CellObj of the target equipment cell, and places this object within that cell.
	 **/
	public function setEquipmentCell(Cell:Int):Bool {
		_dlg.dlgSpellGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;
		_dlg.add(this);
		var cellRef:CqEquipmentCell = cast(_dlg.dlgEqGrid.cells[Cell], CqEquipmentCell);
		if ( cellRef.equipSlot != this.item.equipSlot ) {
			Cell = _dlg.dlgInvGrid.getOpenCellIndex();
			setInventoryCell(Cell);
			return false;
		}
		cellRef.icon.visible = false;
		cellIndex = Cell;
		setPos(_dlg.dlgEqGrid.getCellItemPos(Cell));
		_dlg.dlgEqGrid.setCellObj(Cell, this);
		cellEquip = true;
		cellSpell = false;
		cellPotion = false;
		return true;
	}

	/**
	 * Sets this object as the CellObj of the target spell cell, and places this object within that cell.
	 **/
	public function setSpellCell(Cell:Int):Bool {
		if (cellSpell) {
			// if it was already in a different spell cell before moving to the new spell cell
			CqRegistery.player.equippedSpells[cellIndex] = null;
		}
		
		_dlg.dlgSpellGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;
		if (_dlg.dlgSpellGrid.cells.length <= Cell)
			return false;
		
		if ( cast(_dlg.dlgSpellGrid.cells[Cell], CqEquipmentCell).equipSlot != this.item.equipSlot ) {
			Cell = _dlg.dlgInvGrid.getOpenCellIndex();
			setInventoryCell(Cell);
			return false;
		}

		_dlg.dlgSpellGrid.add(this);
		cellIndex = Cell;
		setPos(_dlg.dlgSpellGrid.getCellItemPos(Cell));
		_dlg.dlgSpellGrid.setCellObj(Cell, this);
		cellSpell = true;
		cellEquip = false;
		cellPotion = false;
		
		CqRegistery.player.equippedSpells[cellIndex] = cast(this.item,CqSpell);
		
		return true;
	}

	/**
	 * Sets this object as the CellObj of the target potion cell, and places this object within that cell.
	 **/
	public function setPotionCell(Cell:Int):Bool {
		_dlg.dlgPotionGrid.remove(this);
		_dlg.remove(this);
		zIndex = idleZIndex;

		if ( cast(_dlg.dlgPotionGrid.cells[Cell], CqEquipmentCell).equipSlot != this.item.equipSlot ) {
			Cell = _dlg.dlgInvGrid.getOpenCellIndex();
			setInventoryCell(Cell);
			return false;
		}

		_dlg.dlgPotionGrid.add(this);
		cellIndex = Cell;
		setPos(_dlg.dlgPotionGrid.getCellItemPos(Cell));
		_dlg.dlgPotionGrid.setCellObj(Cell, this);
		cellSpell = false;
		cellEquip = false;
		cellPotion = true;
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
		if ( !Std.is(GameUI.currentPanel,CqInventoryDialog) || !exists || !visible || !active || !dragEnabled) 
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
			setSelected(true);
		}
	}

	private override function onDragMouseUp(event:MouseEvent) {
		if ( !exists || !visible || !active || !dragEnabled || !Std.is(GameUI.currentPanel,CqInventoryDialog) || HxlGraphics.mouse.dragSprite != this ) 
			return;
		super.onDragMouseUp(event);
		if ( !isDragging ) {
			event.stopPropagation();
		}
	}

	override function dragStart() {
		if (cellEquip) {
			var cellRef:CqEquipmentCell = cast(_dlg.dlgEqGrid.cells[cellIndex], CqEquipmentCell);
			cellRef.icon.visible = true;
		}
		
		//if its moved from an spell cell, make it not clear charge after dragging stops
		if (item.equipSlot == CqEquipSlot.SPELL) {
			if (cellSpell)
				clearCharge = false;
			else
				clearCharge = true;
		}
		
		_dlg.remove(this);
		_dlg.dlgSpellGrid.remove(this);
		_dlg.dlgPotionGrid.remove(this);
		zIndex = 400;
		_dlg.add(this);
		_dlg.dlgEqGrid.onItemDrag(this.item);
		_dlg.dlgSpellGrid.onItemDrag(this.item);
		_dlg.dlgPotionGrid.onItemDrag(this.item);
		super.dragStart();
	}
	
	// If the user was hovering an eligable drop target, act on it
	override function dragStop() {
		//collect info
		var dragStopCell:CqInventoryCell = CqInventoryCell.highlightedCell;
		var dragStopCell_class:Dynamic = Type.getClass(dragStopCell);
		var dragStopCell_type:String = (cellEquip?"equip":"") + (cellSpell?"spell":"") + (cellPotion?"potion":"");
		
		
		if ( dragStopCell != null ) {
			
			var dragStop_cell_obj:CqInventoryItem = dragStopCell.getCellObj();	
			if ( dragStop_cell_obj != null )
			{
				if(dragStop_cell_obj == this)
					stopdrag_gotoSameCell(dragStopCell_class, dragStopCell_type, dragStopCell);
				else
					stopdrag_gotoOccupiedCell(dragStopCell_class, dragStopCell_type, dragStopCell,dragStop_cell_obj);
			}else
				stopdrag_gotoEmptyCell(dragStopCell_class, dragStopCell_type, dragStopCell);
			
		} else {
			stopdrag_revert();
		}
		_dlg.dlgEqGrid.onItemDragStop();
		_dlg.dlgSpellGrid.onItemDragStop();
		_dlg.dlgPotionGrid.onItemDragStop();
		super.dragStop();
	}
	
	//when user drops item in same place he picked it up
	private function stopdrag_gotoSameCell(dragStopCell_class:Dynamic, dragStopCell_type:String, dragStopCell:CqInventoryCell):Void 
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
	private function stopdrag_gotoOccupiedCell(dragStopCell_class:Dynamic, dragStopCell_type:String, dragStopCell:CqInventoryCell,dragStop_cell_obj:CqInventoryItem) {
		// There was already an item in the target cell, switch places with it
		switch(dragStopCell_type) {
			case "equip":
				// Unequipping current item (?)
			case "spell":
				// Moving the other item into a spell cell
				dragStop_cell_obj.popup.setText(dragStop_cell_obj.item.fullName+"\n[hotkey " + (cellIndex + 1) + "]");
				
				dragStop_cell_obj.setSpellCell(cellIndex);
				var spellBtn = cast(getSpellCell(cellIndex), CqSpellCell).btn;
				if (dragStop_cell_obj != this)
					GameUI.instance.updateCharge(spellBtn);
			case "potion":
				// Moving the other item into a potion cell
				dragStop_cell_obj.popup.setText(dragStop_cell_obj.item.fullName+"\n[hotkey " + ((cellIndex>3)?cellIndex-4:cellIndex + 6) + "]");
				dragStop_cell_obj.setPotionCell(cellIndex);
			default:
				dragStop_cell_obj.popup.setText(dragStop_cell_obj.item.fullName);
				// Moving the other item into an inventory cell
				dragStop_cell_obj.setInventoryCell(cellIndex);
		}
		
		if (item.equipSlot != CqEquipSlot.POTION &&  item.equipSlot != CqEquipSlot.SPELL) {
			if (cellEquip || dragStop_cell_obj.cellEquip) {
				if (dragStop_cell_obj.item != item)
					CqRegistery.player.unequipItem(item);
				
				CqRegistery.player.equipItem(dragStop_cell_obj.item);
				dragStop_cell_obj.setEquipmentCell(cellIndex);
			}
		}
		
		// moving from inv to equip:
		switch(dragStopCell_class) {
			case CqSpellCell:
				// Moving this item into a spell cell
				setSpellCell(dragStopCell.cellIndex);
				popup.setText(item.fullName+"\n[hotkey " + (cellIndex + 1) + "]");
			case CqPotionCell:
				// Moving this item into a potion cell
				setPotionCell(dragStopCell.cellIndex);
				popup.setText(item.fullName+"\n[hotkey " + ((cellIndex>3)?cellIndex-4:cellIndex + 6) + "]");
			case CqEquipmentCell:
				// Moving this item into an equipment cell
				if (dragStop_cell_obj != this) {
					CqRegistery.player.unequipItem(dragStop_cell_obj.item);
					CqRegistery.player.equipItem(this.item);
				}
				//move new to other's place
				setEquipmentCell(dragStopCell.cellIndex);
				
			case CqInventoryCell:
				// Moving this item into an inventory cell
				popup.setText(item.fullName);
				setInventoryCell(dragStopCell.cellIndex);
			default:
				//unknown cell class
		}
		cellIndex = dragStopCell.cellIndex;
	}
	
	//return to pre drag position, when item dropped on invalid area
	private function stopdrag_revert() {
		_dlg.remove(this);
		setPos(dragStartPoint);
		
		//if last cell was of type == item equipslot, means its from that dialog, so add there
		if (item.equipSlot == CqEquipSlot.POTION && cellPotion) {
			_dlg.dlgPotionGrid.add(this);
		} else if (item.equipSlot == CqEquipSlot.SPELL && cellSpell) {
			_dlg.dlgSpellGrid.add(this);
		} else {
			//else add to inv
			_dlg.dlgInvGrid.add(this);
		}
	}
	
	// when item dropped on a empty cell
	private function stopdrag_gotoEmptyCell(dragStopCell_class:Dynamic,dragStopCell_type:String,dragStopCell:CqInventoryCell) {
		switch(dragStopCell_type) {
			//where it came from
			
			case "equip":
				// Clearing out an equipment cell
				_dlg.dlgEqGrid.setCellObj(cellIndex, null);
				CqRegistery.player.unequipItem(this.item);
			case "spell":
				// Clearing out a spell cell
				var cellIndexNew = dragStopCell.cellIndex;
				var spellCell = getSpellCell(cellIndex); 
				var spellBtn = spellCell.btn;
				_dlg.dlgSpellGrid.setCellObj(cellIndex, null);
				setSpellCell(dragStopCell.cellIndex);
				GameUI.instance.updateCharge(spellBtn);
			case "potion":
				// Clearing out a potion cell
				_dlg.dlgPotionGrid.setCellObj(cellIndex, null);
			default:
				// Clearing out an inventory cell
				_dlg.dlgInvGrid.setCellObj(cellIndex, null);
		}
		
		switch(dragStopCell_class){
			case CqSpellCell:
				// Moving this item into a spell cell
				setSpellCell(dragStopCell.cellIndex);
				var spellCell = getSpellCell(dragStopCell.cellIndex); 
				var spellBtn = spellCell.btn;
				GameUI.instance.updateCharge(spellBtn);
				if (clearCharge)_dlg.dlgSpellGrid.forceClearCharge(dragStopCell.cellIndex);
				popup.setText(item.fullName+"\n[hotkey " + (cellIndex+1) + "]");
			case CqPotionCell:
				// Moving this item into a potion cell
				setPotionCell(dragStopCell.cellIndex);
				popup.setText(item.fullName+"\n[hotkey " + ((cellIndex>3)?cellIndex-4:cellIndex + 6) + "]");
			case CqEquipmentCell:
				// Moving this item into an equipment cell
				setEquipmentCell(dragStopCell.cellIndex);
				CqRegistery.player.equipItem(this.item);
			default:
				popup.setText(item.fullName);
				if ( dragStopCell.dropCell ) {
					// This item is being dropped
					CqRegistery.player.giveMoney( item.getMonetaryValue() );
					_dlg.remove(this);
					destroy();
					CqRegistery.player.removeInventory(this.item);
					_dlg.dlgEqGrid.onItemDragStop();
					_dlg.dlgSpellGrid.onItemDragStop();
					_dlg.dlgPotionGrid.onItemDragStop();
					_dlg.dlgInfo.clearInfo();
					return;
				} else {
					setInventoryCell(dragStopCell.cellIndex);
				}
		}
		cellIndex = dragStopCell.cellIndex;
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