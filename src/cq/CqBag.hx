package cq;

import cq.CqItem;
import cq.CqSpell;
import cq.GameUI;
import cq.ui.bag.BagGrid;
import haxel.HxlSprite;
import haxel.HxlSpriteSheet;
import haxel.HxlUtil;

import data.Resources;
import data.Registery; // doesn't really need this -- easy to factor out
import data.SoundEffectsManager;
import cq.CqResources;


enum BagGrantResult {
	SUCCEEDED;
	SOLD;
	NO_SPACE;
}

class CqBag {
	var slots:Array<CqItemSlot>; // never make this public
	
	public function new()  {
		slots = [];
	}
	
	// grant returns TRUE if the item has been accepted (equipped, stowed in inventory, or cashed out for money)
	// and FALSE if it must remain on the floor
	public function grant(item:CqItem):BagGrantResult {
		// try to stack it, first, with a completely identical item (this applies only to potions at the moment)
		if (item.stackSizeMax != 1) {
			for (slot in slots) {
				if (slot.stackItem(item)) {
					return BagGrantResult.SUCCEEDED;
				}
			}
		}
		
		// try to find an item that would make the new one useless; if one exists, just trash the new item
		// (this will need to be updated to handle multiple equip slots of the desired type, of course)
		if (item.equipSlot != SPELL && item.equipSlot != POTION) {
			// yes, it's very awkward to do this with three separate loops, but notice that it lets us prioritize the sequence
			// in which these messages come up
			
			// (note that we should be looking for more than one like this if we have more than one slot -- easy enough?)
			
			for (i in items(item.equipSlot, false)) {
				if (i.equalTo(item)) {
					// exactly the same as one we already have!
					if ( i.name == item.name ) {
						GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_DUPLICATE" ));
					} else {
						GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_KEEP1" ) + i.name + Resources.getString( "NOTIFY_GET_KEEP2" ));
					}
					
					giveMoney(item);
					
					return BagGrantResult.SOLD;
				}
			}
			
			for (i in items(item.equipSlot, true)) {
				if (i.makesRedundant(item)) {
					// this old item is absolutely better than the new one!
					if ( i.name == item.name ) {
						GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_KEEP1" ) + i.name + Resources.getString( "NOTIFY_GET_KEEP2" ));
					} else {
						GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_SELLNEW1" ) + " " + i.name + Resources.getString( "NOTIFY_GET_SELLNEW2" ) );
					}
					giveMoney(item);
					
					return BagGrantResult.SOLD;
				}
			}
					
			for (i in items(item.equipSlot, false)) {
				if (i.makesRedundant(item)) {
					GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_REDUNDANT" ), 0xBFE137);
					giveMoney(item);
					
					return BagGrantResult.SOLD;
				}
			}
		}
		
		// well, it's a distinct new item and we need a place to put it; start by finding a slot with no item (or an item
		// that is worse than the new item and that is the worst item in any equivalent slot)
		
		var worstSlot:CqItemSlot = null;
		for (slot in slots) {
			if (slot.equipmentType == item.equipSlot) {
				if (slot.item == null)
				{
					worstSlot = slot;
					break;
				}
				else if (item.equipSlot != SPELL && item.equipSlot != POTION && shouldPreferItem(slot.item, item)) {
					if (worstSlot == null || shouldPreferItem(slot.item, worstSlot.item)) {
						worstSlot = slot;
					}
				}
			}
		}
				
		if (worstSlot != null) {
			// we found somewhere to equip it, so let's put it there and explain why.
			
			// start by showing the player just what is changing in terms of buffs:
			if ( item.equipSlot == WEAPON ) {
				CqActor.showWeaponDamage(Registery.player, item.damage);
			}
			
			if (item.equipSlot != SPELL && item.equipSlot != POTION) {
				var oldBuffs:Hash<Int> = worstSlot.item != null ? worstSlot.item.buffs : null;
				if (oldBuffs != null) {
					for (buff in oldBuffs.keys()) {
						var delta:Int = item.buffs.get(buff) - oldBuffs.get(buff);
						if (delta != 0) {
							CqActor.showBuff(Registery.player, delta, buff);
						}
					}
				}
				for (buff in item.buffs.keys()) {
					if (oldBuffs == null || !oldBuffs.exists(buff)) {
						CqActor.showBuff(Registery.player, item.buffs.get(buff), buff);
					}
				}
			}
			
			// now explain why we took this new item
			if (worstSlot.item == null) {
				// the trivial case -- we put it here because we didn't have anything
				if (item.equipSlot != SPELL && item.equipSlot != POTION) {
					GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_FIRST" ), 0xBFE137);
				}
				
				if (item.equipSlot == SPELL) {
					SoundEffectsManager.play(SpellEquipped);
				}
				
				worstSlot.item = item;
				return BagGrantResult.SUCCEEDED;
			} else {
				// the complicated case -- we're replacing some old equipment
				if (item.makesRedundant(worstSlot.item)) {
					var oldItem = worstSlot.item;
					worstSlot.item = item;
					
					GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_SELLOLD1" ) + " " + oldItem.name + Resources.getString( "NOTIFY_GET_SELLOLD2" ), 0xBFE137);
					giveMoney(oldItem);
					oldItem.destroy();
					return BagGrantResult.SUCCEEDED;
				} else {
					// it's not strictly better, so we'd better see if we actually have somewhere to put the old one before switching
					for (slot in slots) {
						// check whether it's an empty backpack cell
						if (slot.equipmentType == null && slot.item == null) {
							var oldItem = worstSlot.item;
							worstSlot.item = item;
							slot.item = oldItem;
							
							GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_STASHOLD1" ) + " " + oldItem.name + Resources.getString( "NOTIFY_GET_STASHOLD2" ), 0xBFE137);
							return BagGrantResult.SUCCEEDED;
						}
					}
					
					// we didn't find anywhere to put the old one, so we can't equip the new one -- I guess we could try to find something else to trash or drop,
					// but let's just complain (yes, we've already put up the buffs -- we could scan first instead)
					
					return BagGrantResult.NO_SPACE;
				}
			}
		}

		// fine.  put it in the backpack, then.
		for (slot in slots) {
			// check whether it's an empty backpack cell
			if (slot.equipmentType == null && slot.item == null) {
				slot.item = item;

				if (item.equipSlot == SPELL ) {
					slot.item.inventoryProxy.setChargeArcVisible( false );
					GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_STASHSPELL1" ) + " " + item.name + Resources.getString( "NOTIFY_GET_STASHSPELL2" ), 0xBFE137);
				} else {
					GameUI.showTextNotification(Resources.getString( "NOTIFY_GET_STASHNEW1" ) + " " + item.name + Resources.getString( "NOTIFY_GET_STASHNEW2" ), 0xBFE137);
				}
				return BagGrantResult.SUCCEEDED;
			}
		}		
		
		// nowhere to put it
		return BagGrantResult.NO_SPACE;
	}
		
	
	private function shouldPreferItem(oldItem:CqItem, newItem:CqItem):Bool {
		if (newItem == null) {
			return false;
		} else if (oldItem == null) {
			return true;
		} else {
			return Registery.player.valueItem(newItem) > Registery.player.valueItem(oldItem);
		}
	}
	
