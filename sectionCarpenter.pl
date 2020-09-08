#!/usr/local/bin/perl

# $ perl sectionCarpenter.pl [arg1 [arg2]]
#
# | Arg | Format | Role                      | Default
# |-----|--------|---------------------------|---------
# | 1   | 0/1/2  | Mode (Divide/Unify/Clone) | 0
# | 2   | string | File Name of LangPack     | 'JPN_Phroneris'
#
# Mode 0: Divide sections in LangPack into individual text files
# Mode 1: Unify section files into single LangPack file
# Mode 2: Clone LangPack as text files named after section titles
#         (Same as mode 0 except each content will be kept fully)
#
# Every mode overwrites existing files.
#



# use strict  ;	# デバッグ用
# use warnings;	# デバッグ用
use autodie ;	# エラー時に$@を得るため
use File::Copy 'copy';
use autodie    'copy';	# 大事


##### 文字エンコーディング関連

use utf8;								# このファイル内に直接書いたUTF-8文字列を全て内部文字列にする
use open IO => ':utf8';					# ファイル入出力を全て ':encoding(UTF-8)' で行う
use Encode qw/encode decode/;

my $enc_os = 'cp932';	# Windows JP
binmode STDIN,  ":encoding(${enc_os})";	# 標準入出力で cp932(見た目)⇔UTF-8(内部) と変換する
binmode STDOUT, ":encoding(${enc_os})";
binmode STDERR, ":encoding(${enc_os})";

sub du($) { decode('UTF-8', shift) };	# 内部文字列にする（文字コードを取り除く）
sub eu($) { encode('UTF-8', shift) };	# UTF-8にする
sub dc($) { decode($enc_os, shift) };
sub ec($) { encode($enc_os, shift) };
sub ed($) { ec(du(shift)) };	# デバッグ時にpで文字列が化けたら"ec $var"または"ed $var"で戻せることが多い
# sub isN($) { Encode::is_utf8(shift) ? 'naibu' : 'hadaka kamo...'; }


##### 汎用関数

sub abort
{
	my ($err, $dontDecode) = @_;
	$err = dc($err) unless $dontDecode;	# エラー文を自前で直接指定する場合、第2引数をtrueにしてデコードを避ける
	print '*ERROR*: ', $err, "\n", 'Press enter to abort.';
	<STDIN>;
	exit 1;
}
sub mightMkdir	# フォルダが無ければ作成（1階層だけ対応）、あればそのまま
{
	my $dir = shift;
	my $retVal = 0;
	if (!-d $dir)
	{
		eval { mkdir ec($dir) };
		&abort($@) if $@;
		print '    Directory created: ', $dir, "\n";
		$retVal = 1;
	}
	return $retVal;
}
sub findExt		# ファイル名を受けて、実在する拡張子つきファイル名を返す（無ければそのまま返す）
{
	my $fileName = shift;
	$fileName .= [ grep { -f ec($fileName.$_) } ('', '.ReaperLangPack', '.txt', '.ReaperLangPack.txt') ]->[0]
		// &abort("Can't find a file '${fileName}' with prescribed extension.", 1);
	return $fileName;
}
sub readFile	# オプションでファイルを丸呑みする（デフォルトでは行区切り）
{
	my ($fileName, $doSlurp, $dontPrint) = @_;
	$fileName = &findExt($fileName);
	my $file;
	eval { open $file, '<', ec($fileName) };
	&abort($@) if $@;
	my $text = $doSlurp ? do { local $/; <$file> } : [<$file>];	# 全体の単一スカラー / 行配列のリファレンス
	close $file;
	print '    File read: ', $fileName, "\n" unless $dontPrint;
	return $text;
}
sub writeFile	# 書き込むテキストは配列なら要リファレンス
{
	my ($fileName, $text, $dontPrint) = @_;
	# if ($fileName =~ /^(.+)[\/\\]/)
	# {
		# &mightMkdir($1);	# ループで回す度にこれやるのはアホらしいので却下
	# }
	my $file;
	eval { open $file, '>', ec($fileName) };
	&abort($@) if $@;
	my $textRef = ref \$text eq 'SCALAR' ? \$text : $text;	# スカラーそのものならリファレンス化
	$textRef = [( ${$textRef} )] if ref $textRef eq 'SCALAR';	# スカラーリファレンスなら配列リファレンス化
	print $file @{$textRef};
	close $file;
	print '    File written: ', $fileName, "\n" unless $dontPrint;
}
sub copyFile
{
	my ($origName, $broName) = @_;
	$origName = &findExt($origName);
	eval { copy(ec($origName), ec($broName)) };
	&abort($@) if $@;
	print '    File copied: ', $broName, "\n";
}
sub getSetSubDir	# オプションでディレクトリ作成を避ける
{
	my ($parent, $file, $dontMkdir) = @_;
	my $child = uc substr($file, 0, 1);
	&mightMkdir($parent . '/' . $child) if !$dontMkdir;
	return $child . '/';
}

