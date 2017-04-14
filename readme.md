製品版REAPER日本語化パッチ（森） ver 5.22.001
====

### 説明
「製品版REAPER日本語化パッチ（森）」は、  
DAW ソフト [REAPER][1] の**製品版**を日本語化するパッチです。**製品版**をです。  
パッチは ver 5.22.001 、対応 REAPER は ver 5.22 です。  

### 使い方
zip で丸ごとダウンロードし、  
"JPN_Phroneris.ReaperLangPack" をダブルクリックとか何とかして適用してください。  
あるいは [OneDrive][0] や [REAPER Stash][0.1] から、余計なもの無しのダウンロードも可能です。  

----

### REAPER 日本語化パッチってもうあるじゃん
それの派生版です。  
2015/10/10 時点の [ちえ様のパッチ][2]に対して、独自の Perl ツールで中身の見づらさを解消・整理し、  
ついでに[後正面様によるサイズ修正][3]も採り入れて作成したものが元になっています。  
よって、翻訳の大部分は先方のものを許可を得て利用しています。  
初公開時点では実質的に元のものとほぼ同じパッチでしたが、少しずつ翻訳が進んでいます。  

### "tool" フォルダは何なの
普通に日本語化ファイルが欲しい人には無用です。  
上述の「独自の Perl ツール」と、その使用後の成果物です。説明書はありません。   
バージョンのすり合わせには[公式マージツール][1.2]が存在するのですが、  
それによって作られるパッチファイルの中身が見づらく感じたので開発しました。  

### 翻訳や開発に協力したい
是非。  
Fork（複製）して編集して Pull Request を下さい。  

### レイアウトがボゴボゴに崩れる
今のところ仕様です。  
ちえ様の方ではその辺も含めた開発をされていた気がします。私はしてないです。  

### なんか上手くいかない
ドンマイ。  

----

### 作者
森の子リスのミーコの大冒険  
* http://phroneris.com/  
* https://twitter.com/Phroneris  
* phroneris@gmail.com
* 配布ページ - https://github.com/Phroneris/ReaperJPN-Phroneris

### Thanks（敬称略）
* Cockos - [REAPER][1] / [REAPER Language Packs][1.5]
* ちえ - [REAPERJapanesePatcher][2]
* 後正面 - [ポジティブ・アレルギー REAPER：センド画面の見切れ問題がVer5でついに解決][3]

[0]: https://onedrive.live.com/redir?resid=436219A2C575511B!1235&authkey=!AAJZFy_cBzWtVwU&ithint=folder%2cReaperLangPack
[0.1]: http://stash.reaper.fm/v/27131/JPN_Phroneris.zip
[1]: http://www.reaper.fm/
[1.2]: http://www.reaper.fm/langpack/index.php#langpack_dev
[1.5]: http://www.reaper.fm/langpack/
[2]: https://github.com/chiepomme/REAPERJapanesePatcher
[3]: http://positiveallergy.blog50.fc2.com/blog-entry-723.html