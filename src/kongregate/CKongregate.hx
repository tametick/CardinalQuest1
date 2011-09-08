package kongregate;

import data.Configuration;

/**
 * http://www.cathelius.co.uk/forum_thread%26topic=257
 * @author TjD__
 */

class CKongregate 
{
    var kongregate: Dynamic;

    public function new()
    {
        kongregate = null;
            
        var parameters = flash.Lib.current.loaderInfo.parameters;

        var url: String;
        
        url = parameters.api_path;
        
        if(url == null)
            url = "http://www.kongregate.com/flash/API_AS3_Local.swf";
        
        var request = new flash.net.URLRequest(url);             
        
        var loader = new flash.display.Loader();
        loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, OnLoadComplete);
        loader.load(request);

        flash.Lib.current.addChild(loader);
    }

    function OnLoadComplete(e: flash.events.Event)
    {
        try
        {
			//Get it
            kongregate = e.target.content;
			//Connect it
            kongregate.services.connect();
        }
        catch(msg: Dynamic)
        {
            kongregate = null;
			if ( Configuration.debug ) {
				trace( "Connection to Kongregate failed: " ); trace( Std.string(msg) );			
			}
			return;
        }
		if ( Configuration.debug ) {
			trace( "Connection to Kongregate succeeded." );
		}		
    }

    public function SubmitScore(score: Float, mode: String)
    {
        try
        {		
			if(kongregate != null)
			{
				kongregate.scores.submit(score, mode);
				if ( Configuration.debug ) {
					trace("Submitted score " + score + " in '" + mode + "' mode.");
				}				
			}
		}
        catch(msg: Dynamic)
        {
            kongregate = null;
			if ( Configuration.debug ) {
				trace( "Could not submit score to Kongregrate!" ); trace( Std.string(msg) );
			}	
        }		
    }

    public function SubmitStat(name: String, stat: Float)
    {
        try
        {			
			if(kongregate != null)
			{
				kongregate.stats.submit(name, stat);
				if ( Configuration.debug ) {
					trace("Submitted stat '" + name + "' : " + stat);
				}
				
			}
		}
        catch(msg: Dynamic)
        {
            kongregate = null;
			if ( Configuration.debug ) {
				trace( "Could not submit stat to Kongregrate!" ); trace( Std.string(msg) );
			}			
        }			
    }
}
