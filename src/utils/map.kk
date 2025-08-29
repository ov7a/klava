import std/data/rb-map
import std/data/rbtree
import std/data/buffer
import std/core/list

pub alias map = rbmap

pub fun to-map<k, v>(pairs: list<(k, v)>, ^?order2: (k,k) -> e order2<k>): e map<k, v>
  pairs.foldl(rb-map/empty(), fn(acc, (k, v)) acc.add(k, v))

pub fun get<k, v>(m: map<k, v>, k: k, ^?order2: (k,k) -> e order2<k>): e maybe<v>
  m.lookup(k)

pub fun empty-map<k, v>(): map<k, v>
  empty()

pub fun upsert<k, v>(m: map<k, v>, k: k, f: (maybe<v>) -> e v, ^?order2: (k,k) -> e order2<k>): e map<k, v>
  m.insert(k, f)

pub fun to-list<k, v>(m: map<k, v>): list<(k, v)>
  m.list 

pub fun size<k, v>(m: map<k, v>): int
  m.keys.length

pub fun merge<k, v>(
  m: map<k, v>, 
  other: map<k, v>, 
  merger: (v, v) -> e v, 
  ^?order2: (k,k) -> e order2<k>
): e map<k, v>
  other.list.foldl(m, fn(current, (k, new))
    current.insert(k, fn(existing)
      match existing
        Just(old) -> merger(old, new)
        Nothing -> new
    )
  )

pub fun map/values<k, v>(m: map<k, v>): list<v>
  m.rb-map/values

pub fun map-values<k, v, t>(m: map<k, v>, f: (v) -> e t, ^?order2: (k,k) -> e order2<k>): e map<k, t>
  m.value/map(f)

pub fun kmap-values<k, v, t>(m: map<k, v>, f: (k, v) -> e t, ^?order2: (k,k) -> e order2<k>): e map<k, t>
  m.kvalue/map(f)

pub fun successors-matching(m: map<k, v>, start: k, matcher: (k) -> e bool, ^?order2: (k,k) -> e order2<k>) : e list<v>
  val Rbmap(tree) = m 
  successors-matching-impl(tree, start, matcher, buffer(), order2).list

fun successors-matching-impl(
  tree: rbtree<k,v>, 
  start: k,
  matcher: (k) -> e bool,
  acc: buffer<v>,
  ^?order2: (k,k) -> e order2<k>
): e buffer<v>
  match tree
    Leaf -> acc
    Node(_, l, kx, v, r) ->
      match order2(start, kx)
        Lt2 ->
          val updated = successors-matching-impl(l, start, matcher, acc)
          if (matcher(kx)) then
            successors-matching-impl(r, start, matcher, updated.append(v))
          else  
            updated  
        _ -> 
          successors-matching-impl(r, start, matcher, acc)
