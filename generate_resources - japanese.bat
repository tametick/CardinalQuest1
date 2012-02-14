@echo off
cqTextEmbed.exe bin.jp

@cd ".\rsrc\cq\"
swfmill simple "resources - japanese.xml" "resources - japanese.swf"

pause
