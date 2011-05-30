package detribus;

import flash.filters.BlurFilter;
import flash.media.SoundChannel;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import haxel.HxlGraphics;
import haxel.HxlState;
import haxel.HxlText;
import haxel.HxlTextInput;
import Sdrl.SdrlGame;
import detribus.StateGame;
import detribus.Resources;
import detribus.Perks;
import detribus.Player;
import flash.filters.GlowFilter;

class PerkSprite extends HxlText {
	public function updateValue(value:Int) {
		// this should be changed to something better looking 
		
		if ( value == 0 ) 
			text = "_ _ _";
		else if ( value == 1 ) 
			text = "X _ _";
		else if ( value == 2 ) 
			text = "X X _";
		else if ( value == 3 ) 
			text = "X X X";
	}
}

class StateCreateChar extends BaseMenuState {

	private var currentStep:Int;

	private var nameInput:HxlTextInput;
	private var whoText:HxlText;
	private var nameText:HxlText;
	private var nextText:HxlText;
	private var backText:HxlText;

	private var whatText:HxlText;
	private var perkPointsText:HxlText;
	private var perks:Perks;
	private var perkName:Array<PerkSprite>;
	private var perkValue:Array<PerkSprite>;
	private var currentPerk:Int;
	private var perkIcon:HxlText;
	private var usedPerk:Bool;

	public override function create():Void {
		super.create();


		perks = new Perks();
		perkName = new Array();
		perkValue = new Array();
		currentPerk = 0;
		usedPerk = false;

		currentStep = 1;
		renderNameStep();

		HxlGraphics.fade.start(false, 0xffffffff, 0.25);
		HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		HxlGraphics.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}

	function startGame():Void {
		var player:Player = new Player(null);
		player.perks = perks;
		perks.player = player;
		player.armor =  perks.getPerkValue(Perks.PERK_ARMOR);
		player.dodge =  perks.getPerkValue(Perks.PERK_DODGE);
		player.damage =  15 + 2*perks.getPerkValue(Perks.PERK_DAMAGE);
		player.name = nameInput.text;
		SdrlGame.player = player;
		HxlGraphics.fade.start(true, 0xffffffff, 0.25, function() {
				HxlGraphics.state = new StateGame();
		}, true);
	}
	
	function onKeyDown(event:KeyboardEvent):Void {
		var c:Int = event.keyCode;
		if ( c == 13 ) { // Enter
			if ( currentStep == 1) {
				renderPerkStep();
				currentStep++;
			} else if ( currentStep == 2 ) {
				if ( usedPerk ) {
					startGame();
				} else {
					perks.setPerkValue(currentPerk, 1);
					usedPerk = true;
					updatePerkValues();
					updatePointsLeft();
				}
			}
			BaseMenuState.playSelectSound();
		} else if ( c == 27 ) { // Esc
			currentStep--;
			if ( currentStep == 0 ) {
				HxlGraphics.fade.start(true, 0xffffffff, 0.25, function() {
					HxlGraphics.state = new StateTitle();
				}, true);
			} else if ( currentStep == 1 ) {
				renderNameStep();
			}
		} else if ( c == 38 ) { // Up
			if ( currentStep == 2 ) {
				currentPerk--;
				if ( currentPerk < 0 ) currentPerk = perkName.length - 1;
				updatePerkIcon();
				BaseMenuState.playScrollSound();
			}
			BaseMenuState.playScrollSound();
		} else if ( c == 40 ) { // Down
			if ( currentStep == 2 ) {
				currentPerk++;
				if ( currentPerk >= perkName.length ) currentPerk = 0;
				updatePerkIcon();
				BaseMenuState.playScrollSound();
			}
		} else if ( c == 37 ) { // Left
			if ( currentStep == 2 && usedPerk && perks.getPerkValue(currentPerk) > 0 ) {
				perks.setPerkValue(currentPerk, 0);
				usedPerk = false;
				updatePerkValues();
				updatePointsLeft();
				BaseMenuState.playSelectSound();
			}
		} else if ( c == 39 ) { // Right
			if ( currentStep == 2 && !usedPerk ) {
				perks.setPerkValue(currentPerk, 1);
				usedPerk = true;
				updatePerkValues();
				updatePointsLeft();
				BaseMenuState.playSelectSound();
			}
		}
	}
	
	function onMouseUp(event:MouseEvent):Void {
		var mX = HxlGraphics.mouse.x;
		var mY = HxlGraphics.mouse.y;
		if ( backText.overlapsPoint(mX, mY) ) {
			currentStep--;
			if ( currentStep == 0 ) {
				HxlGraphics.fade.start(true, 0xffffffff, 0.25, function() {
					HxlGraphics.state = new StateTitle();
				}, true);
			} else if ( currentStep == 1 ) {
				renderNameStep();
			}			
		} else if ( nextText.overlapsPoint(mX, mY) ) {
			currentStep++;
			if ( currentStep == 2 ) {
				renderPerkStep();
			} else if ( currentStep == 3 ) {
				startGame();
			}			
		} else if ( currentStep == 2 ) {
			var mx = HxlGraphics.mouse.x;
			var my = HxlGraphics.mouse.y;
			for ( i in 0...perkName.length ) {
				if ( perkName[i].overlapsPoint(mx, my) || perkValue[i].overlapsPoint(mx, my) ) {
					if ( usedPerk && perks.getPerkValue(i) > 0 ) {
						perks.setPerkValue(i, 0);
						usedPerk = false;
					} else if ( usedPerk == false) {
						perks.setPerkValue(i, 1);
						usedPerk = true;
					}
					updatePerkValues();
					updatePointsLeft();
				}
			}
		}
	}

