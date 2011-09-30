

module(..., package.seeall)

currentBackgroundMusic = "menu.mp3";

local onMusicFinished;
onMusicFinished = function(event)
  media.playSound( currentBackgroundMusic, onMusicFinished )
end

function play( )

  media.playSound( currentBackgroundMusic, onMusicFinished )

end
