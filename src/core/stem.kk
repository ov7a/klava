import std/text/regex
import std/core/undiv

import utils/string
import utils/string-view
import core/index

val not_letters = regex("[^\\p{L}]+")

pub fun tokenize(s: string): list<token>
  s
    .split(not_letters)
    .map(trim)
    .map(to-lower-unic)
    .filter(is-notempty)

pub fun stem(original: token): token
  ru-stem(original) 

// See http://snowball.tartarus.org/algorithms/russian/stemmer.html for reference
fun ru-stem(original: token): token
  val v = original.view

  val rv_start = match v.index-of(vowels.contains(_))
    Just(idx) | idx < v.length - 1 -> idx + 1
    _ -> return original

  val r2_start = v.r-region(v.r-region(0))

  v
    // step 1
    .trim-any-ending(rv_start, reflectives)
    .trim-endings(rv_start)
    // step 2
    .trim-any-ending(rv_start, ["и"])
    // step 3
    .trim-any-ending(r2_start, derivationals)
    // step 4
    .trim-any-ending(rv_start, superlatives)
    .trim-any-ending(rv_start, ["н"], fn(_, vv) vv.at(-2) == Just('н'))
    .trim-any-ending(rv_start, ["ь"])
    .string
    .replace-all("ё", "е")

val vowels = ['а', 'е', 'и', 'о', 'у', 'ы', 'э', 'ю', 'я']

val afterAorYa = ['а', 'я']

val reflectives = ["сь", "ся"]
val gerunds1 = ["вши", "в"]
val gerunds2 = ["ивши", "ив", "ывши", "ыв"]
val adjectives = ["ее","ие","ые","ое","ей","ий","ый","ой","ем","им","ым","ом","их","ых","ую","юю","ая","яя","ою","ею", "ими","ыми","его","ого","ему","ому"]
val participles1 = ["ем", "нн", "вш", "ющ", "щ"]
val participles2 = ["ивш", "ывш", "ующ"]
val verbs1 = ["ла","на","ете","йте","ли","й","л","ем","н","ло","но","ет","ют","ны","ть","ешь","нно"]
val verbs2 = ["ила","ыла","ена","ейте","уйте","ите","или","ыли","ей","уй","ил","ыл","им","ым","ен","ило","ыло","ено","ят","ует","уют","ит","ыт","ены","ить","ыть","ишь","ую","ю"]
val nouns = ["а","ев","ов","ие","ье","е","иями","ями","ами","еи","ии","и","ией","ей","ой","ий","й","иям","ям","ием","ем","ам","ом","о","у","ах","иях","ях","ы","ь","ию","ью","ю","ия","ья","я"]
val derivationals = ["ост", "ость"]
val superlatives = ["ейше", "ейш"]

fun trim-endings(v: sview, rv_start: int): sview
  (maybe-trim-any-ending(v, rv_start, afterAorYa, gerunds1)
  || maybe-trim-any-ending(v, rv_start, gerunds2)
  || maybe-trim-any-ending(v, rv_start, adjectives).map fn(v2)
    (maybe-trim-any-ending(v2, rv_start, afterAorYa, participles1)
    || maybe-trim-any-ending(v2, rv_start, participles2)
    ).default(v2)
  || maybe-trim-any-ending(v, rv_start, afterAorYa, verbs1)
  || maybe-trim-any-ending(v, rv_start, verbs2)
  || maybe-trim-any-ending(v, rv_start, nouns)
  ).default(v)

fun trim-any-ending(
  v: sview,
  start: int,
  endings: list<string>,
  filter: (sview, sview) -> bool = fn (_, _){ True }
): sview
  maybe-trim-any-ending(v, start, endings, filter).default(v)

fun maybe-trim-any-ending(
  v: sview,
  start: int,
  endings: list<string>,
  filter: (sview, sview) -> bool = fn (_, _){ True }
): maybe<sview>
  match endings
    Nil -> Nothing
    Cons(ending, tail) -> 
      val candidate = ending.view
      if (v.length - start >= candidate.length) && v.ends-with(candidate) && filter(candidate, v) then
        Just(v.drop-last(candidate.length))
      else
        maybe-trim-any-ending(v, start, tail, filter)  

fun chars/maybe-trim-any-ending(
  v: sview,
  start: int,
  subend-candidates: list<char>,
  endings: list<string>
): maybe<sview>
  maybe-trim-any-ending(v, start, endings) fn(c, vv) 
    subend-candidates.any((start < v.length - c.length) && vv.at(~c.length - 1) == Just(_))

fun r-region(v: sview, idx: int = 0): int
  match v.data.at(v.start + idx)
    Just(c) | vowels.contains(c) -> 
      match v.data.at(v.start + idx + 1)
        Just(c2) | not(vowels.contains(c2)) -> idx + 2
        Nothing -> v.length
        _ -> r-region(pretend-decreasing(v), idx + 1)
    Nothing -> v.length
    _ -> r-region(pretend-decreasing(v), idx + 1)

// weird that it's not in std lib
// https://github.com/koka-lang/koka/pull/801
fun contains(l: list<a>, item: a, ^?(==): (x: a, y: a) -> bool): bool
  l.any(_ == item)