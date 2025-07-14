import std/text/regex

import utils/string
import core/index

val not_letters = regex("[^\\p{L}]+")

// TODO: do a proper stemming
pub fun tokenize(s: string): list<token>
  s
    .split(not_letters)
    .map(trim)
    .map(to-lower-unic)
    .filter(is-notempty)
