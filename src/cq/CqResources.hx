// fixme - don't replicate spriteNames arrays for every instance!

package cq;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLRequest;
import flash.text.Font;
import flash.media.Sound;
import haxel.HxlSprite;
import haxel.HxlUtil;
import cq.CqActor;
import data.Resources;
import haxel.HxlSpriteSheet;

class FontDungeon extends Font { 
	public static var instance = new FontDungeon();
	public function new() { super(); } 
}
class FontAnonymousPro extends Font { 
	public static var instance = new FontAnonymousPro();
	public function new() { super(); } 
}
#if japanese
class JapaneseFontScaling {
	public static inline var c_dungeonScale:Float = 0.6;
	public static inline var c_anonymousScale:Float = 1;
}

class FontTheatre16 extends Font {
	public static var instance = new FontTheatre16();
	public function new() { super(); } 
}
#else
class FontAnonymousProB extends Font { 
	public static var instance = new FontAnonymousProB();
	public function new() { super(); } 
}
#end

class MainThemeOne extends Sound { public function new() { super(); } }
class MainThemeTwo extends Sound { public function new() { super(); } }
class MenuTheme extends Sound { public function new() { super(); } }
class BossTheme extends Sound { public function new() { super(); } }
class WinTheme extends Sound { public function new() { super(); } }

class EnemyHit extends Sound { public function new() { super(); } }
class FortressGate extends Sound { public function new() { super(); } }
class ItemEquipped extends Sound { public function new() { super(); } }
class LevelUp extends Sound { public function new() { super(); } }
class MenuItemClick extends Sound { public function new() { super(); } }
class MenuItemMouseOver extends Sound { public function new() { super(); } }
class PlayerHit extends Sound { public function new() { super(); } }
class PotionEquipped extends Sound { public function new() { super(); } }
class PotionQuaffed extends Sound { public function new() { super(); } }
class SpellCast extends Sound { public function new() { super(); } }
class SpellCastNegative extends Sound { public function new() { super(); } }
class SpellEquipped extends Sound { public function new() { super(); } }
class Footstep1 extends Sound { public function new() { super(); } }
class Footstep2 extends Sound { public function new() { super(); } }
class Footstep3 extends Sound { public function new() { super(); } }
class Footstep4 extends Sound { public function new() { super(); } }
class Footstep5 extends Sound { public function new() { super(); } }
class Footstep6 extends Sound { public function new() { super(); } }
class EnemyMiss extends Sound { public function new() { super(); } }
class PlayerMiss extends Sound { public function new() { super(); } }
class ChestBusted extends Sound { public function new() { super(); } }
class Pickup extends Sound { public function new() { super(); } }
class DoorOpen extends Sound { public function new() { super(); } }
class Death extends Sound { public function new() { super(); } }
class Lose extends Sound { public function new() { super(); } }
class Win extends Sound { public function new() { super(); } }

class SpriteLogo extends Bitmap { public function new() { super(); } }
class SpriteHeart extends Bitmap { public function new() { super(); } }
class SpriteCoin extends Bitmap { public function new() { super(); } }
class SpriteStartButton extends Bitmap { public function new() { super(); } }
class SpriteButtonBg extends Bitmap { public function new() { super(); } }
class SpriteItemSlot1 extends Bitmap { public function new() { super(); } }
class SpriteItemSlot2 extends Bitmap { public function new() { super(); } }
class SpriteItemSlot3 extends Bitmap { public function new() { super(); } }
class SpriteInfo extends Bitmap { public function new() { super(); } }
class UiBeltHorizontal extends Bitmap { public function new() { super(); } }
class MobileUiBeltHorizontal extends Bitmap { public function new() { super(); } }
class UiInventoryBox extends Bitmap { public function new() { super(); } }
class MobileUiInventoryBox extends Bitmap { public function new() { super(); } }
class SpriteMapPaper extends Bitmap { public function new() { super(); } }
class MobileSpriteMapPaper extends Bitmap { public function new() { super(); } }
class SpriteCharPaper extends Bitmap { public function new() { super(); } }
class IntroScreen extends Bitmap { public function new() { super(); } }
class BlankScreen extends Bitmap { public function new() { super(); } }
class DeathScreen extends Bitmap { public function new() { super(); } }
class VortexScreen extends Bitmap { public function new() { super(); } }
class VortexLightsScreen extends Bitmap { public function new() { super(); } }
class VortexFigure extends Bitmap { public function new() { super(); } }
class White extends Bitmap { public function new() { super(); } }
class ArmorGames extends Bitmap { public function new() { super(); } }

