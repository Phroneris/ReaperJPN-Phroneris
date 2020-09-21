#!/usr/local/bin/perl

# use strict  ;	# デバッグ用
# use warnings;	# デバッグ用
use autodie ;	# エラー時に$@を得る


##### 文字エンコーディング関連

use utf8;					# このファイル内に直接書いたUTF-8文字列を全て内部文字列にする

my ($codeOS, $codeOSEnc);
BEGIN {						# useは真っ先に解釈されるので、変数との併用はBEGINによる先回りが要る
	$codeOS = 'cp932';
	$codeOSEnc = ":encoding(${codeOS})";
}
use open IN  => ':utf8';	# ファイル入力を全て ':encoding(UTF-8)' で行う
use open OUT => $codeOSEnc;	# ファイル出力を全て ':encoding(cp932)' で行う

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



##### 汎用関数

sub abort
{
	my ($err) = @_;
	$err = dc($err) if !Encode::is_utf8($err);	# 自前エラー文はUTF-8内部文字列、外からのはcp932バイト文字列
	print '【エラー】', $err, "\n", 'Enter キーを押して中断してください。';
	<STDIN>;
	exit 1;
}
sub findExt		# ファイル名と拡張子名を受けて、実在する拡張子つきファイル名を返す（無ければそのまま返す）
{
	my ($file, $ext) = @_;
	$ext = '.' . ($ext =~ s/^\.//r);
	$file .= ( grep { -f ec($file.$_) } ('', $ext, $ext.'.txt', '.txt') )[0]
		// &abort('ファイル "'.$file.'" をそれっぽい拡張子つきで見つけられませんでした。');
	return $file;
}
sub readFile
{
	my ($fileName, $ext) = @_;
	$fileName = &findExt($fileName, $ext);
	my $file;
	open $file, '<', ec($fileName);
	my $text = [<$file>];	# 行配列のリファレンス
	close $file;
	print '    読み込み完了: ', $fileName, "\n";
	return $text;
}
sub writeFile	# 書き込むテキストは配列なら要リファレンス
{
	my ($fileName, $text) = @_;
	my $file;
	open $file, '>', ec($fileName);
	my $textRef = ref \$text eq 'SCALAR' ? \$text : $text;		# スカラーそのものならリファレンス化
	$textRef = [( ${$textRef} )] if ref $textRef eq 'SCALAR';	# スカラーリファレンスなら配列リファレンス化
	print $file @{$textRef};
	close $file;
	print '    書き出し完了: ', $fileName, "\n";
}
sub CSVize
{
	my @data = @_;
	map { $_ = '"' . s/"/""/rg . '"' } @data;
	return join(',', @data) . "\n";
}


##### メイン処理

eval {

	my $word;
	my $nameTmpl;
	my $nameLnPk;
	my %namesDefault = (lnPk=>'JPN_Phroneris', tmpl=>'template_reaper613');
	my $lenMinWord = 3;
	my $extLnPk = '.ReaperLangPack';

	print '指定した英語文字列の使用状況を調査して CSV に出力するプログラムです。', "\n";
	print 'テンプレート内で文字列が使われている原文、言語パック内の同じ行の訳文、', "\n";
	print 'あとなんかその他諸々を列挙します。', "\n";
	print '※ 言語パックとテンプレートは各行ぴったり対応している必要があります', "\n";
	print '※ オプション行（;^）は調査しません', "\n";
	print "\n";

	print '使用状況を調査する、', $lenMinWord, ' 文字以上の英語文字列を入力してください:', "\n";
	print '※ 大文字・小文字は無視されます', "\n";
	print '※ 入力は正規表現の一部として使われます', "\n";
	print '> ';
	chomp($word = <STDIN>);
	&abort($lenMinWord.' 文字未満の文字列の調査はできません。') if (length $word) < $lenMinWord;
	print '    指定完了: ', $word, "\n";
	print "\n";

	print 'テンプレートファイル名を入力してください:', "\n";
	print '※ 1 つ上の階層から検索します', "\n";
	print '※ 空欄にすると "', $namesDefault{tmpl}, '" を使用します', "\n";
	print '> ';
	chomp($nameTmpl = <STDIN>);
	$nameTmpl = $namesDefault{tmpl} if $nameTmpl eq '';
	$nameTmpl = '../' . $nameTmpl;
	my @linesTmpl = map { tr/\x0d\x0a//rd } @{ &readFile($nameTmpl, $extLnPk) };
	print "\n";

	print '言語パックファイル名を入力してください:', "\n";
	print '※ 1 つ上の階層から検索します', "\n";
	print '※ 空欄にすると "', $namesDefault{lnPk}, '" を使用します', "\n";
	print '> ';
	chomp($nameLnPk = <STDIN>);
	$nameLnPk = $namesDefault{lnPk} if $nameLnPk eq '';
	$nameLnPk = '../' . $nameLnPk;
	my @linesLnPk = map { tr/\x0d\x0a//rd } @{ &readFile($nameLnPk, $extLnPk) };
	print "\n";

	print '処理中…', "\n";
	print "\n";
	my @linesList = &CSVize('行', 'セクション', 'ID', '原文', '訳文', '"'.$word.'" の訳');
	my $strSection = '';
	my $itemLast = 'この列は人力で埋めてね';
	my $numLine = 0;

	foreach my $strLine (@linesTmpl)
	{
		if ( $strLine =~ /^\[([^\[\]]+)\]/ )
		{
			$strSection = $1;
		}
		elsif ( $strLine =~ /^;(?<rxID>\w{16})=(?<rxTmpl>.*?${word}.*?)$/i )
		{
			my ($id, $wordsTmpl) = ($+{rxID}, $+{rxTmpl});
			my $wordsLnPk = $linesLnPk[$numLine];
			if ( $wordsLnPk =~ /^${id}=(?<rxLnPk>.*?)( ▲▼ .+)?$/ )
			{
				$wordsLnPk = $+{rxLnPk};
				push @linesList, &CSVize($numLine, $strSection, $id, $wordsTmpl, $wordsLnPk, $itemLast);
				$itemLast = '' if $itemLast;
			}
		}
		$numLine++;
	}

	$word =~ tr/\\\/:*?"<>|/￥／：＊？”＜＞｜/; # ファイル名に使えない記号を全角化
	&writeFile('wordUsageList_'.$word.'.csv', \@linesList);

};

&abort($@) if $@;	# エラー時に割り込んで即中断

print "\n";
print '処理完了。', "\n";
print 'Enter キーを押して終了してください。', "\n";
<STDIN>;

exit 0;


