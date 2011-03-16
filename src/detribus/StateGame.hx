package detribus;

import haxel.HxlGraphics;
import haxel.HxlPoint;
import haxel.HxlState;
import haxel.HxlUtil;
import haxel.HxlTilemap;
import haxel.HxlSprite;
import haxel.HxlSound;
import detribus.Resources;
import detribus.Sdrl.SdrlGame;
import detribus.StatsDialog;
import detribus.LevelUpDialog;
import detribus.GameOverDialog;
import detribus.HealthBar;
import flash.events.KeyboardEvent;

class StateGame extends haxel.HxlState {

	var initialized:Int;
	public var world:World;
	var player:Player;
	public static var healthBar:HealthBar;

	public static var loadingBox:MessageBox;
	
	public static var forestMusic:HxlSound;
	public static var caveMusic:HxlSound;

	public var statsDialog:StatsDialog;
	public var levelUpDialog:LevelUpDialog;
	public var gameOverDialog:GameOverDialog;

	public override function create():Void {		
		
		super.create();
		initialized = -1;
		
		if ( forestMusic == null) {
			forestMusic = new HxlSound();
			forestMusic.loadEmbedded(Nohighscore, true);
		}
		forestMusic.play();
		
		if ( caveMusic == null) {
			caveMusic = new HxlSound();
			caveMusic.loadEmbedded(Innerfight, true);		
		}
				
		HxlGraphics.fade.start(false, 0xffffffff, 0.25);
		
		loadingBox = new MessageBox(80, 80, 200, 50);
		loadingBox.setBackground(true, 0xff000000);
		loadingBox.setAlign( "center" );
		loadingBox.setFontSize(30);
		loadingBox.setFontColor(0xffffffff);
		loadingBox.messageText.text = "Loading...";
		loadingBox.visible = false;
		add(loadingBox);

	}
	
	public function updateFieldOfView(?SkipTween:Bool = false):Void {
		var bottom = Std.int(Math.min(world.currentLevel.heightInTiles - 1, player.tilePos.y + (player.visionRadius+1)));
		var top = Std.int(Math.max(0, player.tilePos.y - (player.visionRadius+1)));
		var right = Std.int(Math.min(world.currentLevel.widthInTiles - 1, player.tilePos.x + (player.visionRadius+1)));
		var left = Std.int(Math.max(0, player.tilePos.x - (player.visionRadius+1)));
		var tile:HxlTile;
		for ( x in left...right+1 ) {
			for ( y in top...bottom+1 ) {
				tile = world.currentLevel.getTile(x, y);
				if ( tile.visibility == Visibility.IN_SIGHT ) 
					tile.visibility = Visibility.SEEN;
			}
		}

		if ( world.currentLevel.isBlockingView(Std.int(player.tilePos.x), Std.int(player.tilePos.y)) ) {
			var adjacent = new Array();
			adjacent = [[ -1, -1], [0, -1], [1, -1], [ -1, 0], [1, 0], [ -1, 1], [0, 1], [1, 1]];
			for ( i in adjacent ) {
				var xx = Std.int(player.tilePos.x + i[0]);
				var yy = Std.int(player.tilePos.y + i[1]);
				if(yy<world.currentLevel.heightInTiles && xx<world.currentLevel.widthInTiles && yy>=0 && xx>=0)
					cast(world.currentLevel.getTile(xx, yy), Tile).visibility = Visibility.IN_SIGHT;
			}
		} else {		
			HxlUtil.markFieldOfView(player.tilePos, player.visionRadius, world.currentLevel);
		}

		for ( x in left...right+1 ) {
			for ( y in top...bottom+1 ) {
				tile = world.currentLevel.getTile(x, y);
				switch (tile.visibility) {
					case Visibility.IN_SIGHT:
						if ( SkipTween ) {
							tile.color = 0xffffff;
						} else {
							cast(tile,Tile).colorTo(255, player.moveSpeed);
						}
					case Visibility.SEEN:
						if ( SkipTween ) {
							tile.color = 0x888888;
						} else {
							cast(tile,Tile).colorTo(95, player.moveSpeed);
						}
					case Visibility.UNSEEN:
				}
			}
		}
	}
	
