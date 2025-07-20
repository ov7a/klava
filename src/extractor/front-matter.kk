import std/os/file
import std/os/path
import std/core/string

import utils/string
import utils/map

pub struct post 
  title: string
  body: string
  tags: list<string>

pub fun show(post: post): string
   "Post(title=" ++ show(post.title) ++ ", tags=" ++ show(post.tags) ++ ", body=" ++ show(post.body)

fun parse_header(header: string): <exn> map<string, string>
  fun parse_header_line(line: string): <exn> (string, string)
    val parts = line.split(":", 2)
    val key_raw = parts[0].expect("Invalid header line: " ++ line)
    val value_raw = parts[1].expect("Invalid header line: " ++ line)
    (key_raw.trim, value_raw.trim)

  header
    .split("\n")
    .filter(fn(line) -> line.contains(":"))
    .map(parse_header_line) 
    .to-map

pub fun parse_fm(file: path): <exn, fsys> post  
  val input = read-text-file(file)
  val parts = split(input, "---", 3)
  val fields = parse_header(parts[1].expect("Invalid frontmatter file (no header): " ++ show(file)))
  val title = fields
    .get("title")
    .expect("No title in header for file: " ++ show(file))
    .trim_chars("\"")
    .replace-all("\\\"", "\"")
  val tags = fields
    .get("tags")
    .default("")
    .trim_chars("\\[\\]")
    .split(",")
    .map(trim)
    .filter(is-notempty)
  Post(title = title, body = parts[2].expect("Invalid frontmatter file (no body): " ++ show(file)), tags = tags) 