	public function giveMoney(item:CqItem) {
		Registery.player.giveMoney(item.monetaryValue);
	}
		
	public function grantIntrinsic(getThisItem:CqItem) {
		slots.push(CqItemSlot.newIntrinsicSlot(this, getThisItem));
	}
	
	public function addSlot(?uiElement:CqInventoryCell = null, ?equipType:CqEquipSlot = null) {
		if (uiElement == null || !uiElement.isTrashCell) {
			slots.push(new CqItemSlot(this, uiElement, equipType));
		}
	}

	public function items(?equipType:CqEquipSlot, ?equippedOnly:Bool = true):ItemIterator {
		return new ItemIterator(slots, equippedOnly, equipType);
	}
	
	public function spells(?equippedOnly:Bool = true):SpellIterator {
		return new SpellIterator(slots, equippedOnly);
	}	
	
	public function iterator() {
		return items(null, false);
	}
	
	public function equippedDamage():Range {
		var dmg:Range = new Range(0, 0);
		
		for (weapon in items(WEAPON)) {
			if (weapon.damage != null) {
				dmg.start += weapon.damage.start;
				dmg.end += weapon.damage.end;
			}
		}
		
		if (dmg.start == 0 && dmg.end == 0) {
			dmg.start = 1;
			dmg.end = 1;
		}
		
		return dmg;
	}
	
