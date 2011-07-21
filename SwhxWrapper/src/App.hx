package ;
import haxe.io.Bytes;
import haxe.remoting.Context;
import swhx.Connection;
import swhx.Window;

/**
 * ...
 * @author axel huizinga - axel@cunity.me
 */

class App 
{
	static var cnx:Connection;
	
	static function main() 
	{
		#if neko
		neko.Lib.print('hello world');
		
		swhx.Application.init();
        // create a 400x300 window with title "My Application"
        var window = new swhx.Window("SwhxDevel",800,640, swhx.Window.WF_TRANSPARENT);
        // create an incoming communication Server
        var context = new haxe.remoting.Context();
		context.addObject("App", App); 
				
        // create a flash object inside this window 
		var flash = new swhx.Flash(window, context);
		flash.onConnected = function() {
			trace('hello world');
		   // connect to flash
		   var cnx = swhx.Connection.flashConnect(flash);
		   // call Flash.test(5,7)
		   var r : Int = cnx.Client.test.call([5,7]);
		   // display result
		   //systools.Dialogs.message("Result","The result is "+r,false);
		  // systools.Dialogs.message("DumpLayout:", cnx.Flash.dumpLayout.call([]), false);
		   //trace( cnx.Flash.dumpLayout.call([]));
		}
        // set the HTML attributes of this flash object
        flash.setAttribute("src", "ui.swf");
		flash.setAttribute("id","ui");
        // activate the Client object
        flash.start();		

        // display the window
		window.resizable = true;	
        window.visible = true;
		//window.resize();
		 window.width = 801; 
        // enter the system event loop (will exit when window is closed)
        swhx.Application.loop();
        // cleanup SWHX properly
        swhx.Application.cleanup();
		#end

		
	}
	
	static function exit(a:Dynamic=null)
	{
		trace(a);
		swhx.Application.exitLoop();
	}
	
}