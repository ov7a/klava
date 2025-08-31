import std/core/undiv

// very similar to sslice, but grants access to individual chars
struct sview
  data: vector<char>
  start: int
  length: int

pub fun view(s: string): sview
  val data = s.vector
  Sview(data, 0, data.length)

pub fun string(view: sview): string
  view.data
    .list
    .drop(view.start)
    .take(view.length)
    .string

pub fun at(view: sview, pos: int): maybe<char>
  match pos 
    valid | valid >= 0 && valid < view.length -> view.data.at(view.start + pos)
    negative | negative < 0 && ~negative < view.length -> view.data.at(view.start + view.length + pos)
    _ -> Nothing

pub fun index-of(v: sview, pred: char -> e bool, idx: int = 0): e maybe<int>
  match v.data.at(v.start + idx)
    Just(c) | idx < v.length -> 
      if (pred(c)) then 
        Just(idx)
      else
        index-of(pretend-decreasing(v), pred, idx + 1)
    _ -> Nothing

pub fun drop-last(view: sview, n: int): sview
  val Sview(data, start, length) = view
  Sview(data, start, length - n)  

pub fun string/ends-with(v: sview, end: string): bool
  ends-with(v, end.view)

pub fun ends-with(view: sview, end: sview): bool
  var i := view.start + view.length - 1
  var j := end.start + end.length - 1
  pretend-no-div
    while { (i >= view.start) && (view.data.at(i) == end.data.at(j)) }
      i := i - 1
      j := j - 1
  (j == end.start - 1) && (i == view.start + view.length - end.length - 1)
    