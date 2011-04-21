package cq;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;

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

import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

class CqSpecialEffectValue {
	public var name:String;
	public var value:Dynamic;
	public function new(name:String, value:Dynamic) {
		this.name = name;
		this.value = value;
	}
}

class CqLootFactory {
	static function initDescriptions() {
		Resources.descriptions = new Hash<String>();
		Resources.descriptions.set("Healing potion", "A small vial containing fragrant, red salve. Restores life when applied.");
		Resources.descriptions.set("Coca-leaf cocktail","This mysterious beverage grants great speed when quaffed.");
		Resources.descriptions.set("Elixir of the elephant","This elixir temporarily protects the drinker's body with a thick hide.");
		Resources.descriptions.set("Elixir of the hawk","This elixir temporarily grants ultra-human eyesight and reflexes.");
		Resources.descriptions.set("Elixir of the lion","This elixir temporarily strengthens the drinker immensely.");
		Resources.descriptions.set("Boots of escape", "These finely crafted leather boots allow the wearer to run with great speed.");
		Resources.descriptions.set("Hermes' sandals","These winged sandals are made of imperishable gold and allow the wearer to move as swiftly as any bird.");
		Resources.descriptions.set("Leather armor","This armor is made of leather that was boiled in wax for extra toughness.");
		Resources.descriptions.set("Breastplate", "This breastplate is made of iron and offers excellent protection to vital organs without limiting mobility.");
		Resources.descriptions.set("Ring of wisdom","This small silver ring imbues its wearer with uncanny wisdom.");
		Resources.descriptions.set("Amulet of enlightenment","Enlightenment permeates this simple looking amulet, granting its wearer the spirit of the gods.");
		Resources.descriptions.set("Cap of endurance", "This steel skullcap protects the head without restricting the wearer's ability to wear fashionable hats.");
		Resources.descriptions.set("Helm of hardiness", "This helm is crafted by dwarven smiths in the Roshaggon mines, using an alloy jealously kept secret.");
		Resources.descriptions.set("Gloves of dexterity","The swiftness of hand these gloves enable allow their wearer to perform better in battle.");
		Resources.descriptions.set("Achilles' bracer","This magical bronze bracer contains within it the great warrior's spirit.");
		Resources.descriptions.set("Short sword", "A one handed hilt attached to a thrusting blade approximately 60cm in length.");
		Resources.descriptions.set("Long sword","Long swords have long cruciform hilts with grips and  double-edged blades over one meter long.");
		Resources.descriptions.set("Staff","a shaft of hardwood with metal tips.");
		Resources.descriptions.set("Dagger", "a double-edged blade used for stabbing or thrusting.");
	}
	
