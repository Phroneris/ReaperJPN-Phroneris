チェックアウトする際は .git/config ファイルに下記の設定を追記してください。

[filter "ignore-debug-pl"]
	smudge = cat
	clean = perl -pe \"s/^\\s*use\\s+(?=strict|warnings)/\\x23 use /g\"