package generators;
import flash.display.BitmapData;

class Perlin 
{
	public static function getNoiseMap(width:Int, height:Int, tileIndexes:Array<Int>, ?tileWeights:Array<Int> = null, ?jaggedness:Int = 4):Array<Array<Int>> {
		if (tileWeights != null) {
			var weightedTiles = new Array();
			var currentTile = 0;
			for (weight in tileWeights) {
				for(i in 0...weight)
					weightedTiles.push(tileIndexes[currentTile]);
				currentTile++;
			}
			tileIndexes = weightedTiles;
		}
		
		var bmpData:BitmapData = new BitmapData(width, height);
		var seed:Int = Math.round( Math.random()*10000);
		bmpData.perlinNoise(width/jaggedness , height/jaggedness , 8, seed, false, true, 7, true);
		var pixels = bmpData.getVector(bmpData.rect);
		
		var level:Array<Array<Int>> = new Array();
		for (y in 0...height) {
			level[y] = new Array();
		}
		
		var min = 10000;
		var max = 0;
		
		// get random noise
		for (i in 0...pixels.length) {
			var iy = Std.int(i/width);
			var ix = i % width;
			var val = pixels[i] & 0x0000ff;
			
			level[iy][ix] = val;
			
			if (val > max)
				max = val;
			if (val < min)
				min = val;
		}
		
		// normalize
		var maxDistance = max - min;
		var ratio = (maxDistance+1) / tileIndexes.length;
		for (y in 0...height)
			for (x in 0...width)
				level[y][x] = tileIndexes[Std.int( (level[y][x] - min)/ratio )];
		
		return level;
	}
	
}