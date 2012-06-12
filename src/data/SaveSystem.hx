package data;

import data.io.SaveGameIO;
import data.io.FlashSharedObjectIO;

import data.Registery;

/**
 * ...
 * @author randomnine
 */

class SaveSystem 
{
	public static function save() {
		var saveGameIO:SaveGameIO = new FlashSharedObjectIO();

		saveGameIO.startWrite();

		Registery.level.save( saveGameIO );
		Registery.player.save( saveGameIO );

		saveGameIO.completeWrite();
	}
	
	public static function getLoadIO() : SaveGameIO {
		return new FlashSharedObjectIO();
	}
}