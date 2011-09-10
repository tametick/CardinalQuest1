package data;

/**
 * The concept is as follows:
 * 1. We save the game each time we descend a level
 * 2. We delete the save-game when we die..
 * 3. We delete the save-game when we start a new game
 * 4. We load the save game in gamestate if we detect a saved game
 * 
 * Constructed from the following sources:
 * http://haxe.org/api/flash/sharedobject
 *		http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/SharedObject.html
 *		http://lists.motion-twin.com/pipermail/haxe/2008-January/013876.html <-- Gaaah!
 *		This creates a singleton, so memory leaks should not be an easy
 *		Error handling added
 *
 * @author TjD__
 */

import flash.net.SharedObject;
import cq.CqWorld;
import Reflect;
import data.Registery;
import cq.CqActor;

class SaveLoad 
{
	private static var so:SharedObject;

	/*
	public static function loadLevel():Level
	{
		// For now only flash is supported
		if ( Configuration.flash )
		{
		  getSO();
		  if( so != null )
			return so.data.level;
		}
		return null;
	}
	*/
	
	public static function loadWorld():CqWorld
	{
		/* For now only flash is supported */
		if ( Configuration.flash )
		{
		  getSO();
		  if( so != null )
			return so.data.world;
		}
		return null;		
	}

	public static function loadPlayer():CqPlayer
	{
		/* For now only flash is supported */
		if ( Configuration.flash )
		{
		  getSO();
		  if( so != null )
			return so.data.player;
		}
		return null;		
	}	
	
	public static function deleteSaveGame( )
	{
		/* For now only flash is supported */
		if ( Configuration.flash ) 		
		{
			getSO();
			if( so != null )
			{
				so.clear();	
			}
		}
	}	
	
	public static function saveGame( )
	{

		//Dont store the initial level or if the game is not yet fully initialized
		if ( Registery.world == null )
			return;
			
		//Curious..
		trace( "Level: " + Registery.world.currentLevelIndex );
		
		/* For now only flash is supported */
		if ( Configuration.flash ) 
		{
			try
			{
				getSO();
				so.clear();
				so.data.world  = Registery.world;
				so.data.player = Registery.player;
				so.data.depth = Registery.world.currentLevelIndex;
				so.flush();
			}
			catch( msg:Dynamic )
			{
				if ( Configuration.debug )
					trace( "Could not store level: " + Std.string(msg)); 
			}
		}	
	}
		
	public static function hasSaveGame():Bool 
	{
		/* For now only flash is supported */
		if ( Configuration.flash )
		{
			getSO();
			if( so != null )
				if ( Reflect.hasField( so.data , "depth" )  )
				{
					if( Configuration.debug )
						trace( "Loaded Game at level:" + so.data.depth );
					return true;	
				}
		}
		return false;
	}
			
	private static function getSO()
	{
	  //Initialize so if that wasnt done yet
	  try
	  {	  
	    if( so == null )
	      so = so = SharedObject.getLocal("cq");
	    return so;
	  }
	  catch( msg:Dynamic )
	  {
		if ( Configuration.debug )
		  trace( "Could not access local shared object: " + Std.string(msg)); 		  
		return null;
	  }
	}
}