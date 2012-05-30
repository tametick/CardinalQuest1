package cq;
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * ...
 * @author randomnine
 */

class SoftGlowFilter 
{
	public static function applyGlow( _target:BitmapData, _color:Int, _blurDist:Float, _alpha:Float ) {
		var glow:BitmapData = new BitmapData( _target.width, _target.height, true, (0x00FFFFFF & _color));
		
		for ( y in 0 ... _target.height ) {
			var minY:Int = Std.int( Math.max( 0, y - _blurDist ) );
			var maxY:Int = Std.int( Math.min( y + _blurDist + 1, _target.height ) );
			
			for ( x in 0 ... _target.width ) {
				var targetAlphaI:UInt = _target.getPixel32( x, y ) >> 24;
				if ( targetAlphaI < 250 ) {
					var glowAlpha:Float = 0;
					
					var minX:Int = Std.int( Math.max( 0, x - _blurDist ) );
					var maxX:Int = Std.int( Math.min( x + _blurDist + 1, _target.width ) );
					
					for ( by in minY ... maxY ) {
						for ( bx in minX ... maxX ) {
							var sourceAlphaI:UInt = _target.getPixel32( bx, by ) >> 24;
							if ( sourceAlphaI > 250 ) {
								var dist:Float = Math.sqrt( (bx - x) * (bx - x) + (by - y) * (by - y) );
								
								if ( dist < _blurDist ) {
									glowAlpha += (1.0 / 256.0) * ( 1.0 - dist / _blurDist ) * _alpha;
								}
							}
						}
					}
					
					var glowAlphaI:Int = Std.int(Math.min( glowAlpha * 255.0, 255 ) );
					glow.setPixel32( x, y, (0x00FFFFFF & _color) | (glowAlphaI << 24) );
				}
			}
		}
		
		// Composit back to target.
		_target.copyPixels( glow, glow.rect, new Point(0, 0), null, null, true);
//		_target.copyPixels( source, source.rect, new Point(0, 0) );
		
//		_target.fillRect( _target.rect, 0xFFFFFFFF );
		
		glow.dispose();
	}
}