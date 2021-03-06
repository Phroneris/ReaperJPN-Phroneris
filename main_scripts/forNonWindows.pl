#!/usr/local/bin/perl

# use strict  ;	# デバッグ用
# use warnings;	# デバッグ用
use autodie ;	# エラー時に$@を得る


##### 文字エンコーディング関連

use utf8;					# このファイル内に直接書いたUTF-8文字列を全て内部文字列にする

my $codeOS = 'cp932';		# Windows JP
my $codeOSEnc = ":encoding(${codeOS})";
binmode STDIN,  $codeOSEnc;	# 標準入出力で cp932(見た目)⇔UTF-8(内部) と変換する
binmode STDOUT, $codeOSEnc;
binmode STDERR, $codeOSEnc;

use Encode ();
sub du($) { Encode::decode('UTF-8', shift) };	# 内部文字列にする（文字コードを取り除く）
sub eu($) { Encode::encode('UTF-8', shift) };	# バイト文字列にする（UTF-8）
sub dc($) { Encode::decode($codeOS, shift) };
sub ec($) { Encode::encode($codeOS, shift) };
sub ed($) { ec(du(shift)) };	# デバッグ時にpで文字列が化けたら"ec $var"または"ed $var"で戻せることが多い
# sub isN($) { Encode::is_utf8(shift) ? 'naibu' : 'hadaka kamo...'; }


##### その他モジュール

use FindBin;	# スクリプト自身のパスを得る



##### 汎用関数

sub abort
{
	my ($err) = @_;
	$err = dc($err) if !Encode::is_utf8($err);	# 自前エラー文はUTF-8内部文字列、外からのはcp932バイト文字列
	print '*ERROR*: ', $err, "\n", 'Press enter to abort.';
	<STDIN>;
	exit 1;
}


##### メイン処理

eval {

	chdir $FindBin::Bin;	# 必ず日本語化プロジェクトのルートディレクトリに移動して作業
	chdir '..';				# （なお、呼び出し元のコマンドプロンプトの作業ディレクトリは変わらない）

	my $winLangPack = 'JPN_Phroneris.ReaperLangPack';
	my $nonWinLangPack = $ARGV[0] // 'JPN_Phroneris-Mac_Linux.ReaperLangPack';
	my $file;

	print '* Reading "', $winLangPack, '" ...', "\n";
	open $file, '<:encoding(UTF-8)', ec($winLangPack);
	my @txt = <$file>;
	close $file;

	print '* Processing...', "\n";
	map { s/ ?\(&.\)|[\x0d\x0a]//g } @txt;	# アクセスキー、CR、LFを削除
	$txt[0] = $txt[0].'…Mac/Linux';		# パッチ名を変更
	map { $_=$_."\x0a" } @txt;				# LFで改行

	print '* Writing "', $nonWinLangPack, '" ...', "\n";
	# ↓rawはLF化に必須。encodingと逆順だとWide character警告祭。無指定だとWindowsでは勝手にCRLF化される（$/や$\も無力）。
	open $file, '>:raw:encoding(UTF-8)', ec($nonWinLangPack);
	print $file @txt;
	close $file;

};

&abort($@) if $@;	# エラー時に割り込んで即中断

print "\n", 'Done.', "\n";
if ($#ARGV < 0) {	# このファイルを引数無しで直接実行した時
	print 'Press enter to exit.', "\n";
	<STDIN>;
}

exit 0;


##### 改行仕様参考: https://perldoc.jp/docs/perl/5.26.1/perlport.pod#Newlines
##### LFとUTF-8の両立参考: https://pikio.hatenadiary.org/entry/20090820/1250785105
