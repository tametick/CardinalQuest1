package cq.ui;

import haxel.HxlUtil;
import world.GameObject;
import data.Configuration;
import cq.CqResources;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.MethodActuator;
class CqDecoration extends GameObjectImpl {
	public static function randomFloorIndex():Int
	{
		var spriteName:String = SpriteDecorations.floor[Std.int(Math.random() * (SpriteDecorations.floor.length - 1))];
		return SpriteDecorations.instance.getSpriteIndex( spriteName );
	}
	public static function randomWallIndex():Int
	{
		var spriteName:String = SpriteDecorations.wall[Std.int(Math.random() * (SpriteDecorations.wall.length - 1))];
		return SpriteDecorations.instance.getSpriteIndex( spriteName );
	}
}