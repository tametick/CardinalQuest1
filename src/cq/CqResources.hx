package cq;

import flash.text.Font;
import flash.media.Sound;

import data.Resources;
import haxel.HxlSpriteSheet;

class FontGeo extends Font { public function new() { super(); } }

class SpriteEffects extends HxlSpriteSheet { 
	public static var instance = new SpriteEffects();
	public function new() {
		spriteNames = [
			["small_scratch","big_scratch"]
		];
		super(0);
	} 
}
class SpriteItems extends HxlSpriteSheet { 
	public static var instance = new SpriteItems();
	
	public var potions:Array<String>;
	public function new() {
		potions = ["purple_potion", "green_potion", "blue_potion", "yellow_potion", "red_potion"];
		
		spriteNames = [
			["amulet","boots","leather_armor","brestplate","chest","glove","cap","ring","braclet","winged_sandles"],
			["staff","dagger","short_sword","long_sword"].concat(potions).concat(["helm"]),
		];
		super(0);
	} 	
}
class SpriteMonsters extends HxlSpriteSheet { 	
	public static var instance = new SpriteMonsters();
	public static var kobolds = ["kobold_spear", "kobold_knives", "kobold_mage",];
	public static var werewolves = ["werewolf_gray", "werewolf_blue", "werewolf_purple"];
	public static var bandits = ["bandit_long_swords", "bandit_short_swords", "bandit_single_long_sword", "bandit_knives"];
	public static var minotauers = ["minotauer", "minotauer_axe", "minotauer_sword"];
	public static var succubi = ["succubus", "succubus_staff", "succubus_whip", "succubus_scepter", ];
	public static var spiders = ["spider_yellow", "spider_red", "spider_gray", "spider_green"];
	public function new() {
		spriteNames = [
			kobolds.concat(["kobold_blank"]),
			werewolves.concat(["werewolf_blank"]),
			bandits,
			minotauers.concat(["minotauer_blank"]),
			succubi,
			spiders,
		];
		super(0);
	} 
}

class SpritePlayer extends HxlSpriteSheet { 
	public static var instance = new SpritePlayer();
	public function new() { 
		spriteNames = [
			["berserk_fighter", "fighter", "wizard", "thief", "cloaked_thief"],
			["berserk_fighter_long_sword", "fighter_long_sword", "wizard_long_sword","thief_long_sword","cloaked_thief_long_sword"],
			["berserk_fighter_short_sword", "fighter_short_sword", "wizard_short_sword","thief_short_sword","cloaked_thief_short_sword"],
			["berserk_fighter_staff", "fighter_staff", "wizard_staff","thief_staff","cloaked_thief_staff"],
			["berserk_fighter_dagger", "fighter_dagger", "wizard_dagger","thief_dagger","cloaked_thief_dagger"]
		];
		
		super(0); 
	} 
}

class SpriteTiles extends HxlSpriteSheet { 
	public static var instance = new SpriteTiles();
	static var inited = false;
	public var walkableAndSeeThroughTiles:Array<Int>;
	public var solidAndBlockingTiles:Array<Int>;
	public var stairsDown:Array<Int>;
	public var doors:Array<Int>;
	public var openDoors:Array<Int>;
	
