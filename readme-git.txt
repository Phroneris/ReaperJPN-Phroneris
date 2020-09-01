チェックアウトする際は .git/config ファイルに下記の設定を追記してください。

[filter "ignore-debug-pl"]
	smudge = cat
	clean = perl -pe \"s/^(?=use (strict|warnings))/\\x23 /g\"