import atcoder/extra/structure/mo

# This entry point alone must keep positional initMo(N, Q) and the Mo type.
var queries: Mo = initMo(5, 2)
queries.insert(0, 5)
queries.insert(2, 4)
var sum = 0
var answers = newSeq[int](2)
proc add(i: int) = sum += i + 1
proc remove(i: int) = sum -= i + 1
proc save(id: int) = answers[id] = sum
run(self = queries, add_left = add, add_right = add,
  delete_left = remove, delete_right = remove, rem = save)
doAssert answers == @[15, 7]
let constructor: proc(N, Q: int): Mo = initMo
let empty: Mo = constructor(0, 0)
proc ignore(i: int) = doAssert false
empty.run(ignore, ignore, ignore, ignore, ignore)
echo "legacy-only Mo API OK"
