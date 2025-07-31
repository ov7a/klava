import std/data/json

import core/index
import utils/map
import utils/json

fun term-index/to-json(term: term_index): json
  JSObj([
    ("total", term.total.to-json),
    ("docs", term.docs.to-json)
  ])  

fun doc/to-json(doc: doc): json
  JSObj([
    ("url", doc.url.to-json),
    ("title", doc.title.to-json),
    ("tags", doc.tags.to-json)
  ])

fun index/to-json(index: index): json
  JSObj([
    ("docs", index.docs.to-json),
    ("terms", index.terms.to-json(?show = id)),
    ("norms", index.normalizers.to-json)
  ])

pub fun serialize(index: index): string
  index.to-json.show

fun term_index/from-json(j: json, path: string): pure term_index
  val obj = j.as-object(path)
  Term_index(
    total = obj.dict/from-json("total", "total"),
    docs = obj.dict/from-json("docs", "docs")
  )

fun doc/from-json(j: json, path: string): pure doc
  val obj = j.as-object(path)
  Doc(
    url = obj.dict/from-json("url", "url"),
    title = obj.dict/from-json("title", "title"), 
    tags = obj.dict/from-json("tags", "tags")
  )

pub fun deserialize(input: string): pure index
  val json = input.parse.as-object("")
  Index(
    docs = json.dict/from-json("docs", "docs"),
    terms = json.dict/from-json("terms", "terms"),
    normalizers = json.dict/from-json("norms", "norms")
  )