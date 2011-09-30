--
-- Abstract: Hello World sample app
--
-- Version: 1.0
--
-- Copyright (C) 2009 ANSCA Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in the
-- Software without restriction, including without limitation the rights to use, copy,
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
-- and to permit persons to whom the Software is furnished to do so, subject to the
-- following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


--Load Libraries
local music = require("lib_music");


--Load States
local mainmenu = require("state_mainmenu")
local credits  = require("state_credits")
local intro    = require("state_intro")

--Start with the music
music.currentBackgroundMusic = "menu.mp3";
--music:play( );

--Declare all the States here,
--I am thinking for now to have the transitions be defined here
--states should aggressively kill themselves when moving to another state
--with the exception of GameState of course

function doMainMenu()
    mainmenu:build();
end

function doCredits()
    credits:build();
end

function doIntro()
    intro:build();
end

for k,v in pairs(native.getFontNames()) do print(k,v) end

--Now show the mainmenu
doMainMenu();




