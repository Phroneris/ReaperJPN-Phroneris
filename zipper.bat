set here=%~dp0
set here=%here:~0,-1%
cd %here%
set tmp=tmp
"C:\Program Files (x86)\Lhaplus\Lhaplus.exe" /c:zip /n:"%here%\%tmp%" /o:"%here%" .\JPN_Phroneris.ReaperLangPack .\readme.txt .\history.txt
move %tmp%.zip JPN_Phroneris.zip
rmdir %tmp%