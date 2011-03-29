package cq;

import flash.text.Font;
import flash.media.Sound;

import data.Configuration;
import haxel.HxlSpriteSheet;

class FontGeo extends Font { public function new(){super();} }
class SpriteEffects extends HxlSpriteSheet { public function new(){super();} }
class SpriteItems extends HxlSpriteSheet { public function new(){super();} }
class SpriteMonsters extends HxlSpriteSheet { public function new(){super();} }

class SpritePlayer extends HxlSpriteSheet { 
	public function new() { 
		spriteNames = [
			["berserk_fighter", "figher", "wizard", "thief", "cloaked_thief"],
			["berserk_fighter_long_sword", "figher_long_sword", "wizard_long_sword","thief_long_sword","cloaked_thief_long_sword"],
			["berserk_fighter_short_sword", "figher_short_sword", "wizard_short_sword","thief_short_sword","cloaked_thief_short_sword"],
			["berserk_fighter_staff", "figher_staff", "wizard_staff","thief_staff","cloaked_thief_staff"],
			["berserk_fighter_dagger", "figher_dagger", "wizard_dagger","thief_dagger","cloaked_thief_dagger"]
		];
		
		super(); 
	} 
}

class SpriteTiles extends HxlSpriteSheet { 
	public var walkableAndSeeThroughTiles:Array<Int>;
	public function new() { 
		spriteNames = [
			["red_up","red_down","red_floor0","red_floor1","red_wall0","red_wall1","red_wall2","red_wall3","red_wall4","red_door_close","red_door_open"], 
			["blue_up", "blue_down", "blue_floor0", "blue_floor1", "blue_wall0", "blue_wall1", "blue_wall2", "blue_wall3", "blue_wall4", "blue_door_close", "blue_door_open"], 
			["brown_up","brown_down","brown_floor0","brown_floor1","brown_wall0","brown_wall1","brown_wall2","brown_wall3","brown_wall4","brown_door_close","brown_door_open"], 
		];
		super();
		
		walkableAndSeeThroughTiles = [
			getSpriteIndex("red_floor0"), getSpriteIndex("blue_floor0"), getSpriteIndex("brown_floor0"),
			getSpriteIndex("red_floor1"), getSpriteIndex("blue_floor1"), getSpriteIndex("brown_floor1"),
			getSpriteIndex("red_down"), getSpriteIndex("blue_down"), getSpriteIndex("brown_down"),
		];
	}
}
class SpriteCorpses extends HxlSpriteSheet { public function new(){super();} }

class CqResources { }
