class ApplicationMain
{
   public static function main()
   {
      nme.Lib.setAssetBase("assets/");
      
      nme.display.Stage.setFixedOrientation(nme.display.Stage.OrientationPortrait);
      
      nme.Lib.create(
           function(){ cq.Main.main(); },
           1024, 768,
           30,
           0xffffff,
             ( true   ? nme.Lib.HARDWARE  : 0) |
             ( true ? nme.Lib.RESIZABLE : 0),
          "Cardinal Quest HD",
		  "cq"
          );
   }

   public static function getAsset(inName:String):Dynamic
   {
      
      if (inName=="assets/cq/Anonymous-Pro-B.ttf")
      {
         
            return nme.utils.ByteArray.readFile(inName);
         
      }
      
      if (inName=="assets/cq/AnonymousPro-Regular.ttf")
      {
         
            return nme.utils.ByteArray.readFile(inName);
         
      }
      
      if (inName=="assets/cq/Belt_horiz_leather.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Belt_vert_metal.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/BlankOverlay.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/boss.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/button_bg.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/buttons.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Ch_selection_box_01.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/coin.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/corpses.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Credits.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/cursor.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/death.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/decorations.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Dungeon.ttf")
      {
         
            return nme.utils.ByteArray.readFile(inName);
         
      }
      
      if (inName=="assets/cq/effects.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/equipment_icons.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/heart.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/HelpOverlay.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/HighscoresBg.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/HighscoresBgOld.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/info_slot.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/inv_box_02.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/inventoryHelpOverlay.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Item_slot_01.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Item_slot_02.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/items.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Knight_entry_03.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/logo.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/main1.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/main2.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/mainmenuBg.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/map_paper.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/menu.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/Minator_intro_02.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/monsters.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/player.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/portrait_slots.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/portrait_slots_on_paper.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/resources.swf")
      {
         
            return nme.utils.ByteArray.readFile(inName);
         
      }
      
      if (inName=="assets/cq/resources.xml")
      {
         
            return nme.utils.ByteArray.readFile(inName);
         
      }
      
      if (inName=="assets/cq/sounds/chestBusted.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/death.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/doorOpen.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/enemyHit.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/enemyMiss.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/Footstep1.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/Footstep2.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/Footstep3.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/Footstep4.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/Footstep5.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/Footstep6.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/fortressGate.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/itemEquipped.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/levelUp.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/lose.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/menuItemClick.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/menuItemMouseOver.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/pickup.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/playerHit.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/playerMiss.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/potionEquipped.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/potionQuaffed.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/spellCast.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/spellCastNegative.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/spellEquipped.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/sounds/win.mp3")
      {
         
            return new nme.media.Sound(new nme.net.URLRequest(inName),null,true);
         
      }
      
      if (inName=="assets/cq/soundToggle.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/spells.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Start_button.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/swfmill")
      {
         
            return nme.utils.ByteArray.readFile(inName);
         
      }
      
      if (inName=="assets/cq/Thief_entry_03.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/tiles.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/vortex_figure.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Vortex_lights.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Vortex_swirl.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/white.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      if (inName=="assets/cq/Wizard_entry_03.png")
      {
         
            return nme.display.BitmapData.load(inName);
         
      }
      
      return null;
   }
}

