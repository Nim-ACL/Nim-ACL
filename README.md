# Nim-ACL
ACL (AtCoder Library) のNimによる実装です。
ACLで実装されているものはexpander含めてすべてNimに変換しています。
一部、Nim向けに使いやすくなるような仕様も追加しました。

## v0.5.3候補の対応環境
Nim 2.2.4と2.2.10を必須検証版とし、`nim cpp`を使用します。
パッケージの最低依存条件はNim 2.2.4です。これより古い版の互換性は未確認です。
`tools/nim_version_policy.json`の`atcoder_legacy`は過去環境の識別値であり、対応済みの宣言ではありません。
0.5.3はリリース候補です。Ubuntu/Windowsの候補SHAに対するCIと全体OJ検証の完了後に公開を判断します。

## expander
Nim-ACLの`import`・`include`を展開し、`combined.nim`を生成します。
`nim cpp`でコンパイルしてください。Python 3.8以降（lzmaを含む）とGitが必要です。

### モードとオプション
- `--mode bundle`（既定）: moduleの境界を保って格納し、コンパイル時に復元します。
- `--mode plain`: 参照moduleをその場へ展開します。
- `--mode embed`: 展開したmoduleを圧縮して格納します。
- `--lib LIB`: `src`を含むNim-ACLのディレクトリを指定します。
- `--output FILE`: 出力先を指定します。既定は`combined.nim`です。
- `--source-ref REF`: ライブラリの参照元Git commitを指定します。既定はローカルの`origin/master`です。
- `--tool-source-ref REF`: 圧縮出力のbootstrapに使うexpander本体の参照元を指定します。
- `--preview`: 未公開のbootstrapを使ったローカル検証用です。ライブラリの内容一致検査は省略しません。

`--compress`はembed、`--directory`はbundleを選ぶ互換オプションです。
全オプションは`python3 expander.py --help`で確認できます。

Nim-ACLのリポジトリ内で行うローカル検証例（提出用ではありません）:

```bash
python3 expander.py main.nim --lib . --source-ref HEAD --preview --output combined.nim
nim cpp -d:release --opt:speed combined.nim
```

bundle/embedのコンパイルにはコンパイラ側にもPythonが必要です。
Unixでは`python3`、Windowsでは`python`を使い、`NACL_PYTHON`で指定を変更できます。
提出に使う場合は、ライブラリとexpander本体に一致する公開済み参照を指定してください。
出典の内容一致と、公開されていたことの確認は別です。
出典・圧縮方式と過去の検証記録は[Expander資料](tools/EXPANDER_SUBMISSION.md)を参照してください。

## extra
ACLにないがよく使いそうなライブラリを独自に実装しています。
例えば、グラフ関連の処理(ダイクストラ法等)や累積和ライブラリなどがあります。こちらもexpanderで展開可能です。
大体、以下のスタンスで実装していきます。
* 仕様等はACLのものに統一(例: segtreeにおけるmapping, composition等の名称を二分木等の名称でも統一)
* 内部の処理にACLで実装済みのアルゴリズムが必要になった場合はACLのものを用いる
* C++, python等の他の主要言語の標準ライブラリと同等かそれ以上の環境を提供する。特に他の言語で標準搭載であるがNimでは実装されていないものも実装する。例えばC++におけるset/multiset, map/multiset, bitset等が該当し、SortedSet/SortedMultiSet, SortedMap/SortedMultiMap, BitSetという名前で実装しました。
  * これについては、どこまでやるかはちょっと悩みどころです。例えば、pythonのnumpyやC++のboostとかまでやろうとするとかなり大変そうです。
* 本家ACLほどの万全なサポートは行わないが、test, verifyはできるだけ書く
* READMEもできるだけ書く(英訳はできないかも)
* 将来ACLに実装された場合は順次そちらに置き換える

## verifyの実施方法
- [online-judge-tools/verification-helper](https://github.com/online-judge-tools/verification-helper/blob/master/README.ja.md#%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)を参考にpip installする
- [このドキュメント](https://github.com/online-judge-tools/verification-helper/blob/master/.verify-helper/docs/static/document.ja.md#%E5%AF%BE%E5%BF%9C%E3%82%B5%E3%83%BC%E3%83%93%E3%82%B9%E4%B8%80%E8%A6%A7)を参考にYUKICODER_TOKEN を取得し、環境変数を設定する。`export YUKICODER_TOKEN=xxx`
- `src/`に移動する
- すべてのverifyを通すには`oj-verify run`を実行する。初回は遅いので`-j N`(Nは論理コア数)をつけ並列処理が有効にすると良い
- 個別にverifyする場合は`oj-verify run verify/crt_test.nim`のようにpathを指定する

apple silicon上でverifyに失敗した場合
- apple siliconはonline-judge側でスタックサイズを大きくすることができません。`ulimit -s 65000`の実行で多くのテストが成功するようになります

## ドキュメント
* ドキュメントはこちらです。
  * https://nim-acl.github.io/Nim-ACL/document_ja/index.html

## 使用上の注意
* 本ライブラリをコンパイルする際にはcppでのコンパイル、つまりnim cppが必要です。atcoderでもcppでコンパイルされています。nim cでは動きません。
* mathという名前の標準ライブラリがあるので、import atcoder/mathとimport mathはバッティングします。両方importしたい場合は後者をimport std/mathとしましょう。

# References
- https://atcoder.jp/posts/517?lang=ja

## Local verification

For a compact local smoke test of the main library, extra FPS facade, monoid helpers, graph helpers, and generated documentation, run:

```bash
bash tools/quick_verify.sh
```

The script writes the full log to `/tmp/nacl_quick_verify.log` and prints a short `NACL RESULT` block at the end.

## Documentation publishing

To regenerate documentation, publish it to `gh-pages`, and run a short live-page sanity check:

```bash
bash tools/publish_docs.sh
```

The script writes the full log to `/tmp/nacl_publish_docs.log` and prints a short `NACL RESULT` block at the end.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the local verification, CI, and documentation publishing policy.
