package cq;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;
import haxel.GraphicCache;

import data.Configuration;
import data.Resources;
import data.Registery;

import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;

import world.Loot;
import world.GameObject;

import cq.CqConfiguration;
import cq.CqResources;
import cq.CqWorld;
import cq.CqGraphicKey;

import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

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
			itemArray = SpriteItems.instance.potions;
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
			Resources.descriptions.set("Helm of Hardiness", "This helm is crafted by dwarven smiths in the Roshaggon mines, using an alloy jealously kept secret.");
			Resources.descriptions.set("Gloves of Dexterity","The swiftness of these hand gloves allow their wearer to perform faster in battle.");
			Resources.descriptions.set("Achilles' Bracer","This magical bronze bracer contains within it the great warrior's spirit.");
			Resources.descriptions.set("Short Sword", "A one handed hilt attached to a thrusting blade approximately 60cm in length.");
			Resources.descriptions.set("Long Sword","Long swords have long cruciform hilts with grips and double-edged blades over one meter long.");
			Resources.descriptions.set("Staff","A sturdy shaft of hardwood with metal tips.");
			Resources.descriptions.set("Dagger", "A double-edged blade used for stabbing or thrusting.");
			
			Resources.descriptions.set("Axe", "A mighty axe, good for chopping wood and flesh.");
			Resources.descriptions.set("Hardened Batlle Axe", "Crafted from the finest of metals, this axe can deal lethal slashing, cleaving and slicing blows.");
			Resources.descriptions.set("Broad Claymore", "An ancient weapon, many bards have sung about glorious victories won with it.");
			Resources.descriptions.set("Kings Golden Helm", "Made of pure gold, gives you unbreachable head protection, and irresistible looks.");
			Resources.descriptions.set("Beastly Mace", "A mighty huge and spiky mace, made for fast swinging and powerfull rips.");
			Resources.descriptions.set("Twin Bladed Katana", "An Ancient weapon, crafted by masters of the craft, from the far east.");
			Resources.descriptions.set("Full Helmet of Vitality", "Originally worn by dark priests, this helmet helps you tap into energies of the full moon.");
			Resources.descriptions.set("Full Plate Armor", "A classic well tested model of armor, highly praised by knights from around the globe.");
			Resources.descriptions.set("Rogues' Cloak of Swiftness", "Made from enchanted cloth, both light and durable. Wearing this feel like touching the sky.");
			Resources.descriptions.set("Gauntlets of Sturdiness", "The floral decorations on these gauntlets give confidence that they're crafted skillfully and with attention to detail.");
			Resources.descriptions.set("Supernatural Amulet", "Inscribed upon this amulet, are magic runes, which yield gains in many attributes for the wearer.");
			Resources.descriptions.set("Ring of Rubies", "You sense a powerfull force in this ring, feels like life itself is flowing from it.");
			Resources.descriptions.set("Lizards' Tundra Boots", "Made for the toughest of conditions, able to withstand both ice and fire, gives you superior mobility on every terrain.");
		
		inited = true;
	}
	
	public static function newItem(X:Float, Y:Float, type:CqItemType):CqItem {
		initDescriptions();

		var item = new CqItem(X, Y, type);
		
		
		switch(type) {
			case WINGED_SANDLES, BOOTS, TUNDRA_BOOTS:
				item.equipSlot = CqEquipSlot.SHOES;
			case LEATHER_ARMOR, BRESTPLATE, FULL_PLATE_MAIL, CLOAK:
				item.equipSlot = CqEquipSlot.ARMOR;
			case RING, AMULET,GEMMED_AMULET, GEMMED_RING:
				item.equipSlot = CqEquipSlot.JEWELRY;
			case CAP, HELM, GOLDEN_HELM, FULL_HELM:
				item.equipSlot = CqEquipSlot.HAT;
			case GLOVE, BRACELET, GAUNTLET:
				item.equipSlot = CqEquipSlot.GLOVES;
			case STAFF, DAGGER, SHORT_SWORD, LONG_SWORD, AXE, BATTLE_AXE, CLAYMORE, MACE, SPIKE_SWORD:
				item.equipSlot = CqEquipSlot.WEAPON;
			case GREEN_POTION, PURPLE_POTION, BLUE_POTION, YELLOW_POTION, RED_POTION:
				item.equipSlot = CqEquipSlot.POTION;
			default:
				item.equipSlot = null;
		}
		switch(type) {
			//POTIONS
			case GREEN_POTION:
				item.name = "Elixir of the Hawk";
				item.consumable = true;
				item.buffs.set("attack", 3);
				item.stackSizeMax = -1;
				item.duration = 120;
			case PURPLE_POTION:
				item.name = "Elixir of the Lion";
				item.consumable = true;
				item.specialEffects.add(new CqSpecialEffectValue("damage multipler","2"));
				item.duration = 120;
				item.stackSizeMax = -1;			
			case BLUE_POTION:
				item.name = "Elixir of the Elephant";
				item.consumable = true;
				item.buffs.set("defense", 3);
				item.duration = 120;
				item.stackSizeMax = -1;
			case YELLOW_POTION:
				item.name = "Coca-leaf Cocktail";
				item.consumable = true;
				item.buffs.set("speed", 3);
				item.duration = 120;
				item.stackSizeMax = -1;
			case RED_POTION:
				item.name ="Healing Potion";
				item.consumable = true;
				item.specialEffects.add(new CqSpecialEffectValue("heal","full"));
				item.stackSizeMax = -1;
			//BOOTS
			case BOOTS:
				item.name ="Boots of Escape";
				item.buffs.set("speed", 1);
			case WINGED_SANDLES:
				item.name =	"Hermes' Sandals";
				item.buffs.set("speed", 2);
			case TUNDRA_BOOTS:
				item.name =	"Lizards' Tundra Boots";
				item.buffs.set("speed", 2);
				item.buffs.set("defense", 1);
			//ARMORS
			case LEATHER_ARMOR:
				item.name ="Leather Armor";
				item.buffs.set("defense", 1);
			case BRESTPLATE:
				item.name ="Breastplate";
				item.buffs.set("defense", 2);
			case FULL_PLATE_MAIL:
				item.name ="Full Plate Armor";
				item.buffs.set("defense", 3);
			case CLOAK:
				item.name ="Rogues' Cloak of Swiftness";
				item.buffs.set("defense", 2);
				item.buffs.set("speed", 2);
			//JEWELRY
			case RING:
				item.name ="Ring of Wisdom";
				item.buffs.set("spirit", 1);
			case AMULET:
				item.name ="Amulet of Enlightenment";
				item.buffs.set("spirit", 2);
			case GEMMED_AMULET:
				item.name ="Supernatural Amulet";
				item.buffs.set("spirit", 2);
				item.buffs.set("speed", 1);
				item.buffs.set("defense", 1);
			case GEMMED_RING:
				item.name ="Ring of Rubies";
				item.buffs.set("life", 3);
				item.buffs.set("spirit",2);
			//HELMETS
			case CAP:
				item.name ="Cap of Endurance";
				item.buffs.set("life", 1);
			case HELM:
				item.name ="Helm of Hardiness";
				item.buffs.set("life", 2);
			case GOLDEN_HELM:
				item.name = "Kings Golden Helm";
				item.buffs.set("life", 2);
				item.buffs.set("defense", 3);
			case FULL_HELM:
				item.name = "Full Helmet of Vitality";
				item.buffs.set("life", 4);
			//GLOVES
			case GLOVE:
				item.name ="Gloves of Dexterity";
				item.buffs.set("attack", 1);
			case BRACELET:
				item.name ="Achilles' Bracer";
				item.buffs.set("attack", 2);
			case GAUNTLET:
				item.name ="Gauntlets of Sturdiness";
				item.buffs.set("attack", 2);
				item.buffs.set("defense", 2);
			//WEAPONS
			case DAGGER:
				item.name ="Dagger";
				item.damage = new Range(1, 2);
			case STAFF:
				item.name ="Staff";
				item.damage = new Range(1, 3);
			case SHORT_SWORD:
				item.name ="Short Sword";
				item.damage = new Range(1, 3);
			case LONG_SWORD:
				item.name ="Long Sword";
				item.damage = new Range(2, 4);
				//add stats
			case AXE:
				item.name = "Axe";
				item.damage = new Range(4, 6);
			case BATTLE_AXE:
				item.name = "Hardened Batlle Axe";
				item.damage = new Range(5, 12);
				item.buffs.set("speed", -2);
			case MACE:
				item.name = "Beastly Mace";
				item.damage = new Range(4, 11);
			case CLAYMORE:
				item.name = "Broad Claymore";
				item.damage = new Range(6, 10);
				item.buffs.set("speed", -1);
			case SPIKE_SWORD:
				item.name ="Twin Bladed Katana";
				item.damage = new Range(5, 12);
				item.buffs.set("defense", -2);
				item.buffs.set("speed", 2);
			default:
				throw "forgot something";
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
			case 2, 3:
				Item.isMagical = true;
			case 4, 5:
				Item.isSuperb = true;
				Item.isMagical = true;
			case 6, 7, 8: // 8 is for out of depth items on level 7
				Item.isSuperb = true;
				Item.isWondrous = true;
		}

		if (Item.isSuperb) {
			Item.name = "Superb " + Item.name;
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
			var buffs = ["defense", "attack", "life", "spirit", "speed"];
			
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
				Item.name = "Magical " + Item.name;
				Item.buffs.set(extraBuff, Item.buffs.get("extraBuff") + 1);
			} else {// isWondrous
				Item.name = "Wondrous " + Item.name;
				Item.buffs.set(extraBuff, Item.buffs.get("extraBuff") + 2);
			}
		}
	}
}

