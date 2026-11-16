when not declared ATCODER_EXTRA_ALGORITHM_MO_HPP:
  const ATCODER_EXTRA_ALGORITHM_MO_HPP* = 1

  import atcoder/extra/algorithm/internal/mo_core
  # In a flattened submission the first imported entry point owns the short
  # type alias. Constructors and operations always use their exact state type.
  when not declared(Mo):
    type Mo* = MoState[false]
  export MoQuery, len, addQuery, orderedQueries

  proc initMo*(n: int, blockSize = 0): MoState[false] =
    ## Creates a Mo query container; blockSize = 0 selects sqrt(n).
    initMoState[false](n, blockSize)

  proc run*(
    mo: MoState[false],
    addLeft: proc(index: int) {.closure.},
    addRight: proc(index: int) {.closure.},
    removeLeft: proc(index: int) {.closure.},
    removeRight: proc(index: int) {.closure.},
    answer: proc(queryId: int) {.closure.}
  ) =
    mo.runMoQueries(addLeft, addRight, removeLeft, removeRight, answer)

  proc run*(
    mo: MoState[false],
    add: proc(index: int) {.closure.},
    remove: proc(index: int) {.closure.},
    answer: proc(queryId: int) {.closure.}
  ) =
    mo.runMoQueries(add, add, remove, remove, answer)
