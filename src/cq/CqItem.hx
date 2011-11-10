package cq;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Cubic;

import data.Configuration;
import data.Resources;
import data.Registery;
import data.StatsFile;

import haxel.HxlSprite;
import haxel.HxlState;
import haxel.HxlGraphics;
import haxel.HxlUtil;
import haxel.HxlPoint;

import world.Loot;
import world.GameObject;

import data.Configuration;
import cq.states.GameState;
import cq.CqResources;
import cq.CqWorld;
import cq.CqGraphicKey;
import cq.effects.CqEffectSpell;
import cq.CqActor;
import cq.CqSpell; // maybe offload this by overriding activate in CqSpell, but not yet, and maybe not ever (there are trade-offs)

import data.SoundEffectsManager;

import cq.CqBag;
import cq.ui.bag.BagGrid;

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
	public var fullName(computeFullName, null):String;	
	public var isReadyToActivate (computeIsReadyToActivate, never):Bool;
	public var isEnchanted(computeIsEnchanted, never):Bool;
	public var monetaryValue(computeMonetaryValue, never):Int;
	
	public var equipSlot:CqEquipSlot;
	public var consumable:Bool;
	public var spriteIndex:String;
	public var damage:Range;
	
	// some spells/items take more than one turn to perform their action and cannot be used again until they are done
	public var isActive(default, null):Bool;
	public var currentActivationDamage(default, null):Int;
	
	// most spells and items change intrinsics or apply effects
	public var buffs:Hash<Int>;
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
	
	public var inventoryProxy:CqInventoryProxy;
	public var itemSlot:CqItemSlot;

	public var targetsOther:Bool;
	public var targetsEmptyTile:Bool;
	
	// recharging rules for spells and other similar equipment
	public var stat:String;
	public var statPoints:Int;
	public var statPointsRequired:Int;
	
	public function new(X:Float, Y:Float, _id:String, sprite:String) {
		super(X, Y);
		
		spriteIndex = sprite.toLowerCase();
		
		zIndex = 1;
		isSuperb = false;
		isMagical = false;
		isWondrous = false;
		
		id = _id;
		statPoints = 0;		
		statPointsRequired = 0;
		visible = false;
		
		
		targetsOther = false;
		targetsEmptyTile = false;

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
	
	function computeIsEnchanted() {
		return isMagical || isSuperb || isWondrous;
	}
	
	function computeFullName():String {
		var prefix = "";
		if (isSuperb)
			prefix += Resources.getString( "PREFIX_SUPERB" ) + " ";
		if (isWondrous)
			prefix += Resources.getString( "PREFIX_WONDROUS" ) + " ";
		if (isMagical)
			prefix += Resources.getString( "PREFIX_MAGICAL" ) + " ";			
			
		return prefix + name;
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
		
		inventoryProxy = null;
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
	}
	
	public function equalTo(other:CqItem):Bool {
		return (
		     other.buffs.get( "attack" ) == buffs.get( "attack" )
		  && other.buffs.get( "defense" ) == buffs.get( "defense" )
		  && other.buffs.get( "speed" ) == buffs.get( "speed" )
		  && other.buffs.get( "spirit" ) == buffs.get( "spirit" )
		  && other.buffs.get( "life" ) == buffs.get( "life" )
		  && other.damage.start == damage.start
		  && other.damage.end == damage.end
		);
	}
	
	// this probably doesn't belong here, really
		
	public function makesRedundant(other:CqItem):Bool { // merge note: use this!
		return !( other.buffs.get( "attack" ) > buffs.get( "attack" )
		  || other.buffs.get( "defense" ) > buffs.get( "defense" )
		  || other.buffs.get( "speed" ) > buffs.get( "speed" )
		  || other.buffs.get( "spirit" ) > buffs.get( "spirit" )
		  || other.buffs.get( "life" ) > buffs.get( "life" )
		  || (other.damage.start + other.damage.end > damage.start + damage.end )
		  || equalTo(other)
		  );
	}
	
	private function computeMonetaryValue():Int {
		var sumBuffsThis:Float  = HxlUtil.sumHashInt(buffs);
		var dmgAvgThis:Float  = (damage.start + damage.end)/2;
		return Math.ceil((sumBuffsThis + dmgAvgThis) / 2);
	}
	
	private function computeIsReadyToActivate():Bool {
		if (!Std.is(HxlGraphics.state, GameState)) return false;
		
		if (isActive) return false;
		
		if (statPointsRequired > 0 && statPoints < statPointsRequired) return false;
		
		return true;
	}
	
	public function tryToActivate(?keyPress:Bool = false):Bool {
		// this is used for the player only -- it's for casting spells and using potions from the interface
	
		// there's really no need to make spells the only targeted things --
		// we can add scrolls, or darts, and such things as consumables like potions,
		// and those can be targeted.
		
		if (!isReadyToActivate) return false;
		
		if ( targetsOther || targetsEmptyTile) {
			GameUI.setTargeting(this);
			if (keyPress) GameUI.setTargetingPos(Registery.player.tilePos);
			
			return true;
		} else {
			if (!Std.is(HxlGraphics.state, GameState)) return false;
			
			GameUI.setTargeting(null);
			activate(Registery.player);
			cast(HxlGraphics.state, GameState).passTurn(); // this is a bad place for this  :(
			
			return true;
		}
	}
	
	public function activate(user:CqActor, ?victim:CqActor = null, ?cell:HxlPoint = null) {
		var item:CqItem = this;
		
		isActive = true;
		
		if (targetsOther && victim != null) {
			user.breakInvisible();
			
			// and now shoot
			var colorSource:BitmapData;
			
			// Update spell damage.
			var spellLevel:Int = 0;
			if (Std.is(user, CqPlayer)) {
				spellLevel = Registery.player.level;
				colorSource = item.inventoryProxy.pixels;
			} else {
				spellLevel = Math.ceil(2 + .5 * Registery.world.currentLevelIndex);
				colorSource = this._framePixels;
			}
			
			var damageRange = CqSpellFactory.getSpellDamageByLevel(item.id, spellLevel);
			currentActivationDamage = CqActor.biasedRandomInRange(damageRange.start, damageRange.end, 2);
			useOn(user, victim);
			
			// Fire off the effect.
			GameUI.instance.shootXBall(user, victim, colorSource, item);
		} else if (targetsEmptyTile && cell != null) {
			useAt(user, cell);
		} else {
			currentActivationDamage = 0;
			useOn(user, victim);
			completeUseOn(user, victim);
		}
		
		if (consumable) {
			stackSize--;
			if (stackSize <= 0) {
				itemSlot.item = null;
			} else {
				if (inventoryProxy != null) inventoryProxy.setIcon();
			}
		}
		
		if (item.statPointsRequired > 0) {
			SoundEffectsManager.play(SpellCast);
			item.statPoints = 0;
			//asSpell.inventoryProxy.updateCharge(asSpell);
		}
	}
			
	var tmpSpellSprite:HxlSprite;
	public function useOn(user:CqActor, victim:CqActor) {
		var itemOrSpell = this; // because this was refactored and this is easier than the alternative

		
		if (itemOrSpell.equipSlot == POTION)
			SoundEffectsManager.play(SpellEquipped);
			
		var effectColorSource:BitmapData;
		if (itemOrSpell.inventoryProxy == null) {
			if (tmpSpellSprite == null )
				tmpSpellSprite = new HxlSprite();
				
			// only happens when enemies try to use a spell
			tmpSpellSprite.loadGraphic(SpriteSpells, true, false, Configuration.tileSize, Configuration.tileSize);
			tmpSpellSprite.setFrame(SpriteSpells.instance.getSpriteIndex(itemOrSpell.spriteIndex));
			effectColorSource = tmpSpellSprite.getFramePixels();
		} else {
			effectColorSource = itemOrSpell.inventoryProxy.pixels;
		}
		
		// add buffs
		if(itemOrSpell.buffs != null) {
			for (buff in itemOrSpell.buffs.keys()) {
				var val = itemOrSpell.buffs.get(buff);
				var text = (val > 0?"+":"") + val + " " + buff;

				if (victim == null) {
					// apply to self
					user.buffs.set(buff, user.buffs.get(buff) + itemOrSpell.buffs.get(buff));
					
					// add timer
					if (itemOrSpell.duration > -1) {
						user.addTimer(new CqTimer(itemOrSpell.duration, buff, itemOrSpell.buffs.get(buff),null));
					}
				} else {
					// apply to victim
					var delta:Int = itemOrSpell.buffs.get(buff);
					victim.buffs.set(buff, victim.buffs.get(buff) + itemOrSpell.buffs.get(buff));
					
					// add timer
					if (itemOrSpell.duration > -1) {
						var bufftimer: CqTimer = new CqTimer(itemOrSpell.duration, buff, delta, null);
						
						victim.addTimer(bufftimer);
					}
				}
			}
		}
		// apply special effect
		if(itemOrSpell.specialEffects != null){
			for (effect in itemOrSpell.specialEffects) {
				user.applyEffect(effect, victim);
				
				// this is ugly, and will be changed so we only have effects -- no buffs, no separate timers
				if (itemOrSpell.duration > -1) {
					if (victim == null)
						user.addTimer(new CqTimer(itemOrSpell.duration, null, -1, effect));
					else
						victim.addTimer(new CqTimer(itemOrSpell.duration, null, -1, effect));
				}
			}
		}
		
		// calculate damage
		if (currentActivationDamage > 0) {
			// we'll keep currentActivationDamage all the way until completeUseOn, when the spell actually hits
			var dmg = currentActivationDamage;

			// "Ghost" killed actors now so they can't act any more (make this a parameter of damageActor?)
			if (victim == null) {
				var lif = user.hp + user.buffs.get("life");
				if (lif - dmg <= 0)
					user.doGhost(dmg);
			} else {
				var lif = victim.hp + victim.buffs.get("life");
				if (lif - dmg <= 0)
					victim.doGhost(dmg);
			}
		}
		
		// dispose of an enemy's tmp spell sprite, if we've made one
		if (itemOrSpell.inventoryProxy == null) {
			effectColorSource.dispose();
			tmpSpellSprite.destroy();
			tmpSpellSprite = null;
		}		
	}

	// Called when a spell hits, even though the effects are applied immediately.
	public function completeUseOn(user:CqActor, victim:CqActor) {
		var itemOrSpell = this; // because this was refactored and this is easier than bothering to change everything around
		var effectColorSource:BitmapData;
		
		isActive = false;
		
		if (itemOrSpell.inventoryProxy == null) {
			if (tmpSpellSprite == null )
				tmpSpellSprite = new HxlSprite();
				
			// only happens when enemies try to use a spell
			tmpSpellSprite.loadGraphic(SpriteSpells, true, false, Configuration.tileSize, Configuration.tileSize);
			tmpSpellSprite.setFrame(SpriteSpells.instance.getSpriteIndex(itemOrSpell.spriteIndex));
			effectColorSource = tmpSpellSprite.getFramePixels();
		} else {
			effectColorSource = itemOrSpell.inventoryProxy.pixels;
		}
		
		// show buffs
		if(itemOrSpell.buffs != null) {
			for (buff in itemOrSpell.buffs.keys()) {
				var val = itemOrSpell.buffs.get(buff);
				var text = (val > 0?"+":"") + val + " " + buff;

				if (victim == null) {
					var c:Int;
					switch(buff) {
						case "attack":
							c = 0x4BE916;
						case "defense":
							c = 0x381AE6;
						case "speed":
							c = 0xEDD112;
						default:
							c = 0xFFFFFF;
					}
					
					GameUI.showEffectText(user, text, c);
					
					//special effect
					var eff:CqEffectSpell = new CqEffectSpell(user.x+user.width/2, user.y+user.width/2, effectColorSource);
					eff.zIndex = 1000;
					HxlGraphics.state.add(eff);
					eff.start(true, 1.0, 10);
				} else {
					// apply to victim
					GameUI.showEffectText(victim, text, 0xff8822);
				}
			}
		}
		if (victim != null){
			//special effect
			var eff:CqEffectSpell = new CqEffectSpell(victim.x + victim.width/2, victim.y + victim.height/2, effectColorSource);
			eff.zIndex = 1000;
			HxlGraphics.state.add(eff);
			eff.start(true, 1.0, 10);
		}
		
		// apply damage
		if (currentActivationDamage > 0 ) {
			var dmg = currentActivationDamage;
			
			// redundant and repetitive:
			if (victim== null) {
				user.hp -= dmg;
				var lif = user.hp + user.buffs.get("life");
				if (lif > 0 && !user.isGhost)
					user.injureActor(HxlGraphics.state, user, dmg);
				else
					user.killActor(HxlGraphics.state, user, dmg);
			} else {
				victim.hp -= dmg;
				var lif = victim.hp + victim.buffs.get("life");
				if (lif > 0 && !victim.isGhost)
					user.injureActor(HxlGraphics.state, victim, dmg);
				else
					user.killActor(HxlGraphics.state, victim, dmg);
			}
		}
		
		// dispose of an enemy's tmp spell sprite, if we've made one
		if (itemOrSpell.inventoryProxy == null) {
			effectColorSource.dispose();
			tmpSpellSprite.destroy();
			tmpSpellSprite = null;
		}		
	}
	
	public function useAt(user:CqActor, coord:HxlPoint) {
		var itemOrSpell:CqItem = this;
		var tile:CqTile = Registery.level.getTile(coord.x, coord.y);
		
		var effectColorSource:BitmapData = itemOrSpell.pixels;
		if (itemOrSpell.specialEffects != null){
			for (effect in itemOrSpell.specialEffects) {
				applyEffectAt(user, effect, tile, itemOrSpell.duration);
			}
		}
		//special effect
		var pos:HxlPoint = Registery.level.getTilePos(tile.mapX, tile.mapY, true);
		var eff:CqEffectSpell = new CqEffectSpell(pos.x, pos.y, effectColorSource);
		eff.zIndex = 1000;
		HxlGraphics.state.add(eff);
		eff.start(true, 1.0, 10);
	}
	
	// I don't like this method signature very well
	function applyEffectAt(user:CqActor, effect:CqSpecialEffectValue, tile:CqTile, ?duration:Int = -1) {
		switch(effect.name){
		
		case "teleport":
			var pixelLocation = Registery.level.getPixelPositionOfTile(tile.mapX,tile.mapY);
			user.setTilePos(Std.int(tile.mapX), Std.int(tile.mapY));
			// movetoPixel should _never_ be called directly by _anything_, much less by an item; setTilePos should handle this
			user.moveToPixel(HxlGraphics.state, pixelLocation.x, pixelLocation.y);
			
			Registery.level.hideAll(HxlGraphics.state);
			Registery.level.updateFieldOfView(HxlGraphics.state, true);
			
			pixelLocation = null;
		case "magic_mirror":
			// note that the player's magic mirror sprite will actually be backwards!  Very cool.
			var mob = Registery.level.createAndAddMirror(new HxlPoint(tile.mapX,tile.mapY), Registery.player.level, true, user);
			mob.specialEffects.set(effect.name, effect);
			Registery.level.updateFieldOfView(HxlGraphics.state, true);
			
			// if this were not after updateFieldOfView, we would not see the message
			GameUI.showEffectText(mob, Resources.getString( "POPUP_MIRROR" ), 0x2DB6D2);
			
			if (duration > -1) {
				mob.addTimer(new CqTimer(duration, null, -1, effect));
			}
		}
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
