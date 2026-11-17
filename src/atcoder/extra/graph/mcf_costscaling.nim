when not declared ATCODER_MCF_COSTSCALING_HPP:
  const ATCODER_MCF_COSTSCALING_HPP* = 1
  type
    MCFEdge*[Cap, Cost] = object
      src*, dst*: int
      cap*, flow*: Cap
      cost*: Cost
  
    MCFCostScaling*[Cap, Cost; SCALING: static[int] = 1;
                    REFINEMENT_ITER: static[int] = 20] = object
      n*: int
      cap: seq[Cap]
      cost: seq[Cost]
      opposite: seq[int]
      dst: seq[seq[int]]
      b: seq[Cap]
      p: seq[Cost]
  
  proc initMCFCostScaling*[Cap, Cost; SCALING: static[int] = 1;
                           REFINEMENT_ITER: static[int] = 20](
      n: int
    ): MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER] =
    MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER](n:n, dst: newSeq[seq[int]](n), b: newSeq[Cap](n), p:newSeq[Cost](n))

  proc addEdge*[Cap, Cost; SCALING: static[int]; REFINEMENT_ITER: static[int]](
      self: var MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER],
      src, dst: int, capVal: Cap, costVal: Cost
    ): int  {.discardable.} =
    doAssert 0 <= src and src < self.n
    doAssert 0 <= dst and dst < self.n
    doAssert capVal >= 0
  
    let scaledCost = costVal * Cost(self.n + 1)
    let e = self.cap.len
  
    self.dst[src].add e
    self.cap.add capVal
    self.cost.add scaledCost
    self.opposite.add dst
  
    self.dst[dst].add e + 1
    self.cap.add Cap(0)
    self.cost.add -scaledCost
    self.opposite.add src
  
    result = e div 2
  
  proc addSupply*[Cap, Cost; SCALING: static[int]; REFINEMENT_ITER: static[int]](
      self: var MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER],
      v: int, supply: Cap
    ) =
    self.b[v] += supply
  
  proc addDemand*[Cap, Cost; SCALING: static[int]; REFINEMENT_ITER: static[int]](
      self: var MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER],
      v: int, demand: Cap
    ) =
    self.addSupply(v, -demand)
  
  proc solveAs*[Cap, Cost, RetCost; SCALING: static[int]; REFINEMENT_ITER: static[int]](
      self: var MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER],
      _: typedesc[RetCost]
    ): RetCost =
    var eps = Cost(1)
    var que: seq[int] = @[]
  
    for c in self.cost:
      while eps <= -c:
        eps = eps shl SCALING
  
    # Even zero costs need one phase to route nonzero balances. Clamp the
    # first phase instead of shifting 1 upward, which could overflow Cost.
    var firstPhase = true
    while true:
      eps = eps shr SCALING
      if eps == Cost(0):
        if not firstPhase:
          break
        eps = Cost(1)
      firstPhase = false
  
      block refinePhase:
        var allBalanced = true
        for i in 0 ..< self.n:
          if self.b[i] != 0:
            allBalanced = false
            break
  
        if allBalanced:
          var pp = self.p
          var refined = false
          for _ in 0 ..< REFINEMENT_ITER:
            var changed = false
            for e in 0 ..< self.cap.len:
              if self.cap[e] == 0:
                continue
              let i = self.opposite[e xor 1]
              let j = self.opposite[e]
              let cand = pp[i] + self.cost[e] + eps
              if pp[j] > cand:
                pp[j] = cand
                changed = true
            if not changed:
              self.p = pp
              refined = true
              break
          if refined:
            continue
  
      # saturate negative reduced cost edges
      for e in 0 ..< self.cap.len:
        let i = self.opposite[e xor 1]
        let j = self.opposite[e]
        let cpij = self.cost[e] + self.p[i] - self.p[j]
        if self.cap[e] != 0 and cpij < 0:
          let f = self.cap[e]
          self.b[i] -= f
          self.b[j] += f
          self.cap[e xor 1] += f
          self.cap[e] = 0
  
      que.setLen(0)
      var qh = 0
      for i in 0 ..< self.n:
        if self.b[i] > 0:
          que.add i
  
      var iters = newSeq[int](self.n)
  
      while qh < que.len:
        let i = que[qh]
        inc qh
  
        while iters[i] < self.dst[i].len and self.b[i] != 0:
          let e = self.dst[i][iters[i]]
          inc iters[i]
  
          if self.cap[e] == 0:
            continue
  
          let j = self.opposite[e]
          let cpij = self.cost[e] + self.p[i] - self.p[j]
          if cpij >= 0:
            continue
  
          let f = (if self.b[i] > self.cap[e]: self.cap[e] else: self.b[i])
  
          if self.b[j] <= 0 and self.b[j] + f > 0:
            que.add j
  
          self.b[i] -= f
          self.b[j] += f
          self.cap[e] -= f
          self.cap[e xor 1] += f
  
        if self.b[i] > 0:
          var found = false
          var best = self.p[i]
          for e in self.dst[i]:
            if self.cap[e] == 0:
              continue
            let x = self.p[self.opposite[e]] - self.cost[e] - eps
            if (not found) or x > best:
              found = true
              best = x
          self.p[i] = best
          que.add i
          iters[i] = 0
  
    result = RetCost(0)
    var e = 0
    while e < self.cap.len:
      result += RetCost(self.cost[e]) * RetCost(self.cap[e xor 1])
      e += 2
  
    result = result div RetCost(self.n + 1)
  
  proc solve*[Cap, Cost; SCALING: static[int]; REFINEMENT_ITER: static[int]](
      self: var MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER]
    ): Cost =
    self.solveAs(Cost)
  
  proc potential*[Cap, Cost; SCALING: static[int]; REFINEMENT_ITER: static[int]](
      self: MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER]
    ): seq[Cost] =
    result = self.p
    var c0 = self.cost
  
    for i in 0 ..< result.len:
      result[i] = result[i] div Cost(self.n + 1)
    for i in 0 ..< c0.len:
      c0[i] = c0[i] div Cost(self.n + 1)
  
    while true:
      var changed = false
      for i in 0 ..< self.n:
        for e in self.dst[i]:
          if self.cap[e] == 0:
            continue
          let j = self.opposite[e]
          let y = result[i] + c0[e]
          if result[j] > y:
            result[j] = y
            changed = true
      if not changed:
        break
  
  proc getEdge*[Cap, Cost; SCALING: static[int]; REFINEMENT_ITER: static[int]](
      self: MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER],
      e: int
    ): MCFEdge[Cap, Cost] =
    let m = self.cap.len div 2
    doAssert 0 <= e and e < m
    result.src = self.opposite[e * 2 + 1]
    result.dst = self.opposite[e * 2]
    result.cap = self.cap[e * 2] + self.cap[e * 2 + 1]
    result.flow = self.cap[e * 2 + 1]
    result.cost = self.cost[e * 2] div Cost(self.n + 1)
  
  proc edges*[Cap, Cost; SCALING: static[int]; REFINEMENT_ITER: static[int]](
      self: MCFCostScaling[Cap, Cost, SCALING, REFINEMENT_ITER]
    ): seq[MCFEdge[Cap, Cost]] =
    let m = self.cap.len div 2
    result = newSeq[MCFEdge[Cap, Cost]](m)
    for i in 0 ..< m:
      result[i] = self.getEdge(i)