	public function equippedBuff(buff:String) {
		var buffVal:Int = 0;
		
		for (item in items()) {
			if (item.equipSlot != SPELL && item.equipSlot != POTION) {
				buffVal += item.buffs.get(buff);
			}
		}
		
		return buffVal;
	}

	/*public function equipItem(item:CqItem) {
		var equippedWeapon:CqItem;
		public var equippedSpells:Array<CqSpell>;
		var onEquip:List<Dynamic>;
		var onUnequip:List<Dynamic>;		
		
		if (CqEquipSlot.WEAPON == item.equipSlot) {
			equippedWeapon = item;
			updateSprite();
		}

		// add buffs
		if(item.buffs != null) {
			for (buff in item.buffs.keys()) {
				buffs.set(buff, buffs.get(buff) + item.buffs.get(buff));
				if (buff == "life") {
					if (Std.is(this, CqPlayer)) {
						var player = Registery.player;
						player.updatePlayerHealthBars();
					}
				}
			}
		}
	}

	public function unequipItem(item:CqItem) {
		if (item == equippedWeapon) {
			equippedWeapon = null;
			updateSprite();
		}
			
		// remove buffs
		if(item.buffs != null) {
			for (buff in item.buffs.keys()) {
				buffs.set(buff, buffs.get(buff) - item.buffs.get(buff));
				if (buff == "life") {
					if (this.hp < 1)
						this.hp = 1;
					if (Std.is(this, CqPlayer)) {
						var player = Registery.player;
						player.updatePlayerHealthBars();
					}
				}
			}
		}
	}*/
	
	public function setInventoryChargeArcsVisible( _visible:Bool ) {
		for (slot in slots) {
			if (slot.equipmentType == null && slot.item != null && slot.item.equipSlot == SPELL ) {
				slot.item.inventoryProxy.setChargeArcVisible( _visible );
			}
		}
	}
	
	public function destroy( ) { }
}

class CqItemSlot {
	public var item(default, swapItem):CqItem;
	public var equipmentType(default, null):CqEquipSlot; // bad name for this type, "CqEquipSlot"
	public var bag(default, null):CqBag;
	public var cell(default, null):CqInventoryCell;
	
	public function new(containerBag:CqBag, ?uiElement:CqInventoryCell = null, ?equipType:CqEquipSlot = null) {
		// having a visible cell is optional, since we can use these for monsters too,
		// but having an ability to decide whether to autoequip, etc., is not
		
		item = null;
		cell = uiElement;
		equipmentType = equipType;
		bag = containerBag;
		
		if (cell != null) {
			if (cell.slot != null) {
				throw "This cell has been associated with a slot already.";
			}
			cell.slot = this;
		}
	}
	
	static public function newIntrinsicSlot(containerBag:CqBag, intrinsic:CqItem):CqItemSlot {
		var slot:CqItemSlot = new CqItemSlot(containerBag, null, intrinsic.equipSlot);
		slot.item = intrinsic;
		return slot;
	}
	
	public function isEmpty( ):Bool {
		return (item == null);
	}
	
	public function isPassive():Bool {
		return equipmentType == null;
	}
	
	public function currentItem( ):CqItem {
		return item;
	}
	
	public function couldTakeItem(item:CqItem):Bool {
		if (equipmentType == null || item == null || item.equipSlot == equipmentType) {
			return true;
		} else {
			return false;
		}
	}
	
	public function hasItemOfType(equipType:CqEquipSlot) {
		return (item != null && (equipType == null || item.equipSlot == equipType));
	}
	
