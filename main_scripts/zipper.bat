@echo off

REM バッチ自身のパスを取得（最後に区切り文字が付くので削除）
set here=%~dp0
set here=%here:~0,-1%

REM ルートに移動してパスを取得（最後に区切り文字は付かない）
cd %here%
cd ..
set root=%cd%

REM 非Windows用パッチを作成
set forNonWin=forNonWindows.pl
set nonWinLangPack=JPN_Phroneris-Mac_Linux.ReaperLangPack
@echo on
call "%here%\%forNonWin%" "%nonWinLangPack%"
@echo off
if %errorlevel% neq 0 (
	echo,
	echo %forNonWin% の実行に失敗しました。ZIP ファイルを作らず終了します。
	pause
	exit /b 1
)

REM ZIPファイルを作成
set tmp=tmp
@echo on
"C:\Program Files (x86)\Lhaplus\Lhaplus.exe" /c:zip /n:"%root%\%tmp%" /o:"%root%" .\JPN_Phroneris.ReaperLangPack .\readme.txt .\history.txt ".\%nonWinLangPack%"
move %tmp%.zip JPN_Phroneris.zip
rmdir /s /q %tmp%
@echo off
REM del "%nonWinLangPack%"
REM pause

exit /b 0
