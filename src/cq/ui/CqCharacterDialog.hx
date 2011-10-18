package cq.ui;

import cq.CqActor;
import data.Registery;
import cq.CqResources;
import data.Configuration;
import haxel.HxlSprite;
import haxel.HxlUtil;


import haxel.HxlSlidingDialog;
import haxel.HxlText;

class CqCharacterDialog extends HxlSlidingDialog {

	var txtCharName:HxlText;
	var txtAttackLabel:HxlText;
	var txtDefenseLabel:HxlText;
	var txtSpeedLabel:HxlText;
	var txtSpiritLabel:HxlText;
	var txtVitalityLabel:HxlText;
	var txtHealthLabel:HxlText;

	var valAttack:HxlText;
	var valDefense:HxlText;
	var valSpeed:HxlText;
	var valSpirit:HxlText;
	var valVitality:HxlText;
	var valHealth:HxlText;

	static inline var textBoxes:Array<String> = ["txtCharName", "txtHealthLabel", "valHealth", "txtAttackLabel", "valAttack", "txtDefenseLabel", "valDefense", "txtSpeedLabel", "valSpeed", "txtSpiritLabel", "valSpirit", "txtVitalityLabel", "valVitality"];
	static inline var pos:Array<Array<Int>> = [ [ 40, 40], [40, 100], [190, 100], [40, 130], [190, 130], [40, 160], [190, 160], [40, 190], [190, 190], [40, 220], [190, 220], [40, 250], [190, 250]];
		
	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);
		
		var bg:HxlSprite = new HxlSprite(0, 0, SpriteMapPaper);
		bg.zIndex = -5;
		add(bg);
		
		var textColor:Int = 0x6D564B;
		var player_class:String = Registery.player.playerClassName;
		var txt_string:Array<String> = [player_class, "Health:", "0", "Attack:", "0", "Defense:", "0", "Speed:", "0", "Spirit:", "0", "Vitality:", "0"];
		
		
		for (i in 0...textBoxes.length)
		{
			var box:HxlText = new HxlText(pos[i][0], pos[i][1], 430, txt_string[i]);
			Reflect.setField(this, textBoxes[i], box);
			add(box);
			if (i == 0)
				box.setFormat(null, 48, textColor, "left", 0x010101);
			else
				box.setFormat(FontAnonymousPro.instance.fontName, 20, textColor, "left", 0x010101);
		}
		//char icon
		var player = new HxlSprite(0, 0);
		var shadow = new HxlSprite(0, 0);
		player.loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 8.0, 8.0);
		shadow.loadGraphic(SpritePlayer, true, false, Configuration.tileSize, Configuration.tileSize, false, 8.0, 8.0);
		player.setFrame(SpritePlayer.instance.getSpriteIndex(Registery.player.playerClassSprite));
		shadow.setFrame(SpritePlayer.instance.getSpriteIndex(Registery.player.playerClassSprite));
		//shadow.
		shadow.setAlpha(0.7);
		shadow.setColor(1);
		add(shadow);
		add(player);
		shadow.x = player.x = 300;
		shadow.y = player.y = 150;
		shadow.x += 5;
		shadow.y += 5;
		
	}

	public override function show(?ShowCallback:Dynamic=null) {
		super.show(ShowCallback);
		updateDialog();
	}

	public override function updateDialog() {
		var _player:CqPlayer = Registery.player;
		valHealth.text = "" + (_player.hp + _player.buffs.get("life")) +"/" + (_player.maxHp + _player.buffs.get("life"));
		
		if (_player.buffs.get("life") != 0) {
			valHealth.text += " [" +(_player.buffs.get("life") < 0?"":"+")+ _player.buffs.get("life") + "]";
		}
		
		valAttack.text = "" + (_player.attack+ _player.buffs.get("attack"));
		if(_player.buffs.get("attack")!=0){
			valAttack.text += " [" +(_player.buffs.get("attack") < 0?"":"+")+ _player.buffs.get("attack") + "]";
		}
		
		valDefense.text = "" + (_player.defense+ _player.buffs.get("defense"));
		if(_player.buffs.get("defense")!=0){
			valDefense.text += " [" +(_player.buffs.get("defense") < 0?"":"+")+ _player.buffs.get("defense") + "]";
		}
		
		valSpeed.text = "" + (_player.speed+ _player.buffs.get("speed"));
		if(_player.buffs.get("speed")!=0){
			valSpeed.text += " [" +(_player.buffs.get("speed") < 0?"":"+")+ _player.buffs.get("speed") + "]";
		}
		
		valSpirit.text = "" +(_player.spirit+ _player.buffs.get("spirit"));
		if(_player.buffs.get("spirit")!=0){
			valSpirit.text += " [" +(_player.buffs.get("spirit") < 0?"":"+")+ _player.buffs.get("spirit") + "]";
		}
		
		valVitality.text = ""+_player.vitality;
	}

}