class ScoutsRogue extends Bitmap { public function new() { super(); } }
class ScoutsWarrior extends Bitmap { public function new() { super(); } }
class ScoutsWizard extends Bitmap { public function new() { super(); } }
class ScoutsTitlepage extends Bitmap { public function new() { super(); } }
class ScoutsFinal extends Bitmap { public function new() { super(); } }
class ScoutsStartButton  extends Bitmap { public function new() { super(); } }

class SpriteCredits extends Bitmap { public function new() { super(); } }
class SpriteHighScoresBg extends Bitmap { public function new() { super(); } }
class SpriteMainmenuBg extends Bitmap { public function new() { super(); } }
class SpriteKnightEntry extends Bitmap { public function new() { super(); } }
class SpriteWizardEntry extends Bitmap { public function new() { super(); } }
class SpriteThiefEntry extends Bitmap { public function new() { super(); } }
class SpriteHelpOverlay extends Bitmap { public function new() { super(); } }
class SpriteInvHelpOverlay extends Bitmap { public function new() { super(); } }

class LogoSprite extends HxlSprite {
	public function new(?X:Float = 0, ?Y:Float = 0) {
		super(X,Y);
		loadGraphic(SpriteLogo);
	}
}
class CursorSprite extends HxlSprite {
	public function new(?CursorName:String = "diagonal", ?X:Float = 0, ?Y:Float = 0) {
		super(X,Y);
		loadGraphic(SpriteCursor, true, false, 32, 32);
		setFrame(SpriteCursor.instance.getSpriteIndex(CursorName));
	}
	
	override public function destroy() 
	{
		//there is only 1 cursor sprite, don't want to destroy it with the rest of the state
		//super.destroy();
	}
}
class StartButtonSprite extends HxlSprite {
	public function new(?X:Float=0, ?Y:Float=0) {
		super(X,Y);
		loadGraphic(SpriteStartButton, false, false, 90, 26);
	}
}
class ScoutsStartButtonSprite extends HxlSprite {
	public function new(?X:Float=0, ?Y:Float=0) {
		super(X,Y);
		loadGraphic(ScoutsStartButton, false, false, 90, 26);
	}
}
class ButtonSprite extends HxlSprite {
	public function new(?X:Float=0, ?Y:Float=0) {
		super(X, Y);
		
		#if flashmobile
		loadGraphic(SpriteItemSlot3, false, false, 64, 64);
		#else
		loadGraphic(SpriteItemSlot1, false, false, 64, 64);
		#end
	}
}

class HeartSprite extends HxlSprite {
	public function new(?X:Float=0, ?Y:Float=0) {
		super(X,Y);
		loadGraphic(SpriteHeart, false, false, 18, 18);
	}
}
class CoinSprite extends HxlSprite {
	public function new(?X:Float=0, ?Y:Float=0) {
		super(X,Y);
		loadGraphic(SpriteCoin, false, false, 18, 18);
	}
}
class SpritePortrait extends HxlSpriteSheet { 
	public static var instance = new SpritePortrait();
	static var _spriteNames:Array<Array<String>>;
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [["thief", "fighter", "wizard"]];
		spriteNames = _spriteNames;
		super(0);
	} 
	
	public static function getIcon(IconName:String, Size:Int, Zoom:Float):HxlSprite {
		return HxlSpriteSheet.getSprite(SpritePortrait, instance.getSpriteIndex(IconName), Size, Zoom);
	}
}
class SpritePortraitPaper extends HxlSpriteSheet { 
	public static var instance = new SpritePortraitPaper();
	static var _spriteNames:Array<Array<String>>;
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [["thief", "fighter", "wizard"]];
		