class CqItem extends GameObjectImpl, implements Loot {
	public var name:String;
	
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
	var glowSprite:BitmapData;
	var glowRect:Rectangle;
	
	public var isSuperb:Bool;
	public var isMagical:Bool;
	public var isWondrous:Bool;

	public function new(X:Float, Y:Float, type:Dynamic) {
		super(X, Y);
		var typeName:String = Type.enumConstructor(type).toLowerCase();
		zIndex = 1;
		isSuperb = false;
		isMagical = false;
		isWondrous = false;
		
		//this is a terrible, terrible work-around, but it'll do for now
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
		
		glowSpriteKey = CqGraphicKey.ItemGlow(typeName);
		//TODO: move to game ui, to be with the rest of graphic cache creation
		glowRect = new Rectangle(0, 0, 48, 48);
		if ( GraphicCache.checkBitmapCache(glowSpriteKey) ) {
			glowSprite = GraphicCache.getBitmap(glowSpriteKey);
		} else {
			var tmp:BitmapData = new BitmapData(48, 48, true, 0x0);
			tmp.copyPixels(getFramePixels(), new Rectangle(0, 0, 32, 32), new Point(8, 8), null, null, true);
			var glow:GlowFilter = new GlowFilter(0xffea00, 0.9, 16.0, 16.0, 1.6, 1, false, false);
			tmp.applyFilter(tmp, glowRect, new Point(0, 0), glow);
			GraphicCache.addBitmapData(tmp, glowSpriteKey);
			glowSprite = tmp;
			glow = null;
		}
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
	

	public function doPickupEffect() {
		HxlGraphics.state.add(this);
		setGlow(false);
		var self = this;
		var oldX = x;
		var oldY = y;
		Actuate.update(function(params:Dynamic) {
			self.x = params.X;
			self.y = params.Y;
			self.alpha = params.Alpha;
		}, 1.0, {X: x, Y: y, Alpha: 1.0}, {X: x, Y: y-48, Alpha: 0.0}).onComplete(function() {
			self.x = oldX;
			self.y = oldY;
			HxlGraphics.state.remove(self);
			self.destroy();
		}).ease(Cubic.easeOut); 
	}
	
	public function equalTo(other:CqItem):Bool {
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
	public function compareTo(other:CqItem) {
		if (other.equipSlot != equipSlot)
			return 0.0;
			
		
		var preference:Float = 0.0;
		var sumBuffsThis:Float  = HxlUtil.sumHashInt(buffs);
		var sumBuffsOther:Float = HxlUtil.sumHashInt(other.buffs);
		
		var dmgAvgThis:Float  = (damage.start + damage.end)/2;
		var dmgAvgOther:Float = (other.damage.start + other.damage.end)/2;
		if (dmgAvgThis > dmgAvgOther)
			sumBuffsThis++;
		else if(dmgAvgThis < dmgAvgOther)
			sumBuffsOther++;
		//do nothing if damage is equal
		if ( sumBuffsOther == 0) sumBuffsOther = 0.1;
		preference = sumBuffsThis / sumBuffsOther;
		
		return preference;
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

		for ( Callback in onBust ) Callback(this);

		// create random item
		var typeName:String = null;
		do {
			// chance of getting a potion
			if (Math.random() < CqConfiguration.dropPotionChance)
				typeName = HxlUtil.getRandomElement(SpriteItems.instance.potions).toUpperCase();
			else
			{
				//set up equipment array. means filter out potions from the item enum.
				if (equipment == null)
				{
					var li:Array<String> 			= Type.getEnumConstructs(CqItemType);
					var upperCasePotions			= Lambda.map(SpriteItems.instance.potions, function (a:String):String { return a.toUpperCase(); });
					var isNotPotion:String->Bool	= function (a:String):Bool { return (!Lambda.has(upperCasePotions, a)); }
					CqChest.equipment				= Lambda.array(Lambda.filter(li, isNotPotion));
				}
				
				var itemsPerLevel:Int = Math.floor( equipment.length / CqConfiguration.lastLevel );
				
				if (Math.random() < CqConfiguration.betterItemChance)
					level = level + 1;
				
				//get random element, by level. this algo might not be perfect, but it works.
				var itemIndex:Int = Math.floor( (level * itemsPerLevel) + (Math.random() * itemsPerLevel) );
				
				if (itemIndex >= equipment.length)
					itemIndex = equipment.length - 1;
				typeName	= equipment[itemIndex];
			}
		} while (typeName == "CHEST");
		
		var item = CqLootFactory.newItem(x, y, Type.createEnum(CqItemType,  typeName));
		
		if (Math.random() < 0.1)
			// 10% chance of magical item
			CqLootFactory.enchantItem(item, Registery.level.index);
		else if (Math.random() < 0.01)
			// another 1% chance of out-of-depth magical item
			CqLootFactory.enchantItem(item, Registery.level.index+1);
		
		// add item to level
		Registery.level.addLootToLevel(state, item);
		
		// remove chest
		Registery.level.removeLootFromLevel(state, this);
	}
}

enum CqItemType {
	AMULET;
	BOOTS;
	LEATHER_ARMOR;
	BRESTPLATE;
	CHEST;
	GLOVE;
	CAP;
	RING;
	BRACELET;
	WINGED_SANDLES;
	STAFF;
	DAGGER;
	SHORT_SWORD;
	LONG_SWORD;
	PURPLE_POTION;
	GREEN_POTION;
	BLUE_POTION;
	YELLOW_POTION;
	RED_POTION;
	HELM;
	AXE;
	BATTLE_AXE;
	CLAYMORE;
	GOLDEN_HELM;
	MACE;
	SPIKE_SWORD;
	FULL_HELM;
	FULL_PLATE_MAIL;
	CLOAK;
	GAUNTLET;
	GEMMED_AMULET;
	GEMMED_RING;
	TUNDRA_BOOTS;
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
