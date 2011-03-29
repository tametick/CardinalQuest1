package world;

import haxel.HxlTilemap;
import haxel.HxlUtil;

import data.Resources;

import flash.geom.Rectangle;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.MethodActuator;

class Tile extends HxlTile
{
	public var actors:Array<Actor>;
	public var loots:Array<Loot>;
	public var level:Level;
	
	override public function isBlockingMovement():Bool {
		return false;
		//return !HxlUtil.contains(Resources.walkableTiles, dataNum);
	}
	
	override public function isBlockingView():Bool {
		return false;
		//return !HxlUtil.contains(Resources.seeThroughTiles, dataNum);
	}
	
	public function new(?X:Int = 0, ?Y:Int = 0, ?Rect:Rectangle = null) {
		super(X, Y, Rect);
		
		actors = new Array<Actor>();
		loots = new Array<Loot>();
	}
	
	public function colorTo(ToColor:Int, Speed:Float):Void {
		var self = this;
		Actuate.update(self.colorTween, Speed, {Color: HxlUtil.colorRGB(_color)[0]}, {Color: ToColor});
	}

	function colorTween(params:Dynamic):Void {
		setColor( HxlUtil.colorInt(params.Color, params.Color, params.Color) );
	}
}