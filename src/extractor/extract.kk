import std/os/env
import std/os/path
import std/os/dir
import std/os/file
import std/text/regex

import core/stem
import core/indexer
import core/index
import utils/serde

import front-matter

fun path_to_url(file: path): string
  file
    .basename
    .replace-all(regex("-"), "/", 3)
    .replace-all(".md", ".html")

fun convert(post: path): <exn, fsys> page
  val data = parse_fm(post)
  Page(
    url = "/" ++ path_to_url(post), 
    title = data.title,
    tags = data.tags,
    tags_tokens = data.tags,
    title_tokens = data.title.tokenize,
    body_tokens = data.body.tokenize
  )

fun extract_pages(dir: path): <exn, fsys, div> list<page>
  list-directory-recursive(dir)
    .filter(is-file)
    .filter(_.extname.to-lower == "md")
    .map(convert)

fun extract_pages_from(paths: list<path>): <exn, fsys, div> list<page>
  paths
    .flatmap(extract_pages)  

fun process(output: path, dirs: list<path>)
  val pages = extract_pages_from(dirs)
  val index = index(pages)
  write-text-file(output, serialize(index))

pub fun main()
  match get-args() 
    Cons(output_file, dirs) -> process(path(output_file), dirs.map(path))
    _ -> println("Please provide at least two arguments: output file and list of directories")

