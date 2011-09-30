

module(..., package.seeall)

local bg;
local bgListener  = {};

local xy = require("lib_xy")

function build()

    bg = display.newImage( "Credits.png" )
    bg.x = xy.centerX;
    bg.y = xy.centerY;
    bg:scale( xy.scaleX , xy.scaleY );

    bg:addEventListener( "tap", bgListener )

end

function postCreditsFade()

    --Memory
    destroy();
    --Credits
    doMainMenu();
    --Fade back in
    transition.to( display.getCurrentStage(), { time=1000, alpha=1 } );

end


function bgListener:tap( event )

    --Fade out
    transition.to( display.getCurrentStage(), { time=2000, alpha=0 , onComplete= postCreditsFade } );

end


function destroy()

    bg:removeSelf();

end

