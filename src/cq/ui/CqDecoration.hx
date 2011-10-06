package cq.ui;

import haxel.HxlUtil;
import world.Decoration;
import world.GameObject;
import data.Configuration;
import cq.CqResources;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.MethodActuator;
class CqDecoration extends GameObjectImpl, implements Decoration{
	public function new(X:Float, Y:Float, ?spriteName:String) {
		super(X, Y, 0);
		loadGraphic(SpriteDecorations, true, false, Configuration.tileSize, Configuration.tileSize, false, 2.0, 2.0);
		if (spriteName == null)
			setFrame(SpriteDecorations.instance.getSpriteIndex( randomWall() ));
		else
			setFrame(SpriteDecorations.instance.getSpriteIndex( spriteName ));
		
	}
	public static function randomFloor():String
	{
		return ( SpriteDecorations.floor[Std.int(Math.random() * (SpriteDecorations.floor.length - 1))]);
	}
	public static function randomWall():String
	{
		return (SpriteDecorations.wall[Std.int(Math.random() * (SpriteDecorations.wall.length - 1))]);
	}
	public function colorTo(ToColor:Int, Speed:Float) {
		Actuate.update(colorTween, Speed, [HxlUtil.colorRGB(_color)[0]], [ToColor]);
	}
	public function colorTween(params:Dynamic) {
		var col = Math.round(cast(params, Float));
		setColor( HxlUtil.colorInt(col, col, col) );
		// fixme - this doesn't actually change the color of the decoration drawn
	}

}