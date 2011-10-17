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
	static var inited = false;
	static var itemArray:Array<String>;
	static function initDescriptions() {
		if (inited)
			return;
		
		if (itemArray == null)
		{
			itemArray = SpriteItems.potions;
		}
		if(Resources.descriptions==null)
			Resources.descriptions = new Hash<String>();
			Resources.descriptions.set("Healing Potion", "A small vial containing a fragrant, red salve. It restores life when applied.");
			Resources.descriptions.set("Coca-leaf Cocktail","This mysterious beverage grants great speed when quaffed.");
			Resources.descriptions.set("Elixir of the Elephant","This elixir temporarily protects the drinker's body with a thick hide.");
			Resources.descriptions.set("Elixir of the Hawk","This elixir temporarily grants ultra-human eyesight and reflexes.");
			Resources.descriptions.set("Elixir of the Lion","This elixir temporarily increases the drinker's strength immensely.");
			Resources.descriptions.set("Boots of Escape", "These finely crafted leather boots allow the wearer to run with great speed.");
			Resources.descriptions.set("Hermes' Sandals","These winged sandals are made of imperishable gold and allow the wearer to move as swiftly as any bird.");
			Resources.descriptions.set("Leather Armor","This armor is made of leather that was boiled in wax for extra toughness.");
			Resources.descriptions.set("Breastplate", "This iron breastplate offers excellent protection to vital organs without limiting mobility.");
			Resources.descriptions.set("Ring of Wisdom","This small, silver ring imbues its wearer with uncanny wisdom.");
			Resources.descriptions.set("Amulet of Enlightenment","Enlightenment permeates this simple looking amulet, granting its wearer the spirit of the gods.");
			Resources.descriptions.set("Cap of Endurance", "This steel skullcap protects the head without restricting the wearer's ability to wear fashionable hats.");
			Resources.descriptions.set("Helm of Hardiness", "This helm is crafted by dwarven smiths in the Roshaggon mines using an alloy jealously kept secret.");
			Resources.descriptions.set("Gloves of Dexterity","The swiftness of these hand gloves allows their wearer to perform faster in battle.");
			Resources.descriptions.set("Achilles' Bracer","This magical bronze bracer contains within it the great warrior's spirit.");
			Resources.descriptions.set("Short Sword", "A one handed hilt attached to a thrusting blade approximately 60cm in length.");
			Resources.descriptions.set("Long Sword","Long swords have long cruciform hilts with grips and double-edged blades over one meter long.");
			Resources.descriptions.set("Staff","A sturdy shaft of hardwood with metal tips.");
			Resources.descriptions.set("Dagger", "A double-edged blade used for stabbing or thrusting.");
			Resources.descriptions.set("Axe", "A mighty axe, good for chopping both wood and flesh.");
			Resources.descriptions.set("Hardened Battle Axe", "Crafted from the finest of metals, this axe can deal lethal slashing, cleaving and slicing blows.");
			Resources.descriptions.set("Broad Claymore", "An ancient weapon. Many bards have sung of glorious victories won with it.");
			Resources.descriptions.set("King's Golden Helm", "Made of pure gold, this helmet gives you unbreachable head protection and irresistible looks.");
			Resources.descriptions.set("Beastly Mace", "A mighty huge and spiky mace made for fast swinging and powerful rips.");
			Resources.descriptions.set("Twin Bladed Katana", "An elegant weapon for a more civilized age. It was crafted by a master blacksmith from the distant orient.");
			Resources.descriptions.set("Full Helmet of Vitality", "Originally worn by dark priests, this helmet helps you tap into energies of the full moon.");
			Resources.descriptions.set("Full Plate Armor", "A classic, well tested model of armor highly praised by knights from around the globe.");
			Resources.descriptions.set("Rogues' Cloak of Swiftness", "Made from enchanted cloth, both light and durable. Wearing this feels like touching the sky.");
			Resources.descriptions.set("Gauntlets of Sturdiness", "These decorated gauntlets are crafted skillfully and with attention to detail.");
			Resources.descriptions.set("Supernatural Amulet", "Inscribed upon this amulet are magic runes, which yield many benefits for the wearer.");
			Resources.descriptions.set("Ring of Rubies", "You sense a powerful force in this ring. It feels like life itself is flowing from it.");
			Resources.descriptions.set("Tundra Lizard Boots", "Made for the toughest of conditions, these boots give you superior mobility on every terrain.");
		
		inited = true;
	}
	
	public static function newItem(X:Float, Y:Float, type:CqItemType):CqItem {
		initDescriptions();

		var item = new CqItem(X, Y, type);
		
		var itemsFile:StatsFile = Resources.statsFiles.get( "items.txt" );
		var potionsFile:StatsFile = Resources.statsFiles.get( "potions.txt" );
		var weaponsFile:StatsFile = Resources.statsFiles.get( "weapons.txt" );

		var entry:StatsFileEntry;
		
		if ( (entry = itemsFile.getEntry( "ID", type + "" )) != null ) {
			// Reading from ITEMS.TXT.
			item.name = itemsFile.getEntryField( entry, "Name" );
			
			var slot:String = itemsFile.getEntryField( entry, "Slot" );
			item.equipSlot =  Type.createEnum( CqEquipSlot, slot );

			if ( itemsFile.getEntryField( entry, "Buff1" ) != "" )	{
				item.buffs.set(itemsFile.getEntryField( entry, "Buff1" ), itemsFile.getEntryField( entry, "Buff1Val" ));
			}
			if ( itemsFile.getEntryField( entry, "Buff2" ) != "" )	{
				item.buffs.set(itemsFile.getEntryField( entry, "Buff2" ), itemsFile.getEntryField( entry, "Buff2Val" ));
			}
		}
		else if ( (entry = weaponsFile.getEntry( "ID", type + "" )) != null )
		{
			// Reading from WEAPONS.TXT.
			item.name = weaponsFile.getEntryField( entry, "Name" );
			
			var slot:String = weaponsFile.getEntryField( entry, "Slot" );
			item.equipSlot =  Type.createEnum( CqEquipSlot, slot );

			item.damage = new Range(weaponsFile.getEntryField( entry, "DamageMin" ),
									weaponsFile.getEntryField( entry, "DamageMax" ));
			
			if ( weaponsFile.getEntryField( entry, "Buff1" ) != "" )	{
				item.buffs.set(weaponsFile.getEntryField( entry, "Buff1" ), weaponsFile.getEntryField( entry, "Buff1Val" ));
			}
			if ( weaponsFile.getEntryField( entry, "Buff2" ) != "" )	{
				item.buffs.set(weaponsFile.getEntryField( entry, "Buff2" ), weaponsFile.getEntryField( entry, "Buff2Val" ));
			}
		}
		else if ( (entry = potionsFile.getEntry( "ID", type + "" )) != null )
		{
			// Reading from POTIONS.TXT.
			item.name = potionsFile.getEntryField( entry, "Name" );
			item.equipSlot = CqEquipSlot.POTION;
			
			item.duration = potionsFile.getEntryField( entry, "Duration" );
			item.consumable = true;
			item.stackSizeMax = -1;			

			var buff:String = potionsFile.getEntryField( entry, "Buff" );
			if ( buff != "" )	{
				item.buffs.set(buff, potionsFile.getEntryField( entry, "BuffVal" ));
			}
			
			var effect:String = potionsFile.getEntryField( entry, "Effect" );
			if ( effect != "" )	{
				item.specialEffects.add(new CqSpecialEffectValue(effect, potionsFile.getEntryField( entry, "EffectVal" )));
			}
		}
		else
		{
			throw "Item type not found in items.txt, weapons.txt or potions.txt.";
		}		

		return item;
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
	public var name:String;
	public var fullName(getFullName, null):String;
	
	function getFullName():String {
		var prefix = "";
		if(isSuperb)
			prefix += "Superb ";
		if (isWondrous)
			prefix += "Wondrous ";
		if (isMagical)
			prefix += "Magical ";
			
		return prefix + name;
	}
	
	public var equipSlot:CqEquipSlot;
	public var consumable:Bool;
	public var spriteIndex:String;
	public var damage:Range;
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

	public function new(X:Float, Y:Float, type:Dynamic) {
		super(X, Y);
		var typeName:String = Type.enumConstructor(type).toLowerCase();
		zIndex = 1;
		isSuperb = false;
		isMagical = false;
		isWondrous = false;
		
		//this is a terrible, terrible work-around, but it'll do for now
		
		// fixme - new arrays created every time
		if (Std.is(this, CqSpell)) {
			loadGraphic(SpriteSpells, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			addAnimation("idle", [SpriteSpells.instance.getSpriteIndex(typeName)], 0 );
		} else if (Std.is(this, CqItem)) {
			loadGraphic(SpriteItems, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			addAnimation("idle", [SpriteItems.instance.getSpriteIndex(typeName)], 0 );
		} else {
			//BOOM!
			throw "Invalid Item/Spell type provided";
		}
	
		consumable = false;
		spriteIndex = typeName;
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
		return true;
	}
	/**
	 * <1 other is worse 1 == equal, >1 other is better
	 * */
	public function compareTo(other:CqItem):Float {
		if (other.equipSlot != equipSlot)
			return 0.0;
			
		
		var preference:Float = 0.0;
		var sumBuffsThis:Float  = HxlUtil.sumHashInt(buffs);
		var sumBuffsOther:Float = HxlUtil.sumHashInt(other.buffs);
		
		var dmgAvgThis:Float  = (damage.start + damage.end)/2;
		var dmgAvgOther:Float = (other.damage.start + other.damage.end)/2;
		if (dmgAvgThis > dmgAvgOther)
			sumBuffsThis += dmgAvgThis-dmgAvgOther;
		else if(dmgAvgThis < dmgAvgOther)
			sumBuffsOther+=dmgAvgOther-dmgAvgThis;
		//do nothing if damage is equal
		if ( sumBuffsOther == 0) sumBuffsOther = 0.1;
		preference = sumBuffsThis / sumBuffsOther;
		
		return preference;
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
		super(X, Y, CqItemType.CHEST);
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
		} else {
			//set up equipment array. means filter out potions from the item enum.
			if (equipment == null) {
				var li:Array<String> 			= Type.getEnumConstructs(CqItemType);
				var upperCasePotions			= Lambda.map(SpriteItems.potions, function (a:String):String { return a.toUpperCase(); });
				var isNotPotion:String->Bool	= function (a:String):Bool { return (!Lambda.has(upperCasePotions, a)); }
				CqChest.equipment				= Lambda.array(Lambda.filter(li, isNotPotion));
				CqChest.equipment.shift();
			}
			
			if (Math.random() < Configuration.betterItemChance)
				level = level + 1;
				
			var itemsPerLevelVariety:Int = 6;
			var itemsPerLevelShift:Int = 3;
			
			var cap:Int = itemsPerLevelVariety+((level) * itemsPerLevelShift);		
			if (cap >= equipment.length)//make last level items have same variety
				cap = equipment.length-1;
			var minimum:Int = cap - itemsPerLevelVariety;

			var itemIndex:Int = minimum + Math.floor( Math.random() * cap);
			//back to bounds, just in case
			if (itemIndex >= equipment.length)
				itemIndex = equipment.length - 1;
			if (itemIndex < 0)
				itemIndex = 0;
				
			typeName	= equipment[itemIndex];
		}
		
		var item = CqLootFactory.newItem(x, y, Type.createEnum(CqItemType,  typeName));
		
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
		
		// remove chest
		Registery.level.removeLootFromLevel(state, this);
	}
}

enum CqItemType {
	CHEST;//chest constructor must be left on top.
	
	PURPLE_POTION;
	GREEN_POTION;
	BLUE_POTION;
	YELLOW_POTION;
	RED_POTION;
	//
	LEATHER_ARMOR;
	DAGGER;
	BOOTS;
	GLOVE;
	CAP;
	SHORT_SWORD;
	RING;
	STAFF;
	//
	BRESTPLATE;
	LONG_SWORD;
	WINGED_SANDLES;
	BRACELET;
	HELM;
	AMULET;
	AXE;
	//
	CLOAK;
	MACE;
	BATTLE_AXE;
	GAUNTLET;
	FULL_HELM;
	GEMMED_AMULET;
	//
	FULL_PLATE_MAIL;
	CLAYMORE;
	TUNDRA_BOOTS;
	BROAD_SWORD;
	GOLDEN_HELM;
	GEMMED_RING;
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