	private function renderNameStep():Void {
		
		if ( whatText != null ) {
			whatText.visible = false;
		}
		if ( perkPointsText != null ) {
			perkPointsText.visible = false;
		}
		if ( whoText == null ) {
			whoText = new HxlText(0, 5, 360, "Who are you?", true);
			whoText.setFormat(null, 30, 0xffffff, "center", 0x010101);
			add(whoText);

			
		} else {
			whoText.visible = true;
		}
		if ( perkName.length > 0 ) {
			for ( i in 0...perkName.length ) {
				perkName[i].visible = false;
				perkValue[i].visible = false;
			}
		}
		if ( perkIcon != null ) {
			perkIcon.visible = false;
		}

		if ( nameInput == null ) {
			nameInput = new HxlTextInput( 90, 100, 240, "Abraxis", true);
			nameInput.setFormat(null, 20, 0x000000, "left");
			nameInput.backgroundVisible = false;
			nameInput.borderVisible = true;
			nameInput.borderColor = 0x000000;
			nameInput.filterMode = HxlTextInput.ONLY_ALPHANUMERIC;
			
			add(nameInput);
		} else {
			nameInput.visible = true;
		}

		if ( nameText == null ) {
			nameText = new HxlText(30, 100, 75, "Name:", true);
			nameText.setFormat(null, 20, 0x000000, "left");
			add(nameText);
		} else {
			nameText.visible = true;
		}

		if ( nextText == null ) {
			nextText = new HxlText(295, 190, 60, "Enter >", true);
			nextText.setFormat(null, 18, 0x000000, "left");
			add(nextText);
		} else {
			nextText.visible = true;
		}

		if ( backText == null ) {
			backText = new HxlText(10, 190, 45, "< Esc", true);
			backText.setFormat(null, 18, 0x000000, "left");
			add(backText);
		}

	}

	private function updatePerkIcon():Void {
		if ( perkIcon != null ) {
			perkIcon.y = 80 + (currentPerk * 22);
		}
	}

	private function updatePointsLeft():Void {
		if ( usedPerk ) {
			perkPointsText.text = "Points Left: 0";
		} else {
			perkPointsText.text = "Points Left: 1";
		}
	}

	private function updatePerkValues():Void {
		for ( i in 0...perkValue.length ) {
			var value:Int = perks.getPerkValue(i);
			perkValue[i].updateValue(value);
		}
	}

	private function renderPerkStep():Void {

		if ( whoText != null ) {
			whoText.visible = false;
		}
		if ( nameInput != null ) {
			nameInput.visible = false;
		}
		if ( nameText != null ) {
			nameText.visible = false;
		}

		if ( whatText == null ) {
			whatText = new HxlText(0, 5, 360, "What are you?", true);
			whatText.setFormat(null, 30, 0xffffff, "center", 0x010101);
			add(whatText);
		} else {
			whatText.visible = true;
		}
		if ( perkPointsText == null ) {
			perkPointsText = new HxlText(140, 40, 200, "Points Left: 1", true);
			perkPointsText.setFormat(null, 16, 0x000000, "left");
			add(perkPointsText);
		} else {
			perkPointsText.visible = true;
		}
		if ( perkName.length == 0 ) {
			var names:Array<String> = perks.getPerkNames();
			for ( i in 0...names.length ) {
				perkName[i] = new PerkSprite(60, 80+(i*22), 100, names[i], true);
				perkName[i].setFormat(null, 22, 0x000000, "left");
				add(perkName[i]);
				perkValue[i] = new PerkSprite(265, 80+(i*22), 100, "_ _ _", true);
				perkValue[i].setFormat(null, 22, 0x000000, "left");
				add(perkValue[i]);
			}
		} else {
			for ( i in 0...perkName.length ) {
				perkName[i].visible = true;
				perkValue[i].visible = true;
			}
		}
		if ( perkIcon == null ) {
			perkIcon = new HxlText(20, 80, 40, "->", true);
			perkIcon.setFormat(null, 22, 0x000000, "center");
			add(perkIcon);
		} else {
			perkIcon.visible = true;
		}

	}

	public override function update():Void {
		super.update();		

		var mx = HxlGraphics.mouse.x;
		var my = HxlGraphics.mouse.y;
		if ( currentStep == 2 ) {
			for ( i in 0...perkName.length ) {
				if ( perkName[i].overlapsPoint(mx, my) || perkValue[i].overlapsPoint(mx, my) ) {
					currentPerk = i;
					updatePerkIcon();
				}
			}
		}
	}

	public override function destroy():Void {
		HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		HxlGraphics.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		super.destroy();
	}
}