		spriteNames = _spriteNames;
		super(0);
	} 
	
	public static function getIcon(IconName:String, Size:Int, Zoom:Float):HxlSprite {
		return HxlSpriteSheet.getSprite(SpritePortraitPaper, instance.getSpriteIndex(IconName), Size, Zoom);
	}
}
class SpriteEquipmentIcons extends HxlSpriteSheet { 
	public static var instance = new SpriteEquipmentIcons();
	static var _spriteNames:Array<Array<String>>;
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
			["grey_destroy", "jewelry", "hat", "destroy"],
			["shoes", "armor", "gloves", "weapon"],
		];
		spriteNames = _spriteNames;
		super(0);
	} 
	
	public static function getIcon(IconName:String, Size:Int, Zoom:Float):HxlSprite {
		return HxlSpriteSheet.getSprite(SpriteEquipmentIcons, instance.getSpriteIndex(IconName), Size, Zoom);
	}
}
class SpriteIcons extends HxlSpriteSheet { 
	public static var instance = new SpriteIcons();
	static var _spriteNames:Array<Array<String>>;
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				["inventory","map","character","blank_icon"]
			];
		spriteNames = _spriteNames;
		super(0);
	} 
}
class SpriteEffects extends HxlSpriteSheet { 
	public static var instance = new SpriteEffects();
	static var _spriteNames:Array<Array<String>>;
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				["small_scratch","big_scratch"]
			];
		spriteNames = _spriteNames;
		super(0);
	} 
}
class SpriteSoundToggle extends HxlSpriteSheet { 
	public static var instance = new SpriteSoundToggle();
	static var _spriteNames:Array<Array<String>>;
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				["on","off"]
			];
		spriteNames = _spriteNames;
		super(0);
	} 
}
class SpriteFullscreenToggle extends HxlSpriteSheet { 
	public static var instance = new SpriteFullscreenToggle();
	static var _spriteNames:Array<Array<String>>;
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				["on","off"]
			];
		spriteNames = _spriteNames;
		super(0);
	} 
}
class SpriteItems extends HxlSpriteSheet { 
	public static var instance = new SpriteItems();
	static var _spriteNames:Array<Array<String>>;
	public static var potions:Array<String>;
	public function new() {
		if(potions==null)
			potions = ["purple_potion", "green_potion", "blue_potion", "yellow_potion", "red_potion"];
			
		//potions = HxlUtil.enumToStringArray([CqItemType.PURPLE_POTION, CqItemType.GREEN_POTION, CqItemType.BLUE_POTION, CqItemType.YELLOW_POTION, CqItemType.RED_POTION]);
		if (_spriteNames ==null)
			_spriteNames = [
				["amulet","boots","leather_armor","breastplate","chest","glove","cap","ring","bracelet","winged_sandals"],
				["staff", "dagger", "short_sword", "long_sword"].concat(potions).concat(["helm"]),
				["axe", "battle_axe", "claymore", "golden_helm", "mace", "broad_sword", "full_helm", "full_plate_mail", "cloak", "gauntlet"],
				["gemmed_amulet","gemmed_ring","tundra_boots","rune_sword"]
			];
			
		spriteNames = _spriteNames;
		super(0);
	} 	
}
class SpriteMonsters extends HxlSpriteSheet {
	static var _spriteNames:Array<Array<String>>;
	public static var instance = new SpriteMonsters();
	public function new() {
		
		if (_spriteNames ==null)
			_spriteNames = [
				["kobold_spear", "kobold_knives", "kobold_mage", "kobold_blank"],
				["werewolf_gray", "werewolf_blue", "werewolf_purple", "werewolf_blank"],
				["bandit_long_swords", "bandit_short_swords", "bandit_single_long_sword", "bandit_knives"],
				["minotaur", "minotaur_axe", "minotaur_sword", "minotaur_blank"],
				["succubus", "succubus_staff", "succubus_whip", "succubus_scepter"],
				["spider_yellow", "spider_red", "spider_gray", "spider_green"],
				["ape_blue", "ape_black", "ape_red","ape_white"],
				["elemental_green", "elemental_white", "elemental_red", "elemental_blue"],
			];
		spriteNames = _spriteNames;
		super(0);
	} 
}
class SpritePlayer extends HxlSpriteSheet { 
	static var _spriteNames:Array<Array<String>>;
	public static var instance = new SpritePlayer();
	public static var spriteNames = [
			["berserk_fighter", "fighter", "wizard", "thief", "cloaked_thief"],
			["berserk_fighter_long_sword", "fighter_long_sword", "wizard_long_sword","thief_long_sword","cloaked_thief_long_sword"],
			["berserk_fighter_short_sword", "fighter_short_sword", "wizard_short_sword","thief_short_sword","cloaked_thief_short_sword"],
			["berserk_fighter_staff", "fighter_staff", "wizard_staff","thief_staff","cloaked_thief_staff"],
			["berserk_fighter_dagger", "fighter_dagger", "wizard_dagger", "thief_dagger", "cloaked_thief_dagger"],
			["berserk_fighter_axe", "fighter_axe", "wizard_axe","thief_axe","cloaked_thief_axe"],
		];
	public function new() { 
		spriteNames = SpritePlayer.spriteNames;
		
		super(0); 
	} 
}
class SpriteTiles extends HxlSpriteSheet { 
	static var _spriteNames:Array<Array<String>>;
	public static var instance = new SpriteTiles();
	static var inited = false;
	public static var walkableAndSeeThroughTiles:Array<Int>;
	public static var solidAndBlockingTiles:Array<Int>;
	public static var stairsDown:Array<Int>;
	public static var doors:Array<Int>;
	public static var openDoors:Array<Int>;
	
