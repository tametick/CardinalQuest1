package cq;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;
import cq.ui.inventory.CqInventoryItem;

import data.Configuration;
import data.Resources;
import data.Registery;
import data.StatsFile;

import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;

import world.Loot;
import world.GameObject;

import data.Configuration;
import cq.CqResources;
import cq.CqWorld;
import cq.CqGraphicKey;

import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

class CqItemBMPData extends BitmapData{}

class CqSpecialEffectValue {
	public var name:String;
	public var value:Dynamic;
	public function new(name:String, ?value:Dynamic=null) {
		this.name = name;
		this.value = value;
	}
}

class CqLootFactory {
	static function completeItem( _item:CqItem, _entry:StatsFileEntry ) {
		_item.name = Resources.getString( _entry.getField( "ID" ) );
		
		var slot:String = _entry.getField( "Slot" );
		_item.equipSlot =  Type.createEnum( CqEquipSlot, slot );

		_item.damage = new Range(_entry.getField( "DamageMin" ),
								 _entry.getField( "DamageMax" ));
		
		if ( _entry.getField( "Buff1" ) != "" )	{
			_item.buffs.set(_entry.getField( "Buff1" ), _entry.getField( "Buff1Val" ));
		}
		if ( _entry.getField( "Buff2" ) != "" )	{
			_item.buffs.set(_entry.getField( "Buff2" ), _entry.getField( "Buff2Val" ));
		}
	}
	
	static function completePotion( _item:CqItem, _entry:StatsFileEntry ) {
		_item.name = Resources.getString( _entry.getField( "ID" ) );
		_item.equipSlot = CqEquipSlot.POTION;
		
		_item.duration = _entry.getField( "Duration" );
		_item.consumable = true;
		_item.stackSizeMax = -1;			

		var buff:String = _entry.getField( "Buff" );
		if ( buff != "" )	{
			_item.buffs.set(buff, _entry.getField( "BuffVal" ));
		}
		
		var effect:String = _entry.getField( "Effect" );
		if ( effect != "" )	{
			_item.specialEffects.add(new CqSpecialEffectValue(effect, _entry.getField( "EffectVal" )));
		}
	}
	
	public static function newItem(X:Float, Y:Float, id:String):CqItem {
		var itemsFile:StatsFile = Resources.statsFiles.get( "items.txt" );
		var potionsFile:StatsFile = Resources.statsFiles.get( "potions.txt" );

		var item:CqItem = null;
		var entry:StatsFileEntry;
		
		if ( (entry = itemsFile.getEntry( "ID", id )) != null )
		{
			// Reading from ITEMS.TXT.
			item = new CqItem(X, Y, id, entry.getField( "Sprite" ));
			completeItem( item, entry );
		}
		else if ( (entry = potionsFile.getEntry( "ID", id )) != null )
		{
			// Reading from POTIONS.TXT.
			item = new CqItem(X, Y, id, entry.getField( "Sprite" ));
			completePotion( item, entry );
		}

		return item;
	}
	
	public static function newRandomItem(X:Float, Y:Float, level:Int):CqItem {
		// Search through items.txt for appropriate items.
		var itemsFile:StatsFile = Resources.statsFiles.get( "items.txt" );
		
		var entry:StatsFileEntry = null;
		var weightSoFar:Int = 0;
		for ( m in itemsFile ) {
			if ( m.getField( "LevelMin" ) <= level+1 && m.getField( "LevelMax" ) >= level+1 ) {
				var weight = m.getField( "Weight" );
				if ( Math.random() > (weightSoFar / (weightSoFar + weight)) ) {
					entry = m;
				}
				weightSoFar += weight;
			}
		}

		if ( entry != null ) {
			var item = new CqItem(X, Y, entry.getField( "ID" ), entry.getField( "Sprite" ) );
			
			completeItem( item, entry );
			
			return item;
		} else {
			throw( "Failed to generate random item!" );
		}
	}
	
