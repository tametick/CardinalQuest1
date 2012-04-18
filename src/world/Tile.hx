package world;

import haxel.HxlGraphics;
import haxel.HxlTilemap;
import haxel.HxlUtil;

import data.Resources;
import data.Configuration;

import flash.geom.Point;
import flash.geom.Rectangle;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.MethodActuator;

import cq.CqResources;

class Tile extends HxlTile {
	public var actors:Array<Actor>;
	public var loots:Array<Loot>;
	public var level:Level;
	public var timesUncovered:Int;
	public var visAmount:Float;
	
	public function new(?X:Int = 0, ?Y:Int = 0, ?Rect:Rectangle = null) {
		super(X, Y, Rect);
		
		actors = new Array<Actor>();
		loots = new Array<Loot>();
		timesUncovered = 0;
		visAmount = 0.0;
	}
	
	public override function setDataNum(DataNum:Int):Int {
		var ret = super.setDataNum(DataNum);
	
		blocksMovement = !HxlUtil.contains(Resources.walkableTiles.iterator(), dataNum);
		blocksView = !HxlUtil.contains(Resources.seeThroughTiles.iterator(), dataNum);
		isStairs = HxlUtil.contains(SpriteTiles.stairsDown.iterator(), dataNum);
		isDoor = HxlUtil.contains(SpriteTiles.doors.iterator(), dataNum);
		
		return ret;
	}
	
	public function colorTo(ToColor:Int, Speed:Float) {
		var FromColor:Int = HxlUtil.colorRGB(_color)[0];
		
		if ( FromColor != ToColor ) {
			if ( Configuration.mobile || Math.abs( FromColor - ToColor ) < 5 ) {
				setColor(HxlUtil.colorInt(ToColor, ToColor, ToColor));
			} else {
				Actuate.update(colorTween, Speed, [FromColor], [ToColor]);
			}
		}
	}

	function colorTween(params:Dynamic) {
		if (params == null)
			return;
		
		var col = Math.round(cast(params, Float));
		setColor( HxlUtil.colorInt(col, col, col) );
	}
}
