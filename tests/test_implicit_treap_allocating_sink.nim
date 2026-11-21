import std/[tables,unittest,strutils]
import atcoder/extra/structure/implicit_treap
var ledger=initTable[pointer,int]()
var serial,allocations,frees,destructors,copies,sinks,invalid:int
type Owner=object
  data:ptr int
  generation:int
proc allocateInto(x:var Owner)=
  inc serial;inc allocations
  x.data=cast[ptr int](alloc(sizeof(int)))
  x.data[]=serial;x.generation=serial
  ledger[cast[pointer](x.data)]=serial
proc acquire():Owner=allocateInto(result)
proc release(x:var Owner)=
  inc destructors
  if x.data!=nil:
    if ledger.getOrDefault(cast[pointer](x.data))!=x.generation:
      inc invalid
    else:
      ledger.del(cast[pointer](x.data));dealloc(x.data);inc frees
    # A destructor need not write a destroyed value. Deliberately leave it.
proc `=destroy`(x:var Owner)=release(x)
proc `=copy`(a:var Owner,b:Owner)=
  if a.data==b.data and a.generation==b.generation:return
  if b.data!=nil:doAssert ledger.getOrDefault(cast[pointer](b.data))==b.generation
  release(a)
  allocateInto(a)
  inc copies
proc `=sink`(a:var Owner,b:Owner)=
  release(a)
  if b.data==nil:
    # A logical empty guard may still allocate bookkeeping when copied/moved.
    allocateInto(a)
  else:
    doAssert ledger.getOrDefault(cast[pointer](b.data))==b.generation
    a.data=b.data;a.generation=b.generation
  inc sinks
# Resource identity is not part of the monoid value.
type V=tuple[sum,len:int,owner:Owner]
proc op(a,b:V):V=
  if a.len==0:return b
  if b.len==0:return a
  (a.sum+b.sum,a.len+b.len,default(Owner))
proc e():V=(0,0,default(Owner))
type Tree=ImplicitTreapType[V](op,e)
proc exercise(scene:string)=
  if scene=="owner_control":
    var a=acquire()
    a=default(Owner)
    doAssert a.data!=nil
    return
  if scene=="seq_control":
    var a= @[acquire()]
    doAssert a.len==1
    return
  var t=Tree.init()
  t.insert(0,(7,1,acquire()))
  if scene=="init":t.init()
  elif scene=="erased_init":
    discard t.erase(0)
    t.init()
  elif scene=="copy":
    var b=Tree.init()
    b.insert(0,(9,1,acquire()))
    t=b
    doAssert t.allProd().sum==9 and b.allProd().sum==9
  elif scene!="scope":raise newException(ValueError,"unknown case")

proc checkReleased()=
  for i in 0..<8:GC_fullCollect()
  doAssert invalid==0, "stale pointer or double destruction"
  doAssert ledger.len==0, "allocating empty sink left native resources alive"
  doAssert allocations==frees

var gcCreated,gcFreed:int
type Payload=ref object
  text:string
  values:seq[int]
proc finalize(p:Payload)=inc gcFreed
proc payload(x:int):Payload=
  new(result,finalize);inc gcCreated
  result.text=repeat($x,8);result.values= @[x,x+1]
type Mixed=tuple[sum,len:int,guard:Owner,p:Payload]
proc mixedOp(a,b:Mixed):Mixed=
  if a.len==0:return b
  if b.len==0:return a
  (a.sum+b.sum,a.len+b.len,default(Owner),nil)
proc mixedE():Mixed=(0,0,default(Owner),nil)
type MixedTree=ImplicitTreapType[Mixed](mixedOp,mixedE)
proc heapAndMixed()=
  var forest:seq[MixedTree]
  for i in 0..<64:
    var a=MixedTree.init()
    for j in 0..<8:a.insert(a.len,(i*8+j,1,acquire(),payload(i*8+j)))
    var b=a
    b.reverse(0,b.len)
    a=b
    b.init()
    doAssert a.get(0).p.values== @[i*8+7,i*8+8]
    forest.add(move(a))
    if i mod 8==0:GC_fullCollect()
  for i in 0..<forest.len:
    forest[i].reverse(0,forest[i].len)
    GC_fullCollect()
    doAssert forest[i].len==8
    for j in 0..<8:discard forest[i].erase(0)
    # Free slots may own default-value bookkeeping supplied by a user hook.
    forest[i].init()

suite "implicit treap allocating empty sink lifetime":
  test "standalone owner and seq controls are valid":
    exercise("owner_control");checkReleased()
    exercise("seq_control");checkReleased()
  test "pool destruction calls destructors without constructing default owners":
    exercise("scope");checkReleased()
  test "reinitialization of active and retired slots":
    exercise("init");checkReleased()
    exercise("erased_init");checkReleased()
  test "copy releases destination while source stays valid":
    exercise("copy");checkReleased()
  test "heap pools retain GC write barriers and release mixed resources":
    heapAndMixed();checkReleased()
    for i in 0..<16:GC_fullCollect()
    doAssert gcCreated==512 and gcFreed==gcCreated