	public override function update():Void {
		super.update();	
		if ( initialized == -1 ) {
			loadingBox.visible = true;
			initialized++;
			return;
		}

		if ( initialized == 0 ) {
			player = SdrlGame.player;
			world = new World(this,player);
			player.enterWorld( world);
			
			add(world.currentLevel);
			world.currentLevel.follow();
			
			
			world.addAllActors();
			world.addAllLoots();
			HxlGraphics.follow(player, 10);
			
			updateFieldOfView(true);

			initialized = 1;
			
			remove(loadingBox);
			loadingBox.destroy();
			loadingBox = null;
			
			/*
			if(StateTitle.menuMusicChannel!=null)
				StateTitle.menuMusicChannel.stop();
				*/
			
			//gameMusic.play(0, 1);
			//defaultGroup.sortMembersByZIndex();
			
			statsDialog = new StatsDialog(300, 200);
			statsDialog.zIndex = 99;
			statsDialog.x = 30;
			statsDialog.y = 20;
			statsDialog.visible = false;
			add(statsDialog);

			levelUpDialog = new LevelUpDialog(300, 200);
			levelUpDialog.zIndex = 99;
			levelUpDialog.x = 30;
			levelUpDialog.y = 20;
			levelUpDialog.visible = false;
			add(levelUpDialog);

			gameOverDialog = new GameOverDialog(300, 200);
			gameOverDialog.zIndex = 99;
			gameOverDialog.x = 30;
			gameOverDialog.y = 20;
			gameOverDialog.visible = false;
			add(gameOverDialog);
	
			healthBar = new HealthBar();
			healthBar.x = healthBar.y = 5;
			healthBar.zIndex = 88;
			add(healthBar);

			HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		if ( levelUpDialog.visible || gameOverDialog.visible ) return;			

		if ( !player.isMoving ) {
			var turnPlayed = false;
			if ( HxlGraphics.keys.justPressed("SPACE") ) {
				var target:HxlPoint = getTarget(player.tilePos, player.range,player.facing);
				player.shoot( target.x, target.y);
				turnPlayed = true;
			}
			
			if ( HxlGraphics.keys.justPressed("ENTER") ) {
				turnPlayed = true;
			}
			
			var facing:Int = getFacingAccordingToKeyPress();
			if (facing != player.facing && HxlGraphics.keys.SHIFT) {
				player.face(facing);
				HxlGraphics.keys.reset();
			} else {
				var targetTile:HxlPoint = getTargetAccordingToKeyPress();
				if ( targetTile != null ) {
					var nextTile = world.currentLevel.getTile(player.tilePos.x + targetTile.x, player.tilePos.y + targetTile.y);
					// dont allow the player to step on a mob
					if (nextTile.actor == null) {						
						player.setTilePos(new HxlPoint(player.tilePos.x + targetTile.x, player.tilePos.y + targetTile.y));
						player.isMoving = true;
						var positionOfTile:HxlPoint = world.currentLevel.getTilePos(Math.round(player.tilePos.x), Math.round(player.tilePos.y));
						player.moveTo(positionOfTile.x + 4, positionOfTile.y + 4);
						
						turnPlayed = true;
						// Update FOV before moving mobs, so we know which mobs should be visible
						updateFieldOfView();
					} else {
						HxlGraphics.log("can't step on mobs!");
						player.face(facing);
					}
				}
			}
			
			if(turnPlayed) {
				// enemy's turn
				for( mob in world.currentLevel.mobs ) {
					mob.act();
				}
				
				// decerement all active power-ups duration
				player.decrementActivePowerUps();
			}
		}
	}
	
	function getTarget(src:HxlPoint, range:Int, direction:Int):HxlPoint {
		var target:HxlPoint = src.clone();
		var _world = world;
		var isEnemyOrBlocking = function():Bool { 
			return _world.currentLevel.isBlockingMovement(Std.int(target.x), Std.int(target.y), true);
		};
		
		var dist = 0;
		switch(player.facing) {
			case HxlSprite.LEFT:
				do { 
					target.x -= 1;
					dist++;
				} while (!(isEnemyOrBlocking() || dist>range));
			case HxlSprite.RIGHT:
				do { 
					target.x += 1;
					dist++;
				} while (!(isEnemyOrBlocking() || dist>range));
			case HxlSprite.UP:
				do { 
					target.y -= 1;
					dist++;
				} while (!(isEnemyOrBlocking() || dist>range));
			case HxlSprite.DOWN:
				do { 
					target.y += 1;
					dist++;
				} while (!(isEnemyOrBlocking() || dist>range));
		}

		return target;
	}
	
	function getFacingAccordingToKeyPress():Int {
		var face:Int = player.facing;
		
		if ( HxlGraphics.keys.justPressed("LEFT") )
			face = HxlSprite.LEFT;
		else if ( HxlGraphics.keys.justPressed("RIGHT") )
			face = HxlSprite.RIGHT;
		else if ( HxlGraphics.keys.justPressed("UP") )
			face = HxlSprite.UP;
		else if ( HxlGraphics.keys.justPressed("DOWN") )
			face = HxlSprite.DOWN;
		
		return face;
	}
	
	function getTargetAccordingToKeyPress():HxlPoint 
	{
		var targetTile:HxlPoint = null;
		if ( HxlGraphics.keys.LEFT ) {
			if ( player.tilePos.x > 0) {
				if ( !world.currentLevel.isBlockingMovement(Std.int(player.tilePos.x-1), Std.int(player.tilePos.y)) ) {
					targetTile = new HxlPoint( -1, 0);
				}
			}
		} else if ( HxlGraphics.keys.RIGHT ) {
			if ( player.tilePos.x < world.currentLevel.widthInTiles) {
				if ( !world.currentLevel.isBlockingMovement(Std.int(player.tilePos.x+1), Std.int(player.tilePos.y)) ) {
					targetTile = new HxlPoint(1, 0);
				}
			}
		} else if ( HxlGraphics.keys.UP ) {
			if ( player.tilePos.y > 0 ) {
				if ( !world.currentLevel.isBlockingMovement(Std.int(player.tilePos.x), Std.int(player.tilePos.y-1)) ) {
					targetTile = new HxlPoint(0, -1);
				}
			}
		} else if ( HxlGraphics.keys.DOWN ) {
			if ( player.tilePos.y < world.currentLevel.heightInTiles ) {
				if ( !world.currentLevel.isBlockingMovement(Std.int(player.tilePos.x), Std.int(player.tilePos.y+1)) ) {
					targetTile = new HxlPoint(0, 1);
				}
			}
		} 
		
		return targetTile;
	}

	function onKeyUp(event:KeyboardEvent):Void {
		var c:Int = event.keyCode;
	}

	public function toggleStats():Void {
		if ( statsDialog.visible ) {
			statsDialog.visible = false;
		} else {
			statsDialog.visible = true;
		}
	}

	public function toggleLevelUp():Void {
		if ( levelUpDialog.visible ) {
			levelUpDialog.toggleDisplay(false);
		} else {
			levelUpDialog.toggleDisplay(true);
		}
	}

	public function getLevel():Level {
		return world.currentLevel;
	}
	
	public function getPlayer():Player {
		return player;
	}

	public override function render():Void {
		super.render();
	}

	public override function destroy():Void {
		HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		super.destroy();
	}

}
