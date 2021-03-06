package cq;


enum CqGraphicKey{
  InventoryCellBG;
  CellBGHighlight;
  DropCellBG;
  DropCellBGHighlight;
  ItemIconSheet;
  SpellIconSheet;
  ItemBG;
  ItemSelectedBG;
  EquipmentCellBG;
  EqCellBGHighlight;
  CellGlow;
  ChestEffectParticle;
  SpellEffectParticle( Color:Int );
  InjureEffectParticle;
  CharCreateSelector;
  targetSprite;
  buttonSprite;
  xball(color:Float);
  ItemGlow( type: String );
  FromClass(className:String, Frame:Int, width:Float, height:Float);
  OneColor(Width:Float, Height:Float, Color:Float);
}