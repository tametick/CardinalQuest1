package detribus;

import haxel.HxlGroup;
import haxel.HxlText;
import haxel.HxlSprite;
import haxel.HxlGraphics;
import haxel.HxlObject;
import flash.media.SoundChannel;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import detribus.Perks;
import detribus.StateCreateChar;

import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

#if flash9
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

class LevelUpDialog extends StatsDialog {

	private var levelUpText:HxlText;
	private var perks:Perks;
	private var perkName:Array<PerkSprite>;
	private var perkValue:Array<PerkSprite>;
	private var currentPerk:Int;
	private var perkIcon:HxlText;
	private var usedPerk:Bool;
	private var chosenPerk:Int;

	public function new(Width:Int, Height:Int) {
		super(Width, Height);

		perks = cast(HxlGraphics.state, StateGame).world.player.perks;
		perkName = new Array();
		perkValue = new Array();
		currentPerk = 0;
		usedPerk = false;
		chosenPerk = 0;

		levelUpText = new HxlText(0, 5, 300, "You gained a level!", true);
		levelUpText.setFormat(null, 24, 0xffffff, "center", 0x010101);
		add(levelUpText);

		var names:Array<String> = perks.getPerkNames();
		for ( i in 0...names.length ) {
			perkName[i] = new PerkSprite(40, 70+(i*22), 100, names[i], true);
			perkName[i].setFormat(null, 22, 0x000000, "left");
			add(perkName[i]);
			perkValue[i] = new PerkSprite(205, 70+(i*22), 100, "_ _ _", true);
			perkValue[i].setFormat(null, 22, 0x000000, "left");
			add(perkValue[i]);
			perkValue[i].updateValue(perks.getPerkValue(i));
		}

		perkIcon = new HxlText(20, 70, 40, "->", true);
		perkIcon.setFormat(null, 22, 0x000000, "left");
		add(perkIcon);

		var o:HxlObject;
		for (i in 0...members.length) {
			o = cast( members[i], HxlObject);
			o.scrollFactor.x = o.scrollFactor.y = 0;
		}

		visible = false;

	}

	public function toggleDisplay(Show:Bool):Void {
		if ( Show ) {
			visible = true;
			HxlGraphics.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown,false,0,true);
			HxlGraphics.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp,false,0,true);
		} else {
			visible = false;
			HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			HxlGraphics.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);		
		}
	}

	private function updatePerkIcon():Void {
		if ( perkIcon != null ) {
			perkIcon.y = perkName[currentPerk].y;
		}
	}

	private function updatePointsLeft():Void {
		if ( usedPerk ) {
			//perkPointsText.text = "Points Left: 0";
		} else {
			//perkPointsText.text = "Points Left: 1";
		}
	}

	private function updatePerkValues():Void {
		for ( i in 0...perkValue.length ) {
			var value:Int = perks.getPerkValue(i);
			perkValue[i].updateValue(value);
		}
	}

	function onKeyDown(event:KeyboardEvent):Void {
		var c:Int = event.keyCode;
		if ( c == 13 ) { // Enter
			if ( usedPerk ) {
				cast(HxlGraphics.state, StateGame).toggleLevelUp();
				BaseMenuState.playSelectSound();
			}
		} else if ( c == 27 ) { // Esc
			if ( usedPerk ) {
				cast(HxlGraphics.state, StateGame).toggleLevelUp();
				BaseMenuState.playSelectSound();
			}
		} else if ( c == 38 ) { // Up
			currentPerk--;
			if ( currentPerk < 0 ) currentPerk = perkName.length - 1;
			updatePerkIcon();
			BaseMenuState.playScrollSound();
		} else if ( c == 40 ) { // Down
			currentPerk++;
			if ( currentPerk >= perkName.length ) currentPerk = 0;
			updatePerkIcon();
			BaseMenuState.playScrollSound();
		} else if ( c == 37 ) { // Left
			if ( usedPerk && chosenPerk == currentPerk ) {
				perks.setPerkValue(currentPerk, perks.getPerkValue(currentPerk)-1);
				usedPerk = false;
				updatePerkValues();
				updatePointsLeft();
				BaseMenuState.playSelectSound();
			}
		} else if ( c == 39 ) { // Right
			if ( !usedPerk ) {
				perks.setPerkValue(currentPerk, perks.getPerkValue(currentPerk)+1);
				usedPerk = true;
				chosenPerk = currentPerk;
				updatePerkValues();
				updatePointsLeft();
				BaseMenuState.playSelectSound();
			}
		}
	}
	
	function onMouseUp(event:MouseEvent):Void {
		var mX = HxlGraphics.mouse.x;
		var mY = HxlGraphics.mouse.y;
		/*
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
		*/
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

	public override function destroy():Void {
		HxlGraphics.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		HxlGraphics.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		super.destroy();
	}

}
