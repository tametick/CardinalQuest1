package cq;

import cq.CqActor;
import cq.CqResources;
import haxel.HxlSprite;


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

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100, ?Direction:Int=0)
	{
		// Size: 472 x 480
		super(X, Y, Width, Height, Direction);
		
		var bg:HxlSprite = new HxlSprite(0, 0, SpriteMapPaper);
		bg.zIndex = -5;
		add(bg);
		
		//var textColor:Int = 0xFFFFFF;
		var textColor:Int = 0x6D564B;
		
		var textBoxes:Array<String> = ["txtCharName", "txtHealthLabel", "valHealth", "txtAttackLabel", "valAttack", "txtDefenseLabel", "valDefense", "txtSpeedLabel", "valSpeed", "txtSpiritLabel", "valSpirit", "txtVitalityLabel", "valVitality"];
		var txt_string:Array<String> = ["Unknown Hero", "Health:", "0", "Attack:", "0", "Defense:", "0", "Speed:", "0", "Spirit:", "0", "Vitality:", "0"];
		var pos:Array<Array<Int>> = [ [ 20, 20], [20, 100], [150, 100], [20, 130], [150, 130], [20, 160], [150, 160], [20, 190], [150, 190], [20, 220], [150, 220], [20, 250], [150, 250]];
		for (i in 0...textBoxes.length)
		{
			var box:HxlText = new HxlText(pos[i][0], pos[i][1], 430, txt_string[i]);
			Reflect.setField(this, textBoxes[i], box);
			add(box);
			if (i == 0)
				box.setFormat(null, 32, textColor, "left", 0x010101);
			else
				box.setFormat(FontAnonymousPro.instance.fontName, 16, textColor, "left", 0x010101);
		}
	}

	public override function show(?ShowCallback:Dynamic=null) {
		super.show(ShowCallback);
		updateDialog();
	}

	public override function updateDialog() {
		var _player:CqPlayer = CqRegistery.player;
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