	public function new() { 
		// important: one color-scheme per line (used implicitly in level generator)
		spriteNames = [
			["red_up","red_down","red_floor0","red_floor1","red_wall0","red_wall1","red_wall2","red_wall3","red_wall4","red_door_close","red_door_open"], 
			["blue_up", "blue_down", "blue_floor0", "blue_floor1", "blue_wall0", "blue_wall1", "blue_wall2", "blue_wall3", "blue_wall4", "blue_door_close", "blue_door_open"], 
			["brown_up","brown_down","brown_floor0","brown_floor1","brown_wall0","brown_wall1","brown_wall2","brown_wall3","brown_wall4","brown_door_close","brown_door_open"], 
		];
		super(1);
		
		solidAndBlockingTiles = [
			getSpriteIndex("red_wall0"),getSpriteIndex("red_wall1"),getSpriteIndex("red_wall2"),getSpriteIndex("red_wall3"),getSpriteIndex("red_wall4"),getSpriteIndex("red_door_close"),
			getSpriteIndex("blue_wall0"),getSpriteIndex("blue_wall1"),getSpriteIndex("blue_wall2"),getSpriteIndex("blue_wall3"),getSpriteIndex("blue_wall4"),getSpriteIndex("blue_door_close"),
			getSpriteIndex("brown_wall0"),getSpriteIndex("brown_wall1"),getSpriteIndex("brown_wall2"),getSpriteIndex("brown_wall3"),getSpriteIndex("brown_wall4"),getSpriteIndex("brown_door_close"),
		];
		walkableAndSeeThroughTiles = [
			getSpriteIndex("red_floor0"), getSpriteIndex("blue_floor0"), getSpriteIndex("brown_floor0"),
			getSpriteIndex("red_floor1"), getSpriteIndex("blue_floor1"), getSpriteIndex("brown_floor1"),
			getSpriteIndex("red_down"), getSpriteIndex("blue_down"), getSpriteIndex("brown_down"),
			getSpriteIndex("red_door_open"), getSpriteIndex("blue_door_open"), getSpriteIndex("brown_door_open"),
		];
		stairsDown = [getSpriteIndex("red_down"), getSpriteIndex("blue_down"), getSpriteIndex("brown_down")];
		doors = [getSpriteIndex("red_door_close"), getSpriteIndex("blue_door_close"), getSpriteIndex("brown_door_close")];
		openDoors = [getSpriteIndex("red_door_open"), getSpriteIndex("blue_door_open"), getSpriteIndex("brown_door_open")];
		
		if (!inited) {
			Resources.walkableTiles = Resources.walkableTiles.concat(walkableAndSeeThroughTiles);
			Resources.seeThroughTiles = Resources.seeThroughTiles.concat(walkableAndSeeThroughTiles);
			Resources.walkableAndSeeThroughTiles = Resources.walkableAndSeeThroughTiles.concat(walkableAndSeeThroughTiles);
			Resources.solidAndBlockingTiles = Resources.solidAndBlockingTiles.concat(solidAndBlockingTiles);
			inited = true;
		}
	}
}
class SpriteCorpses extends HxlSpriteSheet { 
	public static var instance = new SpriteCorpses();
	public function new() {
		spriteNames = [
			["big_skull","small_skull"]
		];
		super(0);
	} 
}

class SpriteSpells extends HxlSpriteSheet { 
	public static var instance = new SpriteSpells();
	public function new() {
		spriteNames = [
			["freeze", "fireball", "berserk", "enfeeble_monster", "bless_weapon", "haste", "shadow_walk"]
		];
		super(0);
	} 
}
class SpriteDecorations extends HxlSpriteSheet { 
	public static var instance = new SpriteDecorations();
	
	public static var wall = ["pic0", "pic1", "wall_pile", "wall_skull", "wall_skeleton", "tapestry0", "tapestry1", "tapestry2", "tapestry3", "crack0", "crack1", "wall_blood0", "wall_blood1", "wall_green_blood0", "wall_green_blood1", "wall_green_blood2"];
	public static var floor = ["floor_pile", "floor_skulls", "floor_skeleton", "floor_crack0", "floor_crack1", "floor_crack2", "floor_blood0", "floor_blood1", "floor_blood2", "floor_green_blood0", "floor_green_blood1", "floor_green_blood2", "rocks0", "rocks1", "baricade0", "baricade1", "baricade2"];
	
	// requires special handling for generating good looking carpet strips
	public static var carpet = ["carpet0", "carpet1", "carpet2", "carpet3"];
	
	public function new() {
		spriteNames = [
			wall.concat(["blank0", "blank1", "blank2", "blank3", "blank4"]),
			floor.concat(carpet)
		];
		super(0);
	} 
}

class CqResources extends Resources {}
