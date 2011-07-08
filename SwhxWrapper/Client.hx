package ;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
/**
 * ...
 * @author axel huizinga - axel@cunity.me
 */

class Client 
{

	static var cnx: swhx.Connection;
	static  var dI:Sprite = new Sprite();
	
	static function main() {
        // draw a red rectangular shape		
		//#if flash
		cnx = swhx.Connection.desktopConnect();
        var tf:TextField = new TextField();
		tf.autoSize  = TextFieldAutoSize.LEFT;
		var format:TextFormat = tf.defaultTextFormat;
		format.font = 'Arial';
		format.size = 24;
		tf.defaultTextFormat = format;
		tf.text = 'Hello World\n Click2Close';
		
		tf.textColor = 0xfffff;
		tf.x = 10;
		tf.y = 100;
		
        flash.Lib.current.addChild(dI);
        flash.Lib.current.addChild(tf);
        var gfx = dI.graphics;
        gfx.moveTo(10, 10);
		gfx.lineStyle(10,  0xff00ff);
        gfx.beginFill(0xFF0000,100);
        gfx.lineTo(200,10);
        gfx.lineTo(200,200);
        gfx.lineTo(10,100);
        gfx.endFill();
		trace('hello world');
		dI.addEventListener(MouseEvent.CLICK, exit);
    }
	
	static function exit(evt:MouseEvent)
	{
		cnx.App.exit.call(['clicked']);
	}
	
	static function test( a : Int, b : Int ) {
       return a + b;
   }
	
}