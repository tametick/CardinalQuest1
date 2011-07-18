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
		var self = this;
		Actuate.update(self.colorTween, Speed, {Color: HxlUtil.colorRGB(_color)[0]}, {Color: ToColor})
			.onComplete(self.captureAltBitmap);
	}
	public function colorTween(params:Dynamic) {
		setColor( HxlUtil.colorInt(params.Color, params.Color, params.Color) );
	}
	public function captureAltBitmap()
	{
		//on color tween
	}
}