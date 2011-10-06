package world;

import haxel.HxlGraphics;
import haxel.HxlTilemap;
import haxel.HxlUtil;

import data.Resources;

import flash.geom.Point;
import flash.geom.Rectangle;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.MethodActuator;

class Tile extends HxlTile {
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
	
	public function colorTo(ToColor:Int, Speed:Float) {
		Actuate.update(colorTween, Speed, [HxlUtil.colorRGB(_color)[0]], [ToColor]);
	}

	function colorTween(params:Dynamic) {
		var col = Math.round(cast(params, Float));
		setColor( HxlUtil.colorInt(col, col, col) );
	}
}