	public function canStackItem(stack:CqItem):Bool {
		if (item == null) {
			return false;
		}
		
		if (item.spriteIndex != stack.spriteIndex) {
			// items only stack if they look the same
			return false;
		}
		
		// now, we say we can stack if stackSizeMax is less than 1 (meaning no limit) or more than 1 (meaning there is a limit) but the sum comes out less
		return ((item.stackSizeMax < 1) || (item.stackSizeMax > 1 && item.stackSize + stack.stackSize <= item.stackSizeMax));
	}
	
	public function stackItem(stack:CqItem):Bool {
		if (!canStackItem(stack)) {
			return false;
		} else {
			item.stackSize += stack.stackSize;
			if (item.inventoryProxy != null) item.inventoryProxy.setIcon(); // a little too procedural still
			return true;
		}
	}
	
	public function prefersItem(otherItem:CqItem):Bool {
		// I don't think I want to do it this way -- I'd rather have this logic in bag than here
		if (!couldTakeItem(otherItem)) {
			return false;
		}
		
		if (item == null) {
			return true;
		}
		
		// move item comparison logic here, maybe?  (probably not)
		return false;
	}
	
	private function swapItem(otherItem:CqItem):CqItem {
		// refuse to swap if the item can't fit here or if it's already here
		if (!couldTakeItem(otherItem) || (otherItem == item)) {
			return item;
		}
		
		// remove the other item from the slot it's in, if it's in one (this invokes this same function on that cell)
		if (otherItem != null && otherItem.itemSlot != null) {
			otherItem.itemSlot.item = null;
		}
		
		var oldItem = item;
		item = otherItem;
		
		// tie up the attached items
		if (oldItem != null) {
			oldItem.itemSlot = null;
		}
		
		if (item != null) {
			item.itemSlot = this;
		}
		
		// now manage their inventoryProxies if this slot has an associated cell (this could be done through 
		// the item when we assign itemSlot, but that's an unnecessary bit of weaving at the moment and would
		// create some ugliness where the item has to check its slot's cell's parentElement somehow)
		if (cell != null) {
			if (item != null) {
				if (item.inventoryProxy == null) {
					item.inventoryProxy = new CqInventoryProxy(item);
				}
				
				item.inventoryProxy.visible = true;
				
				cell.proxy = item.inventoryProxy;
			} else {
				cell.proxy = null;
			}
		} else {
			// if this is an intrinsic but it's used up (perhaps it was a monster's consumable?) remove the slot from the bag
			// bag.removeSlot(this);
		}
		
		// Update popups text.
		if ( otherItem != null && otherItem.inventoryProxy != null ) {
			otherItem.inventoryProxy.updatePopupText();
		}
		
		return item;
	}
}

private class ItemIterator {
	var slots:Array<CqItemSlot>;
	var equipmentType:CqEquipSlot;
	var mustBeEquipped:Bool;
	var nextIndex:Int;
	
	public function new(bagslots:Array<CqItemSlot>, ?equippedOnly:Bool = true, ?equipType:CqEquipSlot = null) {
		nextIndex = 0;
		equipmentType = equipType;
		slots = bagslots;
		mustBeEquipped = equippedOnly;
	}
	
	public function hasNext():Bool {
		while (
			nextIndex < slots.length
			&& ((!slots[nextIndex].hasItemOfType(equipmentType)) || (mustBeEquipped && slots[nextIndex].isPassive()))
		) {
			nextIndex++;
		}
		
		return nextIndex < slots.length;
	}
	
	public function next():CqItem {
		if (hasNext()) {
			return slots[nextIndex++].currentItem();
		} else {
			return null;
		}
	}
}


private class SpellIterator {
	var iter:ItemIterator;
	public function new(bagslots:Array<CqItemSlot>, ?equippedOnly:Bool = true) {
		iter = new ItemIterator(bagslots, equippedOnly, SPELL);
	}
	
	public function hasNext():Bool {
		return iter.hasNext();
	}
	
	public function next():CqSpell {
		return cast(iter.next(), CqSpell);
	}
}