	public function new() { 
		// important: one color-scheme per line (used implicitly in level generator)
		if (_spriteNames ==null)
			_spriteNames = [
				["red_up","red_down","red_floor0","red_floor1","red_wall0","red_wall1","red_wall2","red_wall3","red_wall4","red_door_close","red_door_open"], 
				["blue_up", "blue_down", "blue_floor0", "blue_floor1", "blue_wall0", "blue_wall1", "blue_wall2", "blue_wall3", "blue_wall4", "blue_door_close", "blue_door_open"], 
				["brown_up", "brown_down", "brown_floor0", "brown_floor1", "brown_wall0", "brown_wall1", "brown_wall2", "brown_wall3", "brown_wall4", "brown_door_close", "brown_door_open"], 
				["green_up","green_down","green_floor0","green_floor1","green_wall0","green_wall1","green_wall2","green_wall3","green_wall4","green_door_close","green_door_open"], 
			];
		
		spriteNames = _spriteNames;
		super(1);
		if(solidAndBlockingTiles == null)
			solidAndBlockingTiles = [
				getSpriteIndex("red_wall0"),getSpriteIndex("red_wall1"),getSpriteIndex("red_wall2"),getSpriteIndex("red_wall3"),getSpriteIndex("red_wall4"),getSpriteIndex("red_door_close"),
				getSpriteIndex("blue_wall0"),getSpriteIndex("blue_wall1"),getSpriteIndex("blue_wall2"),getSpriteIndex("blue_wall3"),getSpriteIndex("blue_wall4"),getSpriteIndex("blue_door_close"),
				getSpriteIndex("brown_wall0"), getSpriteIndex("brown_wall1"), getSpriteIndex("brown_wall2"), getSpriteIndex("brown_wall3"), getSpriteIndex("brown_wall4"), getSpriteIndex("brown_door_close"),
				getSpriteIndex("green_wall0"),getSpriteIndex("green_wall1"),getSpriteIndex("green_wall2"),getSpriteIndex("green_wall3"),getSpriteIndex("green_wall4"),getSpriteIndex("green_door_close"),
			];
			
		if(walkableAndSeeThroughTiles == null)
			walkableAndSeeThroughTiles = [
				getSpriteIndex("red_floor0"), getSpriteIndex("blue_floor0"), getSpriteIndex("brown_floor0"),getSpriteIndex("green_floor0"),
				getSpriteIndex("red_floor1"), getSpriteIndex("blue_floor1"), getSpriteIndex("brown_floor1"),getSpriteIndex("green_floor1"),
				getSpriteIndex("red_down"), getSpriteIndex("blue_down"), getSpriteIndex("brown_down"),getSpriteIndex("green_down"),
				getSpriteIndex("red_door_open"), getSpriteIndex("blue_door_open"), getSpriteIndex("brown_door_open"),getSpriteIndex("green_door_open"),
			];
		
		if(stairsDown == null)
			stairsDown = [getSpriteIndex("red_down"), getSpriteIndex("blue_down"), getSpriteIndex("brown_down"), getSpriteIndex("green_down")];
		
		if(doors == null)
			doors = [getSpriteIndex("red_door_close"), getSpriteIndex("blue_door_close"), getSpriteIndex("brown_door_close"), getSpriteIndex("green_door_close")];
		
		if(openDoors == null)
			openDoors = [getSpriteIndex("red_door_open"), getSpriteIndex("blue_door_open"), getSpriteIndex("brown_door_open"), getSpriteIndex("green_door_open")];
		
		if (!inited) {
			if(Resources.walkableTiles == null)
				Resources.walkableTiles = new Array();
				
			if(Resources.seeThroughTiles == null)
				Resources.seeThroughTiles = new Array();
				
			if(Resources.walkableAndSeeThroughTiles == null)
				Resources.walkableAndSeeThroughTiles = new Array();
				
			if(Resources.solidAndBlockingTiles== null)
				Resources.solidAndBlockingTiles = new Array();
				
			if(Resources.doors == null)
				Resources.doors = new Array();
				
			if(Resources.stairsDown == null)
				Resources.stairsDown = new Array();
			
			
			Resources.walkableTiles = Resources.walkableTiles.concat(walkableAndSeeThroughTiles);
			Resources.seeThroughTiles = Resources.seeThroughTiles.concat(walkableAndSeeThroughTiles);
			Resources.walkableAndSeeThroughTiles = Resources.walkableAndSeeThroughTiles.concat(walkableAndSeeThroughTiles);
			Resources.solidAndBlockingTiles = Resources.solidAndBlockingTiles.concat(solidAndBlockingTiles);
			Resources.doors = Resources.doors.concat(doors).concat(openDoors);
			Resources.stairsDown = Resources.stairsDown.concat(stairsDown);
			inited = true;
		}
	}
}
class SpriteCorpses extends HxlSpriteSheet { 
	static var _spriteNames:Array<Array<String>>;
	public static var instance = new SpriteCorpses();
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				["big_skull","small_skull"]
			];
		spriteNames = _spriteNames;
		super(0);
	} 
}
class SpriteSpells extends HxlSpriteSheet { 
	static var _spriteNames:Array<Array<String>>;
	public static var instance = new SpriteSpells();
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				["freeze", "fireball", "berserk", "enfeeble_monster", "bless_weapon", "haste", "shadow_walk"],
				["charm_monster", "polymorph", "sleep", "fear", "magic_mirror", "stone_skin", "blink"],
				["magic_armor", "pass_wall", "teleport", "reveal_map", "heal"]			
			];
		spriteNames = _spriteNames;
		super(0);
	} 
}
class SpriteDecorations extends HxlSpriteSheet { 
	static var _spriteNames:Array<Array<String>>;
	public static var instance = new SpriteDecorations();
	
