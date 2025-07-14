// while creating and writing json is easy, parsing json is insanely clunky
// it's easier (and slightly more fun) to write own parser instead
// this is a very simplistic parser, tailored only for the specific case
// no support for nulls and booleans and can allow some invalid jsons
import std/data/json
import std/num/float64
import std/core/undiv

import utils/map
import utils/buffer

type state
  Start
  ParseJson(parent: state)
  Finished(result: json)

  ParsingObj(parent: state, current: buffer<(string,json)> = buffer())
  ParsingKey(parent: state)
  ParsingKVSep(parent: state, key: string)
  ParsingValue(parent: state, key: string)

  ParsingList(parent: state, current: buffer<json> = buffer())
  ParsingString(parent: state, current: buffer<char> = buffer(), escape: bool = False)
  ParsingNum(parent: state, current: buffer<char> = buffer())

fun pair/show(pair: (string, json)): string
  pair.fst.show ++ ": " ++ pair.snd.show

fun show(state: state): string
  match state
    Start -> "<empty>"
    ParseJson(parent) -> parent.show ++ " -> ParseJson"
    ParsingObj(parent, current) -> parent.show ++ " -> ParsingObj(" ++ current.list.show ++ ")"
    ParsingKey(parent) -> parent.show ++ " -> ParsingKey"
    ParsingKVSep(parent, key) -> parent.show ++ " -> ParsingKVSep(" ++ key.show ++ ")"
    ParsingValue(parent, key) -> parent.show ++ " -> ParsingValue(" ++ key.show ++ ")"
    ParsingList(parent, current) -> parent.show ++ " -> ParsingList(" ++ current.list.show ++ ")"
    ParsingString(parent, current, _) -> parent.show ++ " -> ParsingString(" ++ current.list.show ++ ")"
    ParsingNum(parent, current) -> parent.show ++ " -> ParsingNum(" ++ current.list.show ++ ")"
    Finished(result) -> "Finished(" ++ result.show ++ ")"

fun finish(parent: state, value: json): exn state
  match parent
    Start -> Finished(value)
    ParsingValue(ParsingObj(ancestor, current), key) -> ParsingObj(ancestor, current.append((key, value)))
    ParsingList(grandparent, current) -> ParsingList(grandparent, current.append(value))  
    _ -> throw("Unexpected finishing state: " ++ parent.show ++ " " ++ value.show) 

fun to_num(buffer: buffer<char>): exn json
  val str = buffer.list.string
  match parse-int(str)
    Just(result) -> JSInt(result)
    Nothing ->
      match parse-float64(str)
        Just(result) -> JSNum(result)
        Nothing -> throw("Error during parsing num: " ++ str.show)

fun process(state: state, next: char): exn state
  match (state, next)
    (ParseJson(parent), '{') -> ParsingObj(parent)
    (ParseJson(parent), '[') -> ParseJson(ParsingList(parent))
    (ParseJson(parent), '"') -> ParsingString(parent)
    (ParseJson(parent), char) | char.is-digit -> ParsingNum(parent, buffer().append(char))

    (ParsingObj, '"') -> ParsingString(ParsingKey(state))
    (ParsingObj(parent, current), '}') -> finish(parent, JSObj(current.list))
    (ParsingObj, ',') -> state
    (ParsingKVSep(obj, key), ':') -> ParseJson(ParsingValue(obj, key))

    (ParsingList, ',') -> ParseJson(state)
    (ParsingList(parent, current), ']') -> finish(parent, JSList(current.list))

    (ParsingString(parent, current, False), '\\') -> ParsingString(parent, current, True)
    (ParsingString(ParsingKey(grandparent), current, False), '"') -> ParsingKVSep(grandparent, current.list.string)
    (ParsingString(parent, current, False), '"') -> finish(parent, JSString(current.list.string))
    (ParsingString(parent, current, False), char) -> ParsingString(parent, current.append(char))
    (ParsingString(parent, current, True), e) | e == '"' || e == '\\' -> ParsingString(parent, current.append(e))

    (ParsingNum(parent, current), char) | is-digit(char) || char == '.' -> ParsingNum(parent, current.append(char))
    (ParsingNum(parent, current), other) -> finish(parent, current.to_num).pretend-decreasing.process(other)

    _ -> throw("Unexpected state: " ++ state.show ++ " " ++ " before " ++ next.show)


pub fun parse(input: string): exn json
  match input.list.foldl(ParseJson(Start), process)
    Finished(result) -> result
    other -> throw("Unfinished state while parsing json: " ++ other.show)

pub fun intmap/from-json(j: json, path: string, ?from-json: (j: json, path: string) -> pure a): pure map<int, a>
    j
      .to-dict/as-object(path)
      .map fn ((k, v))
        (k.parse-int.expect("Can't parse " ++ k ++ " as int"), v.from-json(k))
      .to-map

pub fun map/from-json(j: json, path: string, ?from-json: (j: json, path: string) -> pure a): pure map<string, a>
    j
      .to-dict/as-object(path)
      .map fn ((k, v))
        (k, v.from-json(k))
      .to-map

pub fun vector/from-json(j: json, path: string, ?from-json: (j: json, path: string) -> pure a): pure vector<a>
  j.list/from-json(path).vector

pub fun map/to-json<k,v>(input: map<k, v>, ?show: (k) -> string, ?to-json: (v) -> json): json
  JSObj(
    input.to-list.map fn ((k, v)) 
      (k.show, v.to-json)
  )

pub fun vector/to-json(v: vector<a>, ?to-json: a -> e json): e json
  v.list.list/to-json