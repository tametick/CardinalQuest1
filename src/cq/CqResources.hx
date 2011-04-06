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
	public function new() {
		spriteNames = [
			["amulet","boots","leather_armor","brestplate","chest","glove","cap","ring","braclet","winged_sandles"],
			["staff","dagger","short_sword","long_sword","purple_potion","green_potion","blue_potion","yellow_potion","red_potion","helm"],
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
	public function new() { 
		spriteNames = [
			["red_up","red_down","red_floor0","red_floor1","red_wall0","red_wall1","red_wall2","red_wall3","red_wall4","red_door_close","red_door_open"], 
			["blue_up", "blue_down", "blue_floor0", "blue_floor1", "blue_wall0", "blue_wall1", "blue_wall2", "blue_wall3", "blue_wall4", "blue_door_close", "blue_door_open"], 
			["brown_up","brown_down","brown_floor0","brown_floor1","brown_wall0","brown_wall1","brown_wall2","brown_wall3","brown_wall4","brown_door_close","brown_door_open"], 
		];
		super(1);
		
		walkableAndSeeThroughTiles = [
			getSpriteIndex("red_floor0"), getSpriteIndex("blue_floor0"), getSpriteIndex("brown_floor0"),
			getSpriteIndex("red_floor1"), getSpriteIndex("blue_floor1"), getSpriteIndex("brown_floor1"),
			getSpriteIndex("red_down"), getSpriteIndex("blue_down"), getSpriteIndex("brown_down"),
		];
		
		if (!inited) {
			Resources.walkableTiles = Resources.walkableTiles.concat(walkableAndSeeThroughTiles);
			Resources.seeThroughTiles = Resources.seeThroughTiles.concat(walkableAndSeeThroughTiles);
			Resources.walkableAndSeeThroughTiles = Resources.walkableAndSeeThroughTiles.concat(walkableAndSeeThroughTiles);
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
			[]
		];
		super(0);
	} 
}
class SpriteDecorations extends HxlSpriteSheet { 
	public static var instance = new SpriteDecorations();
	public function new() {
		spriteNames = [
			[]
		];
		super(0);
	} 
}


class CqResources extends Resources { }
