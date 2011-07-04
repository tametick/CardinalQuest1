package cq;

import cq.CqActor;
import cq.CqResources;


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

		txtCharName = new HxlText(20, 20, 430, "Unknown Hero");
		txtCharName.setFormat(null, 32, 0xffffff, "left", 0x010101);
		add(txtCharName);

		txtHealthLabel = new HxlText(20, 100, 430, "Health:");
		txtHealthLabel.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(txtHealthLabel);

		valHealth = new HxlText(150, 100, 200, "0");
		valHealth.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(valHealth);

		txtAttackLabel = new HxlText(20, 130, 430, "Attack:");
		txtAttackLabel.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(txtAttackLabel);

		valAttack = new HxlText(150, 130, 200, "0");
		valAttack.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(valAttack);

		txtDefenseLabel = new HxlText(20, 160, 430, "Defense:");
		txtDefenseLabel.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(txtDefenseLabel);

		valDefense = new HxlText(150, 160, 200, "0");
		valDefense.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(valDefense);

		txtSpeedLabel = new HxlText(20, 190, 430, "Speed:");
		txtSpeedLabel.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(txtSpeedLabel);

		valSpeed = new HxlText(150, 190, 200, "0");
		valSpeed.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(valSpeed);

		txtSpiritLabel = new HxlText(20, 220, 430, "Spirit:");
		txtSpiritLabel.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(txtSpiritLabel);

		valSpirit = new HxlText(150, 220, 200, "0");
		valSpirit.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(valSpirit);

		txtVitalityLabel = new HxlText(20, 250, 430, "Vitality:");
		txtVitalityLabel.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(txtVitalityLabel);

		valVitality = new HxlText(150, 250, 200, "0");
		valVitality.setFormat(FontAnonymousPro.instance.fontName, 16, 0xffffff, "left", 0x010101);
		add(valVitality);

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