##### メイン関数

my $secDir = 'sections';
my $secMapPath = "${secDir}/__section_map.txt";
my $sec0Name = '_description';

sub divide		# 言語パック内のセクションを、個別のファイルに分離
{
	my $lpName = shift;
	my @sections = split /^(?=\[)/m, &readFile($lpName, 1);
	&abort("This isn't langpack: ${lpName}", 1) if $sections[0] !~ /^#NAME:/;
	print "\n";
	my @secNames = map { /^\[([^\[\]]+)\]/ ? $1 : $sec0Name } @sections;
	print "\n" if &mightMkdir($secDir) == 1;
	my $i = 0;
	foreach my $secN (@secNames)
	{
		my $secText = $sections[$i];
		my $subDir = $i == 0 ? '' : &getSetSubDir($secDir, $secN);
		&writeFile("${secDir}/${subDir}${secN}.txt", $secText =~ s/[\x0d\x0a]+$//r . "\n");	# 末尾の改行は1個だけ
		$i++;
	}
	print "\n";
	&writeFile($secMapPath, [ map { $_."\n" } @secNames ]);
}
sub unify	# 個別ファイルのセクションを、単一の言語パックに統合
{
	my $lpName = shift =~ s/\.(ReaperLangPack|txt|ReaperLangPack\.txt)$//r;
	chomp(my @secNames = @{ &readFile($secMapPath) });
	print "\n";
	my @lpText = ();
	foreach my $secN (@secNames)
	{
		my $subDir = $secN eq $secNames[0] ? '' : &getSetSubDir($secDir, $secN, 1);
		push @lpText, &readFile("${secDir}/${subDir}${secN}.txt", 1) =~ s/[\x0d\x0a]+$//r . "\n";	# 末尾の改行は1個だけ
	}
	print "\n";
	print "\n" if &mightMkdir($secDir) == 1;
	&writeFile($lpName . '.ReaperLangPack', join("\n", @lpText));	# 間に空行を1つ設ける
}
sub clone		# 言語パックを、各セクション名を名前に持つ個別のファイルに複製
{
	my $lpName = shift;
	my $lpText = &readFile($lpName, 1);
	my @secNames = map { /^\[([^\[\]]+)\]/ ? $1 : $sec0Name } ( split /^(?=\[)/m, $lpText );
	print "\n";
	print "\n" if &mightMkdir($secDir) == 1;
	foreach my $secN (@secNames)
	{
		my $subDir = $secN eq $secNames[0] ? '' : &getSetSubDir($secDir, $secN);
		&copyFile($lpName, "${secDir}/${subDir}${secN}.txt");
	}
	print "\n";
	&writeFile($secMapPath, [ map { $_."\n" } @secNames ]);
}


##### メイン処理

my $isInteractive = $#ARGV < 0;	# このファイルを引数無しで直接実行した時
my $processMode  = $ARGV[0];
my $langPackName = $ARGV[1];
if ($isInteractive) {
	print 'Process Mode? [0=divide, 1=unify, 2=clone] > ';
	chomp($processMode = <STDIN>);
	print 'LangPack Name? > ';
	chomp($langPackName = <STDIN>);
	print "\n";
}
$processMode  = $processMode  || 0;		# 値が偽（0や空文字列など）の時のデフォルト
$langPackName = $langPackName || 'JPN_Phroneris';

if ($processMode eq 0) {	# 英字などの入力のためにeq
	print '* Dividing...', "\n\n";
	&divide($langPackName);
}
elsif ($processMode eq 1) {
	print '* Unifying...', "\n\n";
	&unify($langPackName);
}
elsif ($processMode eq 2) {
	print '* Cloning...', "\n\n";
	&clone($langPackName);
} else {
	&abort("Invalid process mode.", 1);
}

print "\n", 'Done.', "\n";
if ($isInteractive) {
	print 'Press enter to exit.', "\n";
	<STDIN>;
}

exit 0;


##### 墓場

# sub copyFile	# File::Copyを使わない版…だが遅いので没
# {
	# my ($origName, $broName) = @_;
	# $origName = &findExt($origName);
	# my @text = &readFile($origName, 0, 1);
	# &writeFile($broName, \@text, 1);
	# # &abort("Not found: $origName\n", 1) if !-f ec($origName);
	# # &abort("Not found: $broName\n" , 1) if !-f ec($broName);
	# print '    File copied: ', $broName, "\n";
# }
