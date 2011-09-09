package cq;

import cq.CqResources;
import cq.CqItem;
import cq.CqSpell;
import cq.CqActor;
import cq.effects.CqEffectSpell;
import cq.ui.CqDecoration;
import cq.states.GameState;

import generators.BSP;
import world.World;
import world.Level;
import world.Mob;
import world.Loot;
import world.Tile;
import world.GameObject;
import world.Decoration;

import haxel.HxlSprite;
import haxel.HxlPoint;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlGraphics;
import haxel.HxlLog;

import data.Registery;
import data.Resources;
import data.Configuration;
import data.MusicManager;
import data.SaveLoad;

class CqWorld extends World {

	static public var actorAdded:Dynamic = null;

	var onNewLevel:List<Dynamic>;
	

	public function new() {
		super();

		onNewLevel = new List();
		CqSpellFactory.resetRemainigSpells();
			
		goToLevel(currentLevelIndex);
	}

	public function addOnNewLevel(Callback:Dynamic) {
		onNewLevel.add(Callback);
	}
	
	function doOnNewLevel() {
		for ( Callback in onNewLevel ) 
			Callback();
	}

	function goToLevel(level:Int) {
		//levels.push(new CqLevel(level));
		//currentLevel = levels[level];
		currentLevel = new CqLevel(level);
		doOnNewLevel();
		//Store it
		SaveLoad.saveGame();
		//Let Kong know
		Registery.getKong().SubmitStat( Registery.KONG_MAXLEVEL , level );
	}
		
	public override function goToNextLevel(state:HxlState, ?jumpToLevel:Int = -1) {
		state.remove(currentLevel);
		if (jumpToLevel > -1)
			currentLevelIndex = jumpToLevel;
		else
			currentLevelIndex++;
		goToLevel(currentLevelIndex);
		Registery.player.infoViewFloor.setText("Floor " +(currentLevelIndex + 1));

		currentLevel.zIndex = -1;	
		state.add(currentLevel);
		currentLevel.updateFieldOfView(state,true);
		doOnNewLevel();
	}

	static public function onActorAdded(Actor:CqActor) {
		if ( actorAdded != null ) actorAdded();
	}
}
