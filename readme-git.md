初回チェックアウトの直後、`.git/config` ファイルに下記の設定を追記してください。

```ini
[include]
	path = ../.gitconfig
```

**nkf** を未導入の場合、[nkf v2.1.1](https://www.vector.co.jp/soft/win95/util/se295331.html) から `nkf.exe` を入手し、お使いの Git の `usr/bin/` 下に置いた方が良いかもしれません。

上記諸々が済んだら、`.gitconfig` 内のフィルターを確実に適用するために、`rm .git/index && git checkout HEAD -- .` か何かで再チェックアウトした方が良い気がします。

----

もっと詳細・複雑・具体的なことについては、Wiki の方で色々と解説する可能性があります。
