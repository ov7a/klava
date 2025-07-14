import std/num/float64

import utils/map
import core/index

pub struct page
  url: string
  title: string
  tags: list<string>
  tags_tokens: list<token>
  title_tokens: list<token> 
  body_tokens: list<token>

fun update_terms(
  current: map<token, term_index>, 
  doc_id: doc_id,
  terms: list<token>, 
  score: score
): map<token, term_index>
  val terms_map = terms.map(fn(token) -> (
    token,
    Term_index(
      total = score, 
      docs = [(doc_id, score)].to-map()
    )
  )).to-map

  current.merge(terms_map, fn(ti1, ti2) ->
    Term_index(
      total = ti1.total + ti2.total,
      docs = ti1.docs.merge(ti2.docs, (+))
    )
  )

fun update_index(
  current: map<token, term_index>, 
  next: (doc_id, page)
): map<token, term_index>
  val (doc_id, page) = next
  current
    .update_terms(doc_id, page.tags_tokens, 10)
    .update_terms(doc_id, page.title_tokens, 5)
    .update_terms(doc_id, page.body_tokens, 1)

fun to_doc(page: page): doc
  Doc(
    url = page.url,
    title = page.title,
    tags = page.tags
  )

fun length(page: page): int
  page.tags_tokens.length + page.title_tokens.length + page.body_tokens.length

// for BM25
fun get_len_normalizers(pages: list<page>): vector<float64>
 val lengths = pages.map(length)
 val vec = lengths.vector
 val average_length = lengths.sum.float64 / vec.length.float64
 vec.map fn(len)
   1.5 * (0.25 + 0.75 * len.float64 / average_length)

pub fun index(pages: list<page>): index
  val docs = pages.vector.map(to_doc)
  val terms = pages.map-indexed(fn(idx, page) -> (idx, page)).foldl(empty-map(), update_index)
  val normalizers = pages.get_len_normalizers()

  Index(
    docs = docs,
    terms = terms,
    normalizers = normalizers
  )