	public static function enchantItem(Item:CqItem, DungeonLevel:Int) {
		if (Item.equipSlot == CqEquipSlot.SPELL || Item.equipSlot == CqEquipSlot.POTION)
			// sorry, not enchanting potions & spells!
			return;
		switch(DungeonLevel) {
			case 0, 1:
				Item.isSuperb = true;
				Item.setGlow(true);
				Item.customGlow(0x206CDF);
			case 2, 3:
				Item.isMagical = true;
				Item.setGlow(true);
				Item.customGlow(0x3CDA25);
			case 4, 5:
				Item.isSuperb = true;
				Item.isMagical = true;
				Item.setGlow(true);
				Item.customGlow(0x1FE0D7);
			case 6, 7, 8: // 8 is for out of depth items on level 7
				Item.setGlow(true);
				Item.customGlow(0xE7A918);
				Item.isSuperb = true;
				Item.isWondrous = true;
		}
		if (Item.isSuperb) {
			//Item.name = "Superb " + Item.name;
			switch(Item.equipSlot) {
				case CqEquipSlot.ARMOR:
					Item.buffs.set("defense", Item.buffs.get("defense") + 1);
				case CqEquipSlot.GLOVES:
					Item.buffs.set("attack", Item.buffs.get("attack") + 1);
				case CqEquipSlot.HAT:
					Item.buffs.set("life", Item.buffs.get("life") + 1);
				case CqEquipSlot.JEWELRY:
					Item.buffs.set("spirit", Item.buffs.get("spirit") + 1);
				case CqEquipSlot.SHOES:
					Item.buffs.set("speed", Item.buffs.get("speed") + 1);
				case CqEquipSlot.WEAPON:
					Item.damage.start += 1;
					Item.damage.end += 1;
				default:
			}
		}
		
		if (Item.isMagical || Item.isWondrous) {
			var buffs = new Array();
			buffs.push("defense");
			buffs.push("attack");
			buffs.push("life");
			buffs.push("spirit");
			buffs.push("speed");
			
			switch(Item.equipSlot) {
				case CqEquipSlot.ARMOR:
					buffs.remove("defense");
				case CqEquipSlot.GLOVES:
					buffs.remove("attack");
				case CqEquipSlot.HAT:
					buffs.remove("life");
				case CqEquipSlot.JEWELRY:
					buffs.remove("spirit");
				case CqEquipSlot.SHOES:
					buffs.remove("speed");
				default:
			}
			
			var extraBuff = HxlUtil.getRandomElement(buffs);
			if (Item.isMagical) {
				//Item.name = "Magical " + Item.name;
				Item.buffs.set(extraBuff, Item.buffs.get(extraBuff) + 1);
			} else {// isWondrous
				//Item.name = "Wondrous " + Item.name;
				Item.buffs.set(extraBuff, Item.buffs.get(extraBuff) + 2);
			}
		}
	}
}

class CqItem extends GameObjectImpl, implements Loot {
	public var id:String;
	public var name:String;
	public var fullName(getFullName, null):String;
	
	function getFullName():String {
		var prefix = "";
		if(isSuperb)
			prefix += Resources.getString( "PREFIX_SUPERB" ) + " ";
		if (isWondrous)
			prefix += Resources.getString( "PREFIX_WONDROUS" ) + " ";
		if (isMagical)
			prefix += Resources.getString( "PREFIX_MAGICAL" ) + " ";
			
		return prefix + name;
	}
	
	public var equipSlot:CqEquipSlot;
	public var consumable:Bool;
	public var spriteIndex:String;
	public var damage:Range;
	public var lastDamage:Int;
	// changes to basic abilities (attack, defense, speed, spirit)
	public var buffs:Hash<Int>;
	// special effects beyond changes to basic abilities
	public var specialEffects:List<CqSpecialEffectValue>;
	
	public var duration:Int;
	public var stackSize:Int;
	public var stackSizeMax:Int;

	var isGlowing:Bool;
	var glowSpriteKey:CqGraphicKey;
	var glowSprite:CqItemBMPData;
	var glowRect:Rectangle;
	
	public var isSuperb:Bool;
	public var isMagical:Bool;
	public var isWondrous:Bool;
	
	public var uiItem:CqInventoryItem;
	
	public var isEnchanted(getIsEnchanted, null):Bool;
	
	function getIsEnchanted() {
		return isMagical || isSuperb || isWondrous;
	}