	public static function newItem(X:Float, Y:Float, typeName:String):CqItem {

		if (Resources.descriptions == null) {
			initDescriptions();
		}
		
		//typeName = "PURPLE_POTION";
		var type = Type.createEnum(CqItemType,  typeName);
		var item = new CqItem(X, Y, typeName.toLowerCase());

		switch(type) {
			case WINGED_SANDLES, BOOTS:
				item.equipSlot = CqEquipSlot.SHOES;
			case LEATHER_ARMOR, BRESTPLATE:
				item.equipSlot = CqEquipSlot.ARMOR;
			case RING, AMULET:
				item.equipSlot = CqEquipSlot.JEWELRY;
			case CAP, HELM:
				item.equipSlot = CqEquipSlot.HAT;
			case GLOVE, BRACLET:
				item.equipSlot = CqEquipSlot.GLOVES;
			case STAFF, DAGGER, SHORT_SWORD, LONG_SWORD:
				item.equipSlot = CqEquipSlot.WEAPON;
			case GREEN_POTION, PURPLE_POTION, BLUE_POTION, YELLOW_POTION, RED_POTION:
				item.equipSlot = CqEquipSlot.POTION;
			default:
		}
		
		switch(type) {
			case GREEN_POTION:
				item.name = "Elixir of the hawk";
				item.consumable = true;
				item.buffs.set("attack", 3);
				item.stackSizeMax = 20;
			case PURPLE_POTION:
				item.name = "Elixir of the lion";
				item.consumable = true;
				item.specialEffects.add(new CqSpecialEffectValue("damage multipler","2"));
				item.duration = 120;
				item.stackSizeMax = 20;			
			case BLUE_POTION:
				item.name = "Elixir of the elephant";
				item.consumable = true;
				item.buffs.set("defense", 3);
				item.duration = 120;
				item.stackSizeMax = 20;
			case YELLOW_POTION:
				item.name = "Coca-leaf cocktail";
				item.consumable = true;
				item.buffs.set("speed", 3);
				item.duration = 120;
				item.stackSizeMax = 20;
			case RED_POTION:
				item.name ="Healing potion";
				item.consumable = true;
				item.specialEffects.add(new CqSpecialEffectValue("heal","full"));
				item.duration = 120;
				item.stackSizeMax = 20;
			
			case BOOTS:
				item.name ="Boots of escape";
				item.buffs.set("speed", 1);

			case WINGED_SANDLES:
				item.name =	"Hermes' sandals";
				item.buffs.set("speed", 2);
				
			case LEATHER_ARMOR:
				item.name ="Leather armor";
				item.buffs.set("defense", 1);
			case BRESTPLATE:
				item.name ="Breastplate";
				item.buffs.set("defense", 2);
			
			case RING:
				item.name ="Ring of wisdom";
				item.buffs.set("spirit", 1);
			case AMULET:
				item.name ="Amulet of enlightenment";
				item.buffs.set("spirit", 2);
			
			case CAP:
				item.name ="Cap of endurance";
				item.buffs.set("life", 1);
			case HELM:
				item.name ="Helm of hardiness";
				item.buffs.set("life", 2);
			
			case GLOVE:
				item.name ="Gloves of dexterity";
				item.buffs.set("attack", 1);
			case BRACLET:
				item.name ="Achilles' bracer";
				item.buffs.set("attack", 2);
			
			case DAGGER:
				item.name ="Dagger";
				item.damage = new Range(1, 2);
			case STAFF:
				item.name ="Staff";
				item.damage = new Range(1, 3);
			case SHORT_SWORD:
				item.name ="Short sword";
				item.damage = new Range(1, 3);
			case LONG_SWORD:
				item.name ="Long sword";
				item.damage = new Range(2, 4);
			
			default:
		}
	
		return item;
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
	var glowSpriteKey:String;
	var glowSprite:BitmapData;
	var glowRect:Rectangle;

	public function new(X:Float, Y:Float, typeName:String) {
		super(X, Y);

		zIndex = 1;
		
		if (Std.is(this, CqSpell)) {
			loadGraphic(SpriteSpells, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			addAnimation("idle", [SpriteSpells.instance.getSpriteIndex(typeName)], 0 );
		} else {
			loadGraphic(SpriteItems, false, false, Configuration.tileSize, Configuration.tileSize, false, Configuration.zoom, Configuration.zoom);
			addAnimation("idle", [SpriteItems.instance.getSpriteIndex(typeName)], 0 );
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
		glowSpriteKey = "ItemGlow-"+typeName;
		glowRect = new Rectangle(0, 0, 48, 48);
		if ( HxlGraphics.checkBitmapCache(glowSpriteKey) ) {
			glowSprite = HxlGraphics.getBitmap(glowSpriteKey);
		} else {
			var tmp:BitmapData = new BitmapData(48, 48, true, 0x0);
			tmp.copyPixels(getFramePixels(), new Rectangle(0, 0, 32, 32), new Point(8, 8), null, null, true);
			var glow:GlowFilter = new GlowFilter(0xffea00, 0.9, 16.0, 16.0, 1.6, 1, false, false);
			tmp.applyFilter(tmp, glowRect, new Point(0, 0), glow);
			HxlGraphics.addBitmapData(tmp, glowSpriteKey);
			glowSprite = tmp;
			glow = null;
		}
	}

	public function setGlow(Toggle:Bool):Void {
		isGlowing = Toggle;
	}

	override function renderSprite():Void {
		if ( !isGlowing ) {
			super.renderSprite();
			return;
		}
		getScreenXY(_point);
		_flashPoint.x = _point.x - 8;
		_flashPoint.y = _point.y - 8;
		HxlGraphics.buffer.copyPixels(glowSprite, glowRect, _flashPoint, null, null, true);
	}

	public function doPickupEffect():Void {
		HxlGraphics.state.add(this);
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
}

/**
 * Chests are encountered in the dungeon and once detroyed drop a random item
 */
class CqChest extends CqItem {

	var onBust:List<Dynamic>;

	public function new(X:Float, Y:Float) {
		super(X, Y,"chest");
		onBust = new List();
		visible = false;
	}
	
	public function addOnBust(Callback:Dynamic):Void {
		onBust.add(Callback);
	}

	public function bust(state:HxlState) {

		for ( Callback in onBust ) Callback(this);

		// create random item
		var type = null;
		do {
			// doubling chance of getting a potion
			type = HxlUtil.getRandomElement(Type.getEnumConstructs(CqItemType).concat(["PURPLE_POTION","GREEN_POTION","BLUE_POTION","YELLOW_POTION","RED_POTION"])); 
		} while (type == "CHEST");
		var item = CqLootFactory.newItem(x, y, type);		
		
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
	BRACLET;
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
}

enum CqSpellType {
	FREEZE; 
	FIREBALL; 
	BERSERK; 
	ENFEEBLE_MONSTER; 
	BLESS_WEAPON; 
	HASTE; 
	SHADOW_WALK;
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
