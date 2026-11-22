# Moの旧API互換入口

`atcoder/extra/algorithm/mo` と同じ内部コアを使います。旧実装の
並べ替え・区間移動処理は削除し、このファイルはAPI変換だけを担います。

## importとAPI

~~~nim
import atcoder/extra/structure/mo

proc initMo(N, Q: int): Mo
proc insert(self: var Mo, l, r: int)
proc initMo(N: int, l, r: seq[int]): Mo
proc run(self: Mo, add_left, add_right, delete_left, delete_right, rem)
~~~

`initMo(N, Q)` の第2引数はquery数です。`insert`でちょうどQ件を
登録してから`run`を呼びます。区間は半開区間 `[l, r)` です。
Q依存のblock幅、偶数blockの右端降順・奇数blockの昇順、登録順のquery IDを維持します。
`rem(id)`に結果を保存してください。callbackは左追加・右追加・左削除・右削除の順で渡します。

<!-- nim-line-numbers -->
~~~nim
import atcoder/extra/structure/mo

var queries: Mo = initMo(5, 2)
queries.insert(0, 3)
queries.insert(1, 5)
var total = 0
var answers = newSeq[int](2)
proc add(i: int) = total += i + 1
proc remove(i: int) = total -= i + 1
proc save(id: int) = answers[id] = total
queries.run(add, add, remove, remove, save)
doAssert answers == @[6, 14]
~~~

## 計算量と移行

block幅Bに対し `O(Q log Q + Q B + N^2 / B)` 回程度の処理
（端点移動ごとにcallbackのコスト）、保存領域 `O(Q)` です。
新規コードでは[algorithm/mo](../algorithm/mo.html)を推奨します。
新APIの `initMo(n, blockSize)` は第2引数の意味が異なります。
両入口をimportするときは `Q = ...` / `blockSize = ...` を指定してください。
