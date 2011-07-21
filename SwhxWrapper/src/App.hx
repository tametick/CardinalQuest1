import haxe.io.Bytes;
import haxe.remoting.Context;
import swhx.Connection;
import swhx.Window;

class App {
	static var cnx:Connection;
	
	static function main() {
		#if neko
		swhx.Application.init();
		
        // create a window with title
        var window = new swhx.Window("Cardinal Quest",640,480, swhx.Window.WF_FULLSCREEN);
/*        
		// create an incoming communication Server
        var context = new haxe.remoting.Context();
		context.addObject("App", App); 
				
        // create a flash object inside this window 
		var flash = new swhx.Flash(window, context);
		flash.onConnected = function() {
			// connect to flash
			var cnx = swhx.Connection.flashConnect(flash);
			// call Flash.test(5,7)
			var r : Int = cnx.Client.test.call([5,7]);
			// display result
			//systools.Dialogs.message("Result","The result is "+r,false);
			// systools.Dialogs.message("DumpLayout:", cnx.Flash.dumpLayout.call([]), false);
			//trace( cnx.Flash.dumpLayout.call([]));
		}
	*/	
	
		var flash = new swhx.Flash(window);
	
        // set the HTML attributes of this flash object
        flash.setAttribute("src", "cq.swf");
		flash.setAttribute("id","cq-1.0");
        
		// activate the Client object
        flash.start();		
		window.visible = true;
		
		window.onRightClick = function () {
			trace("onRightClick!");
			// toggle full screen mode:
			window.fullscreen = !window.fullscreen;
			// don't forward this event to Flash:
			return false;
		}
		
		window.fullscreen =true;
		
        // enter the system event loop (will exit when window is closed)
        swhx.Application.loop();
        // cleanup SWHX properly
        swhx.Application.cleanup();
		#end
	}
	
	static function exit(a:Dynamic=null) {
		swhx.Application.exitLoop();
	}
	
}