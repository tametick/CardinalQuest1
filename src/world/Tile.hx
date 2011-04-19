package world;

import haxel.HxlGraphics;
import haxel.HxlTilemap;
import haxel.HxlUtil;

import data.Resources;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.MethodActuator;

class Tile extends HxlTile
{
	public var actors:Array<Actor>;
	public var loots:Array<Loot>;
	public var decorations:Array<Decoration>;
	public var level:Level;
	
	override public function isBlockingMovement():Bool {
		return !HxlUtil.contains(Resources.walkableTiles.iterator(), dataNum);
	}
	
	override public function isBlockingView():Bool {
		return !HxlUtil.contains(Resources.seeThroughTiles.iterator(), dataNum);
	}
	
	public function new(?X:Int = 0, ?Y:Int = 0, ?Rect:Rectangle = null) {
		super(X, Y, Rect);
		
		actors = new Array<Actor>();
		loots = new Array<Loot>();
		decorations = new Array<Decoration>();
	}
	
	public function colorTo(ToColor:Int, Speed:Float):Void {
		var self = this;
		altBitmap = null;
		Actuate.update(self.colorTween, Speed, {Color: HxlUtil.colorRGB(_color)[0]}, {Color: ToColor})
			.onComplete(self.captureAltBitmap);
	}

	function colorTween(params:Dynamic):Void {
		setColor( HxlUtil.colorInt(params.Color, params.Color, params.Color) );
	}

	function captureAltBitmap():Void {
		if ( level == null ) return;
		var key:String = level.tileGraphicName+"-"+dataNum+"-"+_color+"-"+_alpha;
		if ( HxlGraphics.checkBitmapCache(key) ) {
			altBitmap = HxlGraphics.getBitmap(key);
		} else {
			HxlGraphics.addBitmapData(level.getTileBitmap(mapX, mapY), key);
			altBitmap = HxlGraphics.getBitmap(key);
		}
	}
}
