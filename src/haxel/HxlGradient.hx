package haxel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape; 
import flash.display.GradientType; 
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;
import flash.geom.Matrix;

class HxlGradient {

	static public function Rect(Width:Int, Height:Int, Colors:Array<Int>, ?Ratios:Array<Int>=null, ?Alphas:Array<Float>=null, ?Rotation:Float=0.0):HxlSprite {
		var spr:HxlSprite = new HxlSprite();
		var type = GradientType.LINEAR; 
		var colors:Array<Int> = Colors; 
		var alphas:Array<Float>;
		if ( Alphas != null ) {
			alphas = Alphas;
			if ( Alphas.length < colors.length ) {
				var count = colors.length - Alphas.length;
				for ( i in 0...count ) {
					alphas.push(1.0);
				}
			}
		} else {
			alphas = new Array();
			for ( i in 0...colors.length ) {
				alphas.push(1.0);
			}
		}
		var ratios:Array<Int>;
		if ( Ratios != null ) {
			ratios = Ratios;
		} else {
			ratios = new Array();
			for ( i in 0...colors.length ) {
				ratios.push( Std.int(i * (255 / (colors.length - 1))) );
			}
		}
		var spreadMethod = SpreadMethod.PAD; 
		var interp = InterpolationMethod.LINEAR_RGB; 
		var focalPtRatio:Int = 0; 
 
		var matrix:Matrix = new Matrix(); 
		var boxWidth:Int = Width; 
		var boxHeight:Int = Height; 
		var boxRotation:Float = Rotation; //Math.PI/2; 
		var tx:Int = 0; 
		var ty:Int = 0; 
		matrix.createGradientBox(boxWidth, boxHeight, boxRotation, tx, ty); 
 
		var square:Shape = new Shape();
		square.graphics.beginGradientFill(type, colors, alphas, ratios, matrix, spreadMethod, interp, focalPtRatio); 
		square.graphics.drawRect(0, 0, Width, Height); 

		var bmp:Bitmap = new Bitmap(new BitmapData(Width, Height, true, 0x0));
		bmp.bitmapData.draw(square);
		spr.pixels = bmp.bitmapData;

		return spr;
	}

}