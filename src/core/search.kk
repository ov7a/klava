import std/num/float64
import std/data/sort

import utils/map
import core/index
import core/stem

pub alias result = doc

fun idf(total_docs: int, doc_frequency: int): float64
  ln((1.0 + total_docs.float64) / (1.0 + doc_frequency.float64))

fun bm25(term_frequency: score, total_docs: int, doc_frequency: int, doc_len_normalizer: float64): float64
  1.75 * (term_frequency.float64) / (term_frequency.float64 + doc_len_normalizer) * 
    idf(total_docs, doc_frequency)

fun scores(term_index: term_index, total_docs: int, normalizers: vector<float64>): map<doc_id, float64>
  term_index
    .docs
    .kmap-values fn(doc_id, score)
      bm25(score, total_docs, term_index.total, normalizers.at(doc_id).default(0.0))

// prefix variable name causes an error, see https://github.com/koka-lang/koka/issues/796
fun prefix_search(m: map<string, v>, prefx: string): list<v>
  m.successors-matching(prefx, _.starts-with(prefx).is-just)

pub fun search(index: index, query: string): <exn> list<result>
  val tokens = query
    .tokenize

  val exacth_matches = tokens  
    .flatmap-maybe(index.terms.get(_))
    .map(scores(_, index.docs.length, index.normalizers))

  val prefix_matches = tokens
    .last.list
    .flatmap(index.terms.prefix_search(_))
    .map fn(term_index)
      scores(term_index, index.docs.length, index.normalizers)
        .map-values(_ / 2.0) // lower importance for prefix matches

  (exacth_matches ++ prefix_matches)    
    .foldl(empty-map(), merge(_, _, float64/(+)))
    .to-list
    .sort(?(<) = fn((_, score1), (_, score2)) score1 > score2)
    .flatmap-maybe(fn((doc_id, _)) index.docs.at(doc_id))
    