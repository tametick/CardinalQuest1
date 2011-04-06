package haxel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;

import haxel.HxlObject;

class HxlDialog extends HxlGroup
{

	var background:HxlSprite;

	/* These are used to set a position for the dialog and all of its children
	 * to be moved to on the next call to update. Use these when moving a 
	 * dialog rather than setting x and y!
	 */
	public var targetX:Float;
	public var targetY:Float;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super();
		x = X;
		y = Y;
		width = Width;
		height = Height;
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		targetX = X;
		targetY = Y;
		_dialog = true;
	}

	public override function add(Object:HxlObjectI,?ShareScroll:Bool=true):HxlObjectI {
		super.add(Object, ShareScroll);
		return Object;
	}

	public override function replace(OldObject:HxlObject,NewObject:HxlObject):HxlObject {
		NewObject.scrollFactor.x = NewObject.scrollFactor.y = 0;
		super.replace(OldObject, NewObject);
		return NewObject;
	}

	public function setBackgroundColor(Color:Int, ?CornerRadius:Float=0.0):Void {
		if ( background == null ) {
			background = new HxlSprite(0, 0);
			background.zIndex = -1;
			add(background);
		}
		if ( CornerRadius <= 0.0 ) {
			background.createGraphic(Std.int(width), Std.int(height), Color);
		} else {
			var target:Shape = new Shape();
			target.graphics.beginFill(Color);
			target.graphics.drawRoundRect(0, 0, width, height, CornerRadius, CornerRadius);
			target.graphics.endFill();
			var bmp:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0x0);
			bmp.draw(target);
			background.width = width;
			background.height = height;
			background.pixels = bmp;
			target = null;
			bmp = null;
		}
	}

	public function setBackgroundSprite(Sprite:HxlSprite):Void {
		if ( background == null ) {
			background = new HxlSprite(0, 0);
			background.zIndex = -1;
			add(background);
		}
		background.pixels = Sprite.pixels;
	}

	public function setBackgroundGraphic(Graphic:Class<Bitmap>, ?Tiled:Bool=false, ?CornerRadius:Float=0.0):Void {
		if ( background == null ) {
			background = new HxlSprite(0, 0);
			background.zIndex = -1;
			add(background);
		}
		if ( Tiled ) {
			background.width = width;
			background.height = height;
			var source:BitmapData = Type.createInstance(Graphic, []).bitmapData;
			var targetBmp:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0x0);
			var targetShape:Shape = new Shape();
			targetShape.graphics.beginBitmapFill(source, null, true);
			// drawRoundRect below if using corner radius
			if ( CornerRadius <= 0.0 ) {
				targetShape.graphics.drawRect(0, 0, width, height);
			} else {
				targetShape.graphics.drawRoundRect(0, 0, width, height, CornerRadius, CornerRadius);
			}
			targetShape.graphics.endFill();
			targetBmp.draw(targetShape);
			background.width = width;
			background.height = height;
			background.pixels = targetBmp;
			targetBmp = null;
			targetShape = null;
			source = null;
		} else {
			background.loadGraphic(Graphic);
		}
	}

	public function setBackgroundKey(Key:String):Void {
		if ( background == null ) {
			background = new HxlSprite(0, 0);
			background.zIndex = -1;
			add(background);
		}
		background.loadCachedGraphic(Key);
	}

	override function updateMembers():Void {
		var mx:Float = Math.NaN;
		var my:Float = Math.NaN;
		var moved:Bool = false;
		if ((x != _last.x) || (y != _last.y)) {
			moved = true;
			mx = x - _last.x;
			my = y - _last.y;
		}
		var o:HxlObject;
		var l:Int = members.length;
		for (i in 0...l) {
			o = cast( members[i], HxlObject);
			if ((o != null) && o.exists) {
				if (moved) {
					if ( o._dialog ) {
						var dlgO:HxlDialog = cast(o, HxlDialog);
						dlgO.targetX += mx;
						dlgO.targetY += my;
					} else if (o._group) {
						o.reset(o.x+mx,o.y+my);
					} else {
						o.x += mx;
						o.y += my;
					}
				}
				if (o.active) {
					o.update();
					HxlGraphics.numUpdates++;
				}
				/*
				if (moved && o.solid) {
					o.colHullX.width += ((mx>0)?mx:-mx);
					if ( mx < 0) {
						o.colHullX.x += mx;
					}
					o.colHullY.x = x;
					o.colHullY.height += ((my>0)?my:-my);
					if (my < 0) {
						o.colHullY.y += my;
					}
					o.colVector.x += mx;
					o.colVector.y += my;
				}
				*/
			}
		}
	}

	public override function update():Void
	{
		saveOldPosition();
		if ( targetX != x || targetY != y ) {
			x = targetX;
			y = targetY;
		}
		if ( mountObject != null ) {
			x = mountObject.x + mountOffsetX;
			y = mountObject.y + mountOffsetY;
		}
		updateMotion();
		updateMembers();
		if ( !initialized ) initialized = true;
	}

}
