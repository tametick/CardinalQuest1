

module(..., package.seeall)

newGameButton = nil;
creditsButton = nil;
highScoresButton = nil;

local bg;
local logo;
local creditsButtonListener  = {};
local newGameButtonListener  = {};

local xy = require("lib_xy")

local function createButton( text , nummer )

    local button = display.newText( text, xy.centerX, xy.centerY, "AnonymousPro", 40 )
    button:setReferencePoint( display.CenterReferencePoint )
    button.x = xy.centerX;
    button.y = xy.bottomY+nummer*70;
    button:setTextColor( 0,0,0 )
    transition.to( button, { time=1000, y = xy.centerY+nummer*70  } )
    return button;

end


function build()

    --Play the gate sound
    media.playEventSound( "fortressGate.mp3" )

    bg = display.newImage( "mainmenuBg.png" )
    bg.x = xy.centerX;
    bg.y = xy.centerY;
    bg:scale( xy.scaleX , xy.scaleY );

    logo = display.newImage( "logo.png" )
    logo:scale( xy.scaleX , xy.scaleY );
    logo.x = xy.centerX
    logo.y = xy.topY;

    transition.to( logo, { time=1000, y=display.contentHeight / 5 * 2  } )

    newGameButton    = createButton( "New Game"   , 0 )
    creditsButton    = createButton( "Credits"    , 1 )
    --highScoresButton = createButton( "Highscores" , 2 )

    creditsButton:addEventListener( "tap", creditsButtonListener )
    newGameButton:addEventListener( "tap", newGameButtonListener )

end

function postCreditsFade()

    --Memory
    destroy();
    --Credits
    doCredits();
    --Fade back in
    transition.to( display.getCurrentStage(), { time=1000, alpha=1 } );

end


function creditsButtonListener:tap( event )

    --Play the clicky sound, Ido this is probably the wrong clip..
    media.playEventSound( "enemyMiss.mp3" )
    --Fade out
    transition.to( display.getCurrentStage(), { time=1000, alpha=0 , onComplete= postCreditsFade } );

end

function newGameButtonListener:tap( event )

    -- Go to the intro screen with the firey minotaur
    destroy();
    -- Intro
    doIntro();

end



function destroy()

    bg:removeSelf();
    logo:removeSelf();
    newGameButton:removeSelf();
    creditsButton:removeSelf();
    --highScoresButton:removeSelf();

end

