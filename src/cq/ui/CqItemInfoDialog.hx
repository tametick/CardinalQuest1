package cq.ui;

import cq.CqItem;
import cq.CqResources;
import cq.CqSpell;
import cq.GameUI;
import data.StatsFile;

import data.Configuration;
import data.Resources;
import data.Registery;

import haxel.HxlDialog;
import haxel.HxlGraphics;
import haxel.HxlSprite;
import haxel.HxlSpriteSheet;
import haxel.HxlText;

#if flash
	import flash.text.engine.LineJustification;
	import flash.text.StyleSheet;
	import flash.text.TextRenderer;
#end

class CqItemInfoDialog extends HxlDialog {
	var itemSprite:HxlSprite;
	var spellSprite:HxlSprite;
	
	
	var _item:CqItem;
	var _icon:HxlSprite;
	var _itemName:HxlText;
	var _itemDesc:HxlText;
	var _itemStats:HxlText;

	public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
		super(X, Y, Width, Height);

		_item = null;

		_icon = new HxlSprite(Width - 28, Height - 98);
		_icon.visible = false;
		_itemName = new HxlText(8, 10, Std.int(Width - 10));
		_itemName.setFormat(null, 26, 0xffffff, "left", 0x010101);
		_itemName.visible = false;
		_itemDesc = new HxlText(7, 30, Std.int(Width-10));
		_itemDesc.setFormat(FontAnonymousPro.instance.fontName, 15, 0xdddddd, "left", 0x010101);
		_itemDesc.visible = false;
		_itemStats = new HxlText(7, 45, Std.int(Width-48-10));
		_itemStats.setFormat(FontAnonymousPro.instance.fontName, 15, 0x4DE16B, "left", 0x010101);
		_itemStats.visible = false;

		add(_icon);
		add(_itemName);
		add(_itemDesc);
		add(_itemStats);
		
		var itemSheetKey:CqGraphicKey = CqGraphicKey.ItemIconSheet;
		itemSprite = new HxlSprite(0, 0);
		itemSprite.loadGraphic(SpriteItems, true, false, Configuration.tileSize, Configuration.tileSize, false, 3.0, 3.0);

		var spellSheetKey:CqGraphicKey = CqGraphicKey.SpellIconSheet;
		spellSprite = new HxlSprite(0, 0);
		spellSprite.loadGraphic(SpriteSpells, true, false, Configuration.tileSize, Configuration.tileSize, false, 3.0, 3.0);
	}

	public function setItem(Item:CqItem) {
		_item = Item;
		_itemName.text = Item.fullName;

		var descriptions:StatsFile = Resources.statsFiles.get( "descriptions.txt" );
		var desc:StatsFileEntry = descriptions.getEntry( "Name", Item.name );
		_itemDesc.text = if (desc != null) desc.getField( "Description" ); else "???";

		_itemDesc.y = _itemName.y + _itemName.height - 2;
		if ( Std.is(Item, CqSpell) ) {
			spellSprite.setFrame(CqSheets.spellSheet.getSpriteIndex(Item.spriteIndex));
			_icon.pixels = spellSprite.getFramePixels();
			_itemStats.text = "";
			_itemStats.visible = false;
		} else {
			itemSprite.setFrame(CqSheets.itemSheet.getSpriteIndex(Item.spriteIndex));
			_icon.pixels = itemSprite.getFramePixels();
			var statStr:String = "";
			// display weapon damage
			if ( _item.damage.end > 0 ) {
				statStr += "" + _item.damage.start + " - " + _item.damage.end + " Damage\n";
			}
			// display special effects
			if ( _item.specialEffects.length > 0 ) {
				var str = "";
				for ( effect in _item.specialEffects ) {
					str += "" + effect.value + " " + effect.name + "\n";
				}
				statStr += str;
			}
			// display item buffs
			if ( Lambda.count(_item.buffs) > 0 ) {
				var str = "";
				for ( key in _item.buffs.keys() ) {
					if ( _item.buffs.get(key) > 0 ) str += "+";
					var keyname:String = key.substr(0,1).toUpperCase() + key.substr(1);
					str += "" + _item.buffs.get(key) + " " + keyname + "\n";
				}
				statStr += str;
			}
			if ( statStr != "" ) {
				_itemStats.y = _itemDesc.y + _itemDesc.height + 3;
				_itemStats.text = statStr;
				_itemStats.visible = true;
			}
		}
		_itemName.visible = true;
		_itemDesc.visible = true;
		_icon.visible = true;
	}

	public function clearInfo() {
		_item = null;
		_itemName.visible = false;
		_itemDesc.visible = false;
		_itemStats.visible = false;
		_icon.visible = false;
	}
}
