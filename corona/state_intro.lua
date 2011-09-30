

module(..., package.seeall)

local bg;
local bgListener  = {};
local paragraph;

local paragraphText = [[The evil minotaur Asterion has
terrorized the peaceful land
of Hallemot for countless years

In his underground den, he and
his minions enjoy the spoils of
their wicked deeds.

Determined to end his reign of
plunder and pillage, a single
hero comes forth..]];

local xy = require("lib_xy")

function buildLine( content , nummer )

    local paragraph = display.newText( content, xy.centerX, xy.centerY, "AnonymousPro", 40 )
    paragraph:setReferencePoint( display.CenterLeftReferencePoint )
    paragraph.x =200;
    paragraph.y = xy.bottomY+nummer * 40;
    paragraph:setTextColor( 0,0,0 )
    transition.to( paragraph, { time=7000, y = 120 + nummer*40  } )

end

function build()

    bg = display.newImage( "Minator_intro_02.png" )
    bg.x = xy.centerX;
    bg.y = xy.centerY;
    bg:scale( xy.scaleX , xy.scaleY );

    bg:addEventListener( "tap", bgListener )

    buildLine( " The evil minotaur Asterion has" , 0 )
    buildLine( "terrorized the peaceful land"    , 1 )
    buildLine( "of Hallemot for countless years" , 2 )

    buildLine( " In his underground den, he and" , 4 )
    buildLine( "his minions enjoy the spoils of" , 5 )
    buildLine( "their wicked deeds."             , 6 )

    buildLine( " Determined to end his reign of" , 8 )
    buildLine( "plunder and pillage, a single"   , 9 )
    buildLine( "hero comes forth.."              , 10)


end

function postIntroFade()

    --Memory
    destroy();
    --Credits
    --doMainMenu();
    --Fade back in
    transition.to( display.getCurrentStage(), { time=1000, alpha=1 } );

end


function bgListener:tap( event )

    --Fade out
    transition.to( display.getCurrentStage(), { time=2000, alpha=0 , onComplete= postIntroFade } );

end


function destroy()

    bg:removeSelf();

end