	public function new(X:Float, Y:Float, _id:String, sprite:String) {
		super(X, Y);
		
		this.id = _id;
		spriteIndex = sprite.toLowerCase();
		
		zIndex = 1;
		isSuperb = false;
		isMagical = false;
		isWondrous = false;
		
		//this is a terrible, terrible work-around, but it'll do for now
		
		// fixme - new arrays created every time
		if (Std.is(this, CqSpell)) {
			loadGraphic(SpriteSpells, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			addAnimation("idle", [SpriteSpells.instance.getSpriteIndex(spriteIndex)], 0 );
		} else if (Std.is(this, CqItem)) {
			loadGraphic(SpriteItems, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			addAnimation("idle", [SpriteItems.instance.getSpriteIndex(spriteIndex)], 0 );
		} else {
			//BOOM!
			throw "Invalid Item/Spell type provided";
		}
	
		consumable = false;
		damage = new Range(0, 0);
		buffs = new Hash<Int>();
		specialEffects = new List<CqSpecialEffectValue>();
		duration = -1;
		play("idle");
		stackSize = 1;
		stackSizeMax = 1;

		isGlowing = false;
//		glowSpriteKey = CqGraphicKey.ItemGlow(typeName);
		//TODO: move to game ui, to be with the rest of graphic cache creation
		glowRect = new Rectangle(0, 0, 48, 48);
/*		if ( GraphicCache.checkBitmapCache(glowSpriteKey) ) {
			glowSprite = GraphicCache.getBitmap(glowSpriteKey);
		} else {*/
			var tmp:CqItemBMPData = new CqItemBMPData(48, 48, true, 0x0);
			tmp.copyPixels(getFramePixels(), new Rectangle(0, 0, 32, 32), new Point(8, 8), null, null, true);
			var glow:GlowFilter = new GlowFilter(0xffea00, 0.9, 16.0, 16.0, 1.6, 1, false, false);
			tmp.applyFilter(tmp, glowRect, new Point(0, 0), glow);
			//GraphicCache.addBitmapData(tmp, glowSpriteKey);
			glowSprite = tmp;
			glow = null;
			tmp = null;
		//}
	}
	public function customGlow(color:Int) {
		var tmp:CqItemBMPData = new CqItemBMPData(48, 48, true, 0x0);
		tmp.copyPixels(getFramePixels(), new Rectangle(0, 0, 32, 32), new Point(8, 8), null, null, true);
		var glow:GlowFilter = new GlowFilter(color, 0.9, 16.0, 16.0, 1.6, 1, false, false);
		tmp.applyFilter(tmp, glowRect, new Point(0, 0), glow);
		//GraphicCache.addBitmapData(tmp, glowSpriteKey);
		glowSprite = tmp;
		glow = null;
		tmp = null;
	}
	public function setGlow(Toggle:Bool) {
		isGlowing = Toggle;
	}

	override function renderSprite() {
		if ( isGlowing )
			renderGlow();
		else
			super.renderSprite();
	}
	
	function renderGlow() {
		getScreenXY(_point);
		_flashPoint.x = _point.x - 8;
		_flashPoint.y = _point.y - 8;
		HxlGraphics.buffer.copyPixels(glowSprite, glowRect, _flashPoint, null, null, true);
	}
	
	public override function destroy() {
		super.destroy();
		if(glowSprite!=null){
			glowSprite.dispose();
			glowSprite = null;
		}
		
		buffs = null;
		damage = null;
		equipSlot = null;
			
		if(specialEffects !=null){
			specialEffects.clear();
			specialEffects = null;
		}
		
		uiItem = null;
		glowRect = null;
	}
	var oldX:Float;
	var oldY:Float;
	public function doPickupEffect() {
		HxlGraphics.state.add(this);
		setGlow(false);
		oldX = x;
		oldY = y;
		Actuate.update(pickupTweenUpdate, 1.0, [x, y, 1.0], [x,y-48, 0.0]).onComplete(pickupTweenOnComplete).ease(Cubic.easeOut); 
	}
	function pickupTweenUpdate(arg0:Dynamic,arg1:Dynamic,arg2:Dynamic) {
			if (arg0 != null)
				x = Math.round(cast(arg0,Float));
			if (arg1 != null)
				y = Math.round(cast(arg1,Float));
			if (arg2 != null)
				alpha = cast(arg2,Float);
	}
	function pickupTweenOnComplete() {
			x = oldX;
			y = oldY;
			HxlGraphics.state.remove(this);
			// need to destory when removing from level and into inv?
			//destroy();
	}
	public function equalTo(other:CqItem):Bool {
		if ( other.buffs.get( "attack" ) == buffs.get( "attack" )
		  && other.buffs.get( "defense" ) == buffs.get( "defense" )
		  && other.buffs.get( "speed" ) == buffs.get( "speed" )
		  && other.buffs.get( "spirit" ) == buffs.get( "spirit" )
		  && other.buffs.get( "life" ) == buffs.get( "life" )
		  && other.damage.start == damage.start
		  && other.damage.end == damage.end )
		{
			return true;
		}
		
		return false;
		
		/*
		if (isSuperb != other.isSuperb || isWondrous != other.isWondrous || isMagical != other.isMagical)
			return false;
		if (spriteIndex != other.spriteIndex)
			return false;
		var itr:Iterator<String> = buffs.keys();
		while (itr.hasNext())
		{
			var key:String = itr.next();
			if (other.buffs.get(key) != buffs.get(key))
				return false;
		}
		return true;*/
	}
	
	public function makesRedundant(other:CqItem):Bool {
		if ( other.buffs.get( "attack" ) > buffs.get( "attack" )
		  || other.buffs.get( "defense" ) > buffs.get( "defense" )
		  || other.buffs.get( "speed" ) > buffs.get( "speed" )
		  || other.buffs.get( "spirit" ) > buffs.get( "spirit" )
		  || other.buffs.get( "life" ) > buffs.get( "life" )
		  || other.damage.start + other.damage.end > damage.start + damage.end )
		{
			return false;
		}

		if ( equalTo(other) ) {
			return false;
		}
		
		return true;
	}
	
	public function getMonetaryValue():Int {
		var sumBuffsThis:Float  = HxlUtil.sumHashInt(buffs);
		var dmgAvgThis:Float  = (damage.start + damage.end)/2;
		return Math.ceil((sumBuffsThis + dmgAvgThis) / 2);
	}
	
}

/**
 * Chests are encountered in the dungeon and once detroyed drop a random item
 */
class CqChest extends CqItem {
	static var equipment:Array<String>;
	var onBust:List<Dynamic>;

	public function new(X:Float, Y:Float) {
		super(X, Y, "CHEST", "CHEST");
		onBust = new List();
		visible = false;
	}
	
	public function addOnBust(Callback:Dynamic) {
		onBust.add(Callback);
	}

	public function bust(state:HxlState,level:Int) {

		for ( Callback in onBust ) 
			Callback(this);

		// create random item
		var typeName:String = null;
		
		// chance of getting a potion
		if (Math.random() < Configuration.dropPotionChance){
			typeName = HxlUtil.getRandomElement(SpriteItems.potions).toUpperCase();
			var item = CqLootFactory.newItem(x, y, typeName);
			
			// add item to level
			Registery.level.addLootToLevel(state, item);
		} else {
			// Get a random level-appropriate item.
			if (Math.random() < Configuration.betterItemChance)
				level = level + 1;
			
			var item = CqLootFactory.newRandomItem(x, y, level);
			
			if (Math.random() < Configuration.EnchantItemChance) {
				// 10% chance of magical item
				if (Math.random() < Configuration.BetterEnchantItemChance){
					// 1% chance of that item being out-of-depth
					CqLootFactory.enchantItem(item, Registery.level.index + 1);
				} else {
					CqLootFactory.enchantItem(item, Registery.level.index);
				}
			}
			
			// add item to level
			Registery.level.addLootToLevel(state, item);
		}
		
		// remove chest
		Registery.level.removeLootFromLevel(state, this);			
	}
}

enum CqEquipSlot {
	SHOES;
	ARMOR;
	JEWELRY;
	HAT;
	GLOVES;
	WEAPON;
	SPELL;
	POTION;
}