	public static var wall = ["pic0", "pic1", "wall_pile", "wall_skull", "wall_skeleton", "tapestry0", "tapestry1", "tapestry2", "tapestry3", "crack0", "crack1", "wall_blood0", "wall_blood1", "wall_green_blood0", "wall_green_blood1", "wall_green_blood2"];
	public static var floor = ["floor_pile", "floor_skulls", "floor_skeleton", "floor_crack0", "floor_crack1", "floor_crack2", "floor_blood0", "floor_blood1", "floor_blood2", "floor_green_blood0", "floor_green_blood1", "floor_green_blood2", "rocks0", "rocks1", "baricade0", "baricade1", "baricade2"];
	
	// requires special handling for generating good looking carpet strips
	public static var carpet = ["carpet0", "carpet1", "carpet2", "carpet3"];
	
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				wall.concat(["blank0", "blank1", "blank2", "blank3", "blank4"]),
				floor.concat(carpet)
			];
		spriteNames = _spriteNames;
		super(0);
	} 
	public static function getIcon(IconName:String, Size:Int, Zoom:Float):HxlSprite {
		return HxlSpriteSheet.getSprite(SpriteDecorations, instance.getSpriteIndex(IconName), Size, Zoom);
	}
}
class UiBeltVertical extends HxlSpriteSheet {
	static var _spriteNames:Array<Array<String>>;
	public static var instance = new UiBeltVertical();
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				["belt_vert_metal","belt_vert_metal_leather"]
			];
		spriteNames = _spriteNames;
		super(0);
	}
}

class MobileUiBeltVertical extends HxlSpriteSheet {
	static var _spriteNames:Array<Array<String>>;
	public static var instance = new MobileUiBeltVertical();
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				["belt_vert_metal","belt_vert_metal_leather"]
			];
		spriteNames = _spriteNames;
		super(0);
	}
}

class SpriteCursor extends HxlSpriteSheet { 
	static var _spriteNames:Array<Array<String>>;
	public static var instance = new SpriteCursor();
	public function new() {
		if (_spriteNames ==null)
			_spriteNames = [
				["up","diagonal"]
			];
		spriteNames = _spriteNames;
		super(0);
	}
}

class CqResources extends Resources {}
