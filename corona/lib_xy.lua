
module(..., package.seeall)

--Centers
centerX = display.contentWidth / 2;
centerY = display.contentHeight / 2;

-- On some devices the top will not be 0...
leftX    = 0;
rightX   = display.contentWidth;
topY     = 0;
bottomY  = display.contentHeight;

--Minor shortcut so we dont have to resize the graphics
scaleX = 8/5;
scaleY = 4/3;
