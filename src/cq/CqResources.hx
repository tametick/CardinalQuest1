package cq;

import flash.text.Font;
import flash.media.Sound;

import data.Configuration;
import haxel.HxlSpriteSheet;

class FontGeo extends Font { public function new(){super();} }
class SpriteEffects extends HxlSpriteSheet { public function new(){super();} }
class SpriteItems extends HxlSpriteSheet { public function new(){super();} }
class SpriteMonsters extends HxlSpriteSheet { public function new(){super();} }
class SpritePlayer extends HxlSpriteSheet { public function new(){super();} }
class SpriteTiles extends HxlSpriteSheet { 
	public function new() { 
		spriteNames = [
			["red_up","red_down","red_floor0","red_floor1","red_wall0","red_wall1","red_wall2","red_wall3","red_wall4","red_door_close","red_door_open"], 
			["blue_up", "blue_down", "blue_floor0", "blue_floor1", "blue_wall0", "blue_wall1", "blue_wall2", "blue_wall3", "blue_wall4", "blue_door_close", "blue_door_open"], 
			["brown_up","brown_down","brown_floor0","brown_floor1","brown_wall0","brown_wall1","brown_wall2","brown_wall3","brown_wall4","brown_door_close","brown_door_open"], 
		];
		super();
	}
}
class SpriteCorpses extends HxlSpriteSheet { public function new(){super();} }

class CqResources 
{
	public static var x:Int;
}
