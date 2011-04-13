package cq;

import cq.CqActor;

import data.Registery;

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
		txtCharName.setFormat(null, 30, 0xffffff, "left", 0x010101);
		add(txtCharName);

		txtHealthLabel = new HxlText(20, 100, 430, "Health:");
		txtHealthLabel.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(txtHealthLabel);

		valHealth = new HxlText(150, 100, 200, "0");
		valHealth.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(valHealth);

		txtAttackLabel = new HxlText(20, 130, 430, "Attack:");
		txtAttackLabel.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(txtAttackLabel);

		valAttack = new HxlText(150, 130, 200, "0");
		valAttack.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(valAttack);

		txtDefenseLabel = new HxlText(20, 160, 430, "Defense:");
		txtDefenseLabel.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(txtDefenseLabel);

		valDefense = new HxlText(150, 160, 200, "0");
		valDefense.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(valDefense);

		txtSpeedLabel = new HxlText(20, 190, 430, "Speed:");
		txtSpeedLabel.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(txtSpeedLabel);

		valSpeed = new HxlText(150, 190, 200, "0");
		valSpeed.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(valSpeed);

		txtSpiritLabel = new HxlText(20, 220, 430, "Spirit:");
		txtSpiritLabel.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(txtSpiritLabel);

		valSpirit = new HxlText(150, 220, 200, "0");
		valSpirit.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(valSpirit);

		txtVitalityLabel = new HxlText(20, 250, 430, "Vitality:");
		txtVitalityLabel.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(txtVitalityLabel);

		valVitality = new HxlText(150, 250, 200, "0");
		valVitality.setFormat(null, 25, 0xffffff, "left", 0x010101);
		add(valVitality);

	}

	public override function show(?ShowCallback:Dynamic=null):Void {
		super.show(ShowCallback);
		updateText();
	}

	public function updateText():Void {
		var _player:CqPlayer = cast(Registery.player, CqPlayer);
		valHealth.text = ""+(_player.hp + _player.buffs.get("life"))+" / "+_player.maxHp;
		valAttack.text = ""+(_player.attack + _player.buffs.get("attack"));
		valDefense.text = ""+(_player.defense + _player.buffs.get("defense"));
		valSpeed.text = ""+(_player.speed + _player.buffs.get("speed"));
		valSpirit.text = ""+(_player.spirit + _player.buffs.get("spirit"));
		valVitality.text = ""+(_player.vitality + _player.buffs.get("vitality"));
	}

}
