set here=%~dp0
set here=%here:~0,-1%
cd %here%
set tmp=tmp
set nonWinLangPack=JPN_Phroneris-Mac_Linux.ReaperLangPack
call forNonWindows.pl "%nonWinLangPack%"
"C:\Program Files (x86)\Lhaplus\Lhaplus.exe" /c:zip /n:"%here%\%tmp%" /o:"%here%" .\JPN_Phroneris.ReaperLangPack .\readme.txt .\history.txt ".\%nonWinLangPack%"
move %tmp%.zip JPN_Phroneris.zip
rmdir /s /q %tmp%
REM del "%nonWinLangPack%"
REM pause
