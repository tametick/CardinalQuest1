package cq.ui;

import cq.CqItem;
import cq.CqResources;
import cq.CqSpell;
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

  public var itemSheet:HxlSpriteSheet;
  public var itemSprite:HxlSprite;
  public var spellSheet:HxlSpriteSheet;
  public var spellSprite:HxlSprite;

  var _item:CqItem;
  var _icon:HxlSprite;
  var _itemName:HxlText;
  var _itemDesc:HxlText;
  var _itemStats:HxlText;

  public function new(?X:Float=0, ?Y:Float=0, ?Width:Float=100, ?Height:Float=100) {
    super(X, Y, Width, Height);

    itemSprite = null;
    itemSheet = null;
    spellSprite = null;
    spellSheet = null;
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
  }

  public function setItem(Item:CqItem) {
    _item = Item;
    _itemName.text = Item.fullName;
	
	_itemDesc.text = Resources.getString( Item.id, true );
	
    _itemDesc.y = _itemName.y + _itemName.height - 2;
    if ( Std.is(Item, CqSpell) ) {
      spellSprite.setFrame(spellSheet.getSpriteIndex(Item.spriteIndex));
      _icon.pixels = spellSprite.getFramePixels();
      _itemStats.text = "";
      _itemStats.visible = false;
    } else {
      itemSprite.setFrame(itemSheet.getSpriteIndex(Item.spriteIndex));
      _icon.pixels = itemSprite.getFramePixels();
      var statStr:String = "";
      // display weapon damage
      if ( _item.damage.end > 0 ) {
        statStr += "" + _item.damage.start + " - " + _item.damage.end + " " + Resources.getString( "UI_DAMAGE" ) + "\n";
      }
      // display special effects
      if ( _item.specialEffects.length > 0 ) {
        var str = "";
        for ( effect in _item.specialEffects ) {
          str += "" + effect.value + " " + Resources.getString( effect.name ) + "\n";
        }
        statStr += str;
      }
      // display item buffs
      if ( Lambda.count(_item.buffs) > 0 ) {
        var str = "";
        for ( key in _item.buffs.keys() ) {
          if ( _item.buffs.get(key) > 0 ) str += "+";
          var keyname:String = Resources.getString( "STAT_" + key.toUpperCase() );
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